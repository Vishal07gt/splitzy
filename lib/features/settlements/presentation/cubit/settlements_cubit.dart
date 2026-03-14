import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/settlements/domain/entities/settlement_entity.dart';
import 'package:splitzy/features/settlements/domain/usecases/settlements_usecases.dart';

class SettlementsCubit extends Cubit<UiStates<List<SettlementEntity>>> {
  final GetGroupSettlementsUsecase getGroupSettlementsUsecase;
  final CreateSettlementUsecase createSettlementUsecase;

  SettlementsCubit({
    required this.getGroupSettlementsUsecase,
    required this.createSettlementUsecase,
  }) : super(DefaultState<List<SettlementEntity>>());

  Future<void> loadSettlements(String groupId) async {
    emit(Progress<List<SettlementEntity>>());
    final result = await getGroupSettlementsUsecase.call(
      GetGroupSettlementsParams(groupId: groupId),
    );
    result.fold(
      (failure) => emit(Error<List<SettlementEntity>>(failure.message)),
      (settlements) => emit(Success<List<SettlementEntity>>(settlements)),
    );
  }

  Future<void> createSettlement({
    required String groupId,
    required String paidBy,
    required String paidTo,
    required double amount,
    String? note,
  }) async {
    final result = await createSettlementUsecase.call(
      CreateSettlementParams(
        groupId: groupId,
        paidBy: paidBy,
        paidTo: paidTo,
        amount: amount,
        note: note,
      ),
    );
    result.fold(
      (failure) => emit(Error<List<SettlementEntity>>(failure.message)),
      (_) => loadSettlements(groupId),
    );
  }
}
