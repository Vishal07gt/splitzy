import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/expenses/domain/entities/expense_entity.dart';
import 'package:splitzy/features/expenses/domain/usecases/expenses_usecases.dart';

class ExpenseDetailCubit extends Cubit<UiStates<ExpenseEntity>> {
  final GetExpenseUsecase getExpenseUsecase;

  ExpenseDetailCubit({
    required this.getExpenseUsecase,
  }) : super(DefaultState<ExpenseEntity>());

  Future<void> loadExpense(String expenseId) async {
    emit(Progress<ExpenseEntity>());
    final result = await getExpenseUsecase.call(
      GetExpenseParams(expenseId: expenseId),
    );
    result.fold(
      (failure) => emit(Error<ExpenseEntity>(failure.message)),
      (expense) => emit(Success<ExpenseEntity>(expense)),
    );
  }
}
