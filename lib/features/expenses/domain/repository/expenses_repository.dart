import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/features/expenses/domain/entities/expense_entity.dart';

abstract class ExpensesRepository {
  /// Get all expenses for a group
  Future<Either<Failure, List<ExpenseEntity>>> getGroupExpenses(String groupId);

  /// Get a single expense by ID
  Future<Either<Failure, ExpenseEntity>> getExpense(String expenseId);

  /// Create an expense with splits
  Future<Either<Failure, ExpenseEntity>> createExpense({
    required String groupId,
    required String description,
    required double amount,
    required String paidBy,
    required String splitType,
    required Map<String, double> splits,
  });

  /// Stream of expenses for a group — real-time
  Stream<Either<Failure, List<ExpenseEntity>>> watchGroupExpenses(String groupId);
}
