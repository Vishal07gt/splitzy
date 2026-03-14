import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/expenses/domain/entities/expense_entity.dart';
import 'package:splitzy/features/expenses/domain/usecases/expenses_usecases.dart';

class ExpensesCubit extends Cubit<UiStates<List<ExpenseEntity>>> {
  final GetGroupExpensesUsecase getGroupExpensesUsecase;
  final CreateExpenseUsecase createExpenseUsecase;

  ExpensesCubit({
    required this.getGroupExpensesUsecase,
    required this.createExpenseUsecase,
  }) : super(DefaultState<List<ExpenseEntity>>());

  Future<void> loadExpenses(String groupId) async {
    emit(Progress<List<ExpenseEntity>>());
    final result = await getGroupExpensesUsecase.call(
      GetGroupExpensesParams(groupId: groupId),
    );
    result.fold(
      (failure) => emit(Error<List<ExpenseEntity>>(failure.message)),
      (expenses) => emit(Success<List<ExpenseEntity>>(expenses)),
    );
  }

  Future<void> createExpense({
    required String groupId,
    required String description,
    required double amount,
    required String paidBy,
    required String splitType,
    required Map<String, double> splits,
  }) async {
    final result = await createExpenseUsecase.call(
      CreateExpenseParams(
        groupId: groupId,
        description: description,
        amount: amount,
        paidBy: paidBy,
        splitType: splitType,
        splits: splits,
      ),
    );
    result.fold(
      (failure) => emit(Error<List<ExpenseEntity>>(failure.message)),
      (_) => loadExpenses(groupId),
    );
  }
}
