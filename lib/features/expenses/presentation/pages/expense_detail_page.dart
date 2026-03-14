import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/expenses/domain/entities/expense_entity.dart';
import 'package:splitzy/features/expenses/presentation/cubit/expense_detail_cubit.dart';

class ExpenseDetailPage extends StatelessWidget {
  final String expenseId;
  const ExpenseDetailPage({super.key, required this.expenseId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseDetailCubit, UiStates<ExpenseEntity>>(
      builder: (context, state) {
        final title =
            state is Success<ExpenseEntity> ? state.data.description : 'Expense';
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          body: _buildBody(context, state),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, UiStates<ExpenseEntity> state) {
    if (state is Progress<ExpenseEntity>) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is Error<ExpenseEntity>) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectableText('Error: ${state.message}'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () =>
                  context.read<ExpenseDetailCubit>().loadExpense(expenseId),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (state is Success<ExpenseEntity>) {
      final expense = state.data;
      final dateFormat = DateFormat.yMMMd();
      return ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Amount ──────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    '\$${expense.amount.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(expense.description,
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Paid by ${expense.paidByUser?.name ?? 'Unknown'}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    dateFormat.format(expense.createdAt),
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // ── Split info ──────────────────────────────
          Text(
            'Split (${expense.splitType.name})',
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          ...expense.splits.map((split) => ListTile(
                leading: CircleAvatar(
                  child: Text(
                    split.user?.name.isNotEmpty == true
                        ? split.user!.name[0].toUpperCase()
                        : '?',
                  ),
                ),
                title: Text(split.user?.name ?? 'Unknown'),
                trailing: Text(
                  '\$${split.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: split.isSettled ? Colors.green : null,
                  ),
                ),
                subtitle: split.isSettled
                    ? const Text('Settled',
                        style: TextStyle(color: Colors.green))
                    : null,
              )),
        ],
      );
    }
    return const SizedBox();
  }
}
