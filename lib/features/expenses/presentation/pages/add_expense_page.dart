import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/expenses/domain/entities/expense_entity.dart';
import 'package:splitzy/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:splitzy/features/groups/domain/entities/group_entity.dart';
import 'package:splitzy/features/groups/presentation/cubit/group_detail_cubit.dart';

class AddExpensePage extends StatefulWidget {
  final String groupId;
  const AddExpensePage({super.key, required this.groupId});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final _descController = TextEditingController();
  final _amountController = TextEditingController();
  String? _paidBy;
  bool _splitEqually = true;
  final Map<String, TextEditingController> _customSplitControllers = {};
  List<User> _members = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    for (final c in _customSplitControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: BlocBuilder<GroupDetailCubit, UiStates<GroupEntity>>(
          builder: (context, groupState) {
            if (groupState is Progress<GroupEntity>) {
              return const Center(child: CircularProgressIndicator());
            }
            if (groupState is Success<GroupEntity>) {
              _members = groupState.data.members;
              _paidBy ??= _members.isNotEmpty ? _members.first.id : null;
              // Initialize custom split controllers
              for (final m in _members) {
                _customSplitControllers.putIfAbsent(
                    m.id, () => TextEditingController());
              }
              return _buildForm(context);
            }
            return const SizedBox();
          },
        ),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _descController,
            decoration: const InputDecoration(
              labelText: 'Description',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              border: OutlineInputBorder(),
              prefixText: '\$ ',
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            initialValue: _paidBy,
            decoration: const InputDecoration(
              labelText: 'Paid by',
              border: OutlineInputBorder(),
            ),
            items: _members
                .map((m) => DropdownMenuItem(
                      value: m.id,
                      child: Text(m.name),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _paidBy = v),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Split equally'),
            value: _splitEqually,
            onChanged: (v) => setState(() => _splitEqually = v),
          ),
          if (!_splitEqually) ...[
            const SizedBox(height: 8),
            const Text('Custom amounts per member:',
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ..._members.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: _customSplitControllers[m.id],
                    decoration: InputDecoration(
                      labelText: m.name,
                      border: const OutlineInputBorder(),
                      prefixText: '\$ ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                )),
          ],
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Add Expense'),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    final desc = _descController.text.trim();
    final amountText = _amountController.text.trim();
    if (desc.isEmpty || amountText.isEmpty || _paidBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill in all fields')),
      );
      return;
    }
    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid amount')),
      );
      return;
    }

    Map<String, double> splits;
    String splitType;

    if (_splitEqually) {
      splitType = 'equal';
      final perPerson = amount / _members.length;
      splits = {for (final m in _members) m.id: perPerson};
    } else {
      splitType = 'exact';
      splits = {};
      double total = 0;
      for (final m in _members) {
        final val =
            double.tryParse(_customSplitControllers[m.id]?.text ?? '') ?? 0;
        splits[m.id] = val;
        total += val;
      }
      if ((total - amount).abs() > 0.01) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Split total (\$${total.toStringAsFixed(2)}) must equal expense amount (\$${amount.toStringAsFixed(2)})')),
        );
        return;
      }
    }

    setState(() => _isSubmitting = true);
    final cubit = context.read<ExpensesCubit>();
    await cubit.createExpense(
      groupId: widget.groupId,
      description: desc,
      amount: amount,
      paidBy: _paidBy!,
      splitType: splitType,
      splits: splits,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);
    final state = cubit.state;
    if (state is Error<List<ExpenseEntity>>) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: SelectableText(state.message)),
      );
    } else {
      context.pop(true);
    }
  }
}
