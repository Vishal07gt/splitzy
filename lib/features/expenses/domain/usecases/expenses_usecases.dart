import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/core/usecases/usecase.dart';
import 'package:splitzy/features/expenses/domain/entities/expense_entity.dart';
import 'package:splitzy/features/expenses/domain/repository/expenses_repository.dart';

// ── Get Group Expenses ───────────────────────────────────────
class GetGroupExpensesUsecase
    implements UseCase<List<ExpenseEntity>, GetGroupExpensesParams> {
  final ExpensesRepository _repo;
  const GetGroupExpensesUsecase(this._repo);

  @override
  Future<Either<Failure, List<ExpenseEntity>>> call(
          GetGroupExpensesParams params) =>
      _repo.getGroupExpenses(params.groupId);
}

class GetGroupExpensesParams extends Equatable {
  final String groupId;
  const GetGroupExpensesParams({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

// ── Get Single Expense ───────────────────────────────────────
class GetExpenseUsecase implements UseCase<ExpenseEntity, GetExpenseParams> {
  final ExpensesRepository _repo;
  const GetExpenseUsecase(this._repo);

  @override
  Future<Either<Failure, ExpenseEntity>> call(GetExpenseParams params) =>
      _repo.getExpense(params.expenseId);
}

class GetExpenseParams extends Equatable {
  final String expenseId;
  const GetExpenseParams({required this.expenseId});

  @override
  List<Object?> get props => [expenseId];
}

// ── Create Expense ───────────────────────────────────────────
class CreateExpenseUsecase
    implements UseCase<ExpenseEntity, CreateExpenseParams> {
  final ExpensesRepository _repo;
  const CreateExpenseUsecase(this._repo);

  @override
  Future<Either<Failure, ExpenseEntity>> call(CreateExpenseParams params) =>
      _repo.createExpense(
        groupId: params.groupId,
        description: params.description,
        amount: params.amount,
        paidBy: params.paidBy,
        splitType: params.splitType,
        splits: params.splits,
      );
}

class CreateExpenseParams extends Equatable {
  final String groupId;
  final String description;
  final double amount;
  final String paidBy;
  final String splitType;
  final Map<String, double> splits;

  const CreateExpenseParams({
    required this.groupId,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.splitType,
    required this.splits,
  });

  @override
  List<Object?> get props =>
      [groupId, description, amount, paidBy, splitType, splits];
}

// ── Watch Group Expenses (Stream) ────────────────────────────
class WatchGroupExpensesUsecase {
  final ExpensesRepository _repo;
  const WatchGroupExpensesUsecase(this._repo);

  Stream<Either<Failure, List<ExpenseEntity>>> call(String groupId) =>
      _repo.watchGroupExpenses(groupId);
}
