import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/expenses/domain/entities/expense_entity.dart';
import 'package:splitzy/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:splitzy/features/groups/domain/entities/group_entity.dart';
import 'package:splitzy/features/groups/presentation/cubit/group_detail_cubit.dart';
import 'package:splitzy/features/settlements/domain/entities/settlement_entity.dart';
import 'package:splitzy/features/settlements/presentation/cubit/settlements_cubit.dart';

class GroupDetailPage extends StatelessWidget {
  final String groupId;
  const GroupDetailPage({super.key, required this.groupId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupDetailCubit, UiStates<GroupEntity>>(
      builder: (context, state) {
        final title = state is Success<GroupEntity> ? state.data.name : 'Group';
        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_add),
                onPressed: () => context.push('/groups/$groupId/add-member'),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final result = await context.push('/groups/$groupId/add-expense');
              if (result == true && context.mounted) {
                context.read<ExpensesCubit>().loadExpenses(groupId);
              }
            },
            child: const Icon(Icons.add),
          ),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, UiStates<GroupEntity> state) {
    if (state is Progress<GroupEntity>) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is Error<GroupEntity>) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectableText('Error: ${state.message}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  context.read<GroupDetailCubit>().loadGroup(groupId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state is Success<GroupEntity>) {
      final group = state.data;
      return RefreshIndicator(
        onRefresh: () async {
          await context.read<GroupDetailCubit>().loadGroup(groupId);
          if (context.mounted) {
            await context.read<ExpensesCubit>().loadExpenses(groupId);
          }
        },
        child: ListView(
          children: [
            // ── Members Section ──────────────────────────
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text('Members',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            ...group.members.map((member) => ListTile(
                  leading: CircleAvatar(
                    child: Text(
                      member.name.isNotEmpty
                          ? member.name[0].toUpperCase()
                          : '?',
                    ),
                  ),
                  title: Text(member.name),
                  subtitle: Text(member.email),
                  trailing: member.id == group.createdBy
                      ? const Chip(
                          label: Text('Admin',
                              style: TextStyle(fontSize: 10)))
                      : null,
                )),
            const Divider(),
            // ── Expenses Section ─────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Expenses',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () async {
                      final result = await context.push('/groups/$groupId/add-expense');
                      if (result == true && context.mounted) {
                        context.read<ExpensesCubit>().loadExpenses(groupId);
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              ),
            ),
            BlocBuilder<ExpensesCubit, UiStates<List<ExpenseEntity>>>(
              builder: (context, expState) {
                if (expState is Progress<List<ExpenseEntity>>) {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (expState is Success<List<ExpenseEntity>>) {
                  if (expState.data.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('No expenses yet',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }
                  return Column(
                    children: expState.data
                        .map((exp) => _ExpenseTile(
                            expense: exp, groupId: groupId))
                        .toList(),
                  );
                }
                if (expState is Error<List<ExpenseEntity>>) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText('Error: ${expState.message}'),
                  );
                }
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('No expenses yet',
                      style: TextStyle(color: Colors.grey)),
                );
              },
            ),
            const Divider(),
            // ── Balances / Settle Up ─────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Balances',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  TextButton(
                    onPressed: () async {
                      await context.push('/groups/$groupId/settlements');
                      if (context.mounted) {
                        context.read<SettlementsCubit>().loadSettlements(groupId);
                        context.read<ExpensesCubit>().loadExpenses(groupId);
                      }
                    },
                    child: const Text('Settle Up'),
                  ),
                ],
              ),
            ),
            BlocBuilder<ExpensesCubit, UiStates<List<ExpenseEntity>>>(
              builder: (context, expState) {
                return BlocBuilder<SettlementsCubit,
                    UiStates<List<SettlementEntity>>>(
                  builder: (context, settState) {
                    final expenses =
                        expState is Success<List<ExpenseEntity>>
                            ? expState.data
                            : <ExpenseEntity>[];
                    final settlements =
                        settState is Success<List<SettlementEntity>>
                            ? settState.data
                            : <SettlementEntity>[];

                    if (expenses.isEmpty && settlements.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('All settled up!',
                            style: TextStyle(color: Colors.grey)),
                      );
                    }

                    final balances = _calculateBalances(
                        expenses, settlements, group);
                    if (balances.isEmpty) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('All settled up!',
                            style: TextStyle(color: Colors.grey)),
                      );
                    }
                    return Column(
                      children: balances.entries.map((e) {
                        final member = group.members
                            .where((m) => m.id == e.key)
                            .firstOrNull;
                        final name = member?.name ?? 'Unknown';
                        final balance = e.value;
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: balance >= 0
                                ? Colors.green[100]
                                : Colors.red[100],
                            child: Text(
                              name.isNotEmpty
                                  ? name[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                          title: Text(name),
                          subtitle: Text(balance >= 0
                              ? 'gets back'
                              : 'owes'),
                          trailing: Text(
                            '\$${balance.abs().toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: balance >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 80), // FAB clearance
          ],
        ),
      );
    }
    return const SizedBox();
  }

  /// Calculates net balance per member:
  /// positive = is owed money, negative = owes money
  Map<String, double> _calculateBalances(
      List<ExpenseEntity> expenses,
      List<SettlementEntity> settlements,
      GroupEntity group) {
    final balances = <String, double>{};
    for (final m in group.members) {
      balances[m.id] = 0;
    }
    for (final exp in expenses) {
      // Person who paid gets credited
      balances[exp.paidBy] = (balances[exp.paidBy] ?? 0) + exp.amount;
      // Each split debits the user
      for (final split in exp.splits) {
        balances[split.userId] =
            (balances[split.userId] ?? 0) - split.amount;
      }
    }
    // Settlements reduce debts
    for (final s in settlements) {
      balances[s.paidBy] = (balances[s.paidBy] ?? 0) + s.amount;
      balances[s.paidTo] = (balances[s.paidTo] ?? 0) - s.amount;
    }
    // Remove zero balances
    balances.removeWhere((_, v) => v.abs() < 0.01);
    return balances;
  }
}

class _ExpenseTile extends StatelessWidget {
  final ExpenseEntity expense;
  final String groupId;
  const _ExpenseTile({required this.expense, required this.groupId});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.MMMd();
    return ListTile(
      leading: CircleAvatar(
        child: Text(
          expense.description.isNotEmpty
              ? expense.description[0].toUpperCase()
              : '?',
        ),
      ),
      title: Text(expense.description),
      subtitle: Text(
        '${expense.paidByUser?.name ?? 'Unknown'} paid \$${expense.amount.toStringAsFixed(2)} - ${dateFormat.format(expense.createdAt)}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () =>
          context.push('/groups/$groupId/expenses/${expense.id}'),
    );
  }
}
