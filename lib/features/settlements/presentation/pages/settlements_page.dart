import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/expenses/domain/entities/expense_entity.dart';
import 'package:splitzy/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:splitzy/features/groups/domain/entities/group_entity.dart';
import 'package:splitzy/features/groups/presentation/cubit/group_detail_cubit.dart';
import 'package:splitzy/features/settlements/domain/entities/settlement_entity.dart';
import 'package:splitzy/features/settlements/presentation/cubit/settlements_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class SettlementsPage extends StatefulWidget {
  final String groupId;
  const SettlementsPage({super.key, required this.groupId});

  @override
  State<SettlementsPage> createState() => _SettlementsPageState();
}

class _SettlementsPageState extends State<SettlementsPage> {
  String get _currentUserId =>
      supa.Supabase.instance.client.auth.currentUser!.id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settle Up')),
      body: BlocBuilder<GroupDetailCubit, UiStates<GroupEntity>>(
        builder: (context, groupState) {
          if (groupState is! Success<GroupEntity>) {
            return const Center(child: CircularProgressIndicator());
          }
          final group = groupState.data;

          return BlocBuilder<ExpensesCubit, UiStates<List<ExpenseEntity>>>(
            builder: (context, expState) {
              final expenses = expState is Success<List<ExpenseEntity>>
                  ? expState.data
                  : <ExpenseEntity>[];

              return BlocBuilder<SettlementsCubit,
                  UiStates<List<SettlementEntity>>>(
                builder: (context, settState) {
                  final settlements =
                      settState is Success<List<SettlementEntity>>
                          ? settState.data
                          : <SettlementEntity>[];

                  final debts =
                      _calculateDebts(expenses, settlements, group);

                  return RefreshIndicator(
                    onRefresh: () async {
                      await context
                          .read<SettlementsCubit>()
                          .loadSettlements(widget.groupId);
                      if (context.mounted) {
                        await context
                            .read<ExpensesCubit>()
                            .loadExpenses(widget.groupId);
                      }
                    },
                    child: ListView(
                      children: [
                        // ── Outstanding Debts ────────────────
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text('Outstanding Debts',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                        if (debts.isEmpty)
                          const Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 16),
                            child: Text('All settled up!',
                                style: TextStyle(color: Colors.grey)),
                          )
                        else
                          ...debts.map((debt) => _DebtTile(
                                debt: debt,
                                currentUserId: _currentUserId,
                                onSettle: () => _showSettleDialog(
                                    context, debt),
                              )),
                        const Divider(height: 32),
                        // ── Settlement History ───────────────
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Text('Settlement History',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ),
                        if (settlements.isEmpty)
                          const Padding(
                            padding:
                                EdgeInsets.symmetric(horizontal: 16),
                            child: Text('No settlements yet',
                                style: TextStyle(color: Colors.grey)),
                          )
                        else
                          ...settlements.map(
                              (s) => _SettlementTile(settlement: s)),
                      ],
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showSettleDialog(BuildContext pageContext, _Debt debt) {
    final amountController =
        TextEditingController(text: debt.amount.toStringAsFixed(2));
    bool isLoading = false;

    showDialog(
      context: pageContext,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Record Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${debt.debtorName} pays ${debt.creditorName}'),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                enabled: !isLoading,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      final amount =
                          double.tryParse(amountController.text);
                      if (amount == null || amount <= 0) return;

                      setDialogState(() => isLoading = true);

                      final cubit =
                          pageContext.read<SettlementsCubit>();
                      await cubit.createSettlement(
                        groupId: widget.groupId,
                        paidBy: debt.debtorId,
                        paidTo: debt.creditorId,
                        amount: amount,
                      );

                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);

                      final state = cubit.state;
                      if (state is Error<List<SettlementEntity>> &&
                          pageContext.mounted) {
                        ScaffoldMessenger.of(pageContext).showSnackBar(
                          SnackBar(
                              content:
                                  SelectableText(state.message)),
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2),
                    )
                  : const Text('Mark as Paid'),
            ),
          ],
        ),
      ),
    );
  }

  List<_Debt> _calculateDebts(
    List<ExpenseEntity> expenses,
    List<SettlementEntity> settlements,
    GroupEntity group,
  ) {
    final balances = <String, double>{};
    for (final m in group.members) {
      balances[m.id] = 0;
    }

    for (final exp in expenses) {
      balances[exp.paidBy] = (balances[exp.paidBy] ?? 0) + exp.amount;
      for (final split in exp.splits) {
        balances[split.userId] =
            (balances[split.userId] ?? 0) - split.amount;
      }
    }

    for (final s in settlements) {
      balances[s.paidBy] = (balances[s.paidBy] ?? 0) + s.amount;
      balances[s.paidTo] = (balances[s.paidTo] ?? 0) - s.amount;
    }

    final debtors = <MapEntry<String, double>>[];
    final creditors = <MapEntry<String, double>>[];

    for (final e in balances.entries) {
      if (e.value < -0.01) {
        debtors.add(MapEntry(e.key, -e.value));
      } else if (e.value > 0.01) {
        creditors.add(MapEntry(e.key, e.value));
      }
    }

    final debts = <_Debt>[];
    var di = 0, ci = 0;
    final dAmounts = debtors.map((e) => e.value).toList();
    final cAmounts = creditors.map((e) => e.value).toList();

    while (di < debtors.length && ci < creditors.length) {
      final settle =
          dAmounts[di] < cAmounts[ci] ? dAmounts[di] : cAmounts[ci];
      if (settle > 0.01) {
        final debtorId = debtors[di].key;
        final creditorId = creditors[ci].key;
        final debtorUser =
            group.members.where((m) => m.id == debtorId).firstOrNull;
        final creditorUser = group.members
            .where((m) => m.id == creditorId)
            .firstOrNull;
        debts.add(_Debt(
          debtorId: debtorId,
          debtorName: debtorUser?.name ?? 'Unknown',
          creditorId: creditorId,
          creditorName: creditorUser?.name ?? 'Unknown',
          amount: settle,
        ));
      }
      dAmounts[di] -= settle;
      cAmounts[ci] -= settle;
      if (dAmounts[di] < 0.01) di++;
      if (cAmounts[ci] < 0.01) ci++;
    }

    return debts;
  }
}

class _Debt {
  final String debtorId;
  final String debtorName;
  final String creditorId;
  final String creditorName;
  final double amount;

  const _Debt({
    required this.debtorId,
    required this.debtorName,
    required this.creditorId,
    required this.creditorName,
    required this.amount,
  });
}

class _DebtTile extends StatelessWidget {
  final _Debt debt;
  final String currentUserId;
  final VoidCallback onSettle;

  const _DebtTile({
    required this.debt,
    required this.currentUserId,
    required this.onSettle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.orange[100],
        child: const Icon(Icons.swap_horiz, color: Colors.orange),
      ),
      title: Text('${debt.debtorName} owes ${debt.creditorName}'),
      subtitle: Text('\$${debt.amount.toStringAsFixed(2)}'),
      trailing: (debt.debtorId == currentUserId ||
              debt.creditorId == currentUserId)
          ? FilledButton(
              onPressed: onSettle,
              child: const Text('Settle'),
            )
          : null,
    );
  }
}

class _SettlementTile extends StatelessWidget {
  final SettlementEntity settlement;
  const _SettlementTile({required this.settlement});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMd();
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.green[100],
        child: const Icon(Icons.check, color: Colors.green),
      ),
      title: Text(
        '${settlement.paidByUser?.name ?? 'Unknown'} paid ${settlement.paidToUser?.name ?? 'Unknown'}',
      ),
      subtitle: Text(dateFormat.format(settlement.createdAt)),
      trailing: Text(
        '\$${settlement.amount.toStringAsFixed(2)}',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}
