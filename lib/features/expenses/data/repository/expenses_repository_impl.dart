import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/features/expenses/data/datasource/expenses_remote_data_source.dart';
import 'package:splitzy/features/expenses/domain/entities/expense_entity.dart';
import 'package:splitzy/features/expenses/domain/repository/expenses_repository.dart';

class ExpensesRepositoryImpl implements ExpensesRepository {
  final ExpensesRemoteDatasource _datasource;
  const ExpensesRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<ExpenseEntity>>> getGroupExpenses(
      String groupId) async {
    try {
      final expenses = await _datasource.getGroupExpenses(groupId);
      return Right(expenses);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> getExpense(String expenseId) async {
    try {
      final expense = await _datasource.getExpense(expenseId);
      return Right(expense);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExpenseEntity>> createExpense({
    required String groupId,
    required String description,
    required double amount,
    required String paidBy,
    required String splitType,
    required Map<String, double> splits,
  }) async {
    try {
      final expense = await _datasource.createExpense(
        groupId: groupId,
        description: description,
        amount: amount,
        paidBy: paidBy,
        splitType: splitType,
        splits: splits,
      );
      return Right(expense);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<ExpenseEntity>>> watchGroupExpenses(
      String groupId) {
    return _datasource.watchGroupExpenses(groupId).map(
      (expenses) => Right<Failure, List<ExpenseEntity>>(expenses),
    ).handleError(
      (e) => Left<Failure, List<ExpenseEntity>>(
        ServerFailure(message: e.toString()),
      ),
    );
  }
}
