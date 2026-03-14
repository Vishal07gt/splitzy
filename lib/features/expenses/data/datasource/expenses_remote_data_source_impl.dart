import 'dart:async';

import 'package:splitzy/features/expenses/data/models/expense_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'expenses_remote_data_source.dart';

class ExpensesRemoteDatasourceImpl implements ExpensesRemoteDatasource {
  final SupabaseClient _client;
  ExpensesRemoteDatasourceImpl(this._client);

  String get _currentUserId => _client.auth.currentUser!.id;

  static const _expenseSelect = '''
    id, group_id, description, amount, paid_by, category,
    split_type, receipt_url, created_by, created_at,
    paid_by_user:users!expenses_paid_by_fkey(id, name, email, avatar_url),
    expense_splits(
      id, expense_id, user_id, amount, is_settled,
      user:users!expense_splits_user_id_fkey(id, name, email, avatar_url)
    )
  ''';

  // ── Get group expenses ──────────────────────────────────────
  @override
  Future<List<ExpenseModel>> getGroupExpenses(String groupId) async {
    final response = await _client
        .from('expenses')
        .select(_expenseSelect)
        .eq('group_id', groupId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ExpenseModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  // ── Get single expense ──────────────────────────────────────
  @override
  Future<ExpenseModel> getExpense(String expenseId) async {
    final response = await _client
        .from('expenses')
        .select(_expenseSelect)
        .eq('id', expenseId)
        .single();

    return ExpenseModel.fromJson(response);
  }

  // ── Create expense with splits ──────────────────────────────
  @override
  Future<ExpenseModel> createExpense({
    required String groupId,
    required String description,
    required double amount,
    required String paidBy,
    required String splitType,
    required Map<String, double> splits,
  }) async {
    // 1. Insert the expense
    final expenseResponse = await _client
        .from('expenses')
        .insert({
          'group_id': groupId,
          'description': description,
          'amount': amount,
          'paid_by': paidBy,
          'category': 'general',
          'split_type': splitType,
          'created_by': _currentUserId,
        })
        .select()
        .single();

    final expenseId = expenseResponse['id'] as String;

    // 2. Insert the splits
    await _client.from('expense_splits').insert(
      splits.entries
          .map((e) => {
                'expense_id': expenseId,
                'user_id': e.key,
                'amount': e.value,
              })
          .toList(),
    );

    // 3. Return full expense with splits
    return getExpense(expenseId);
  }

  // ── Watch group expenses — Realtime ─────────────────────────
  @override
  Stream<List<ExpenseModel>> watchGroupExpenses(String groupId) {
    final controller = StreamController<List<ExpenseModel>>.broadcast();

    // Initial fetch
    getGroupExpenses(groupId).then((expenses) {
      if (!controller.isClosed) controller.add(expenses);
    });

    // Subscribe to realtime changes on expenses table
    _client
        .channel('group_expenses:$groupId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'expenses',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'group_id',
            value: groupId,
          ),
          callback: (_) async {
            final updated = await getGroupExpenses(groupId);
            if (!controller.isClosed) controller.add(updated);
          },
        )
        .subscribe();

    return controller.stream;
  }
}
