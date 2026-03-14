import 'package:splitzy/features/expenses/data/models/expense_model.dart';

abstract class ExpensesRemoteDatasource {
  Future<List<ExpenseModel>> getGroupExpenses(String groupId);
  Future<ExpenseModel> getExpense(String expenseId);
  Future<ExpenseModel> createExpense({
    required String groupId,
    required String description,
    required double amount,
    required String paidBy,
    required String splitType,
    required Map<String, double> splits,
  });
  Stream<List<ExpenseModel>> watchGroupExpenses(String groupId);
}
