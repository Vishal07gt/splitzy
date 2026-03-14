import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/core/usecases/usecase.dart';
import 'package:splitzy/features/settlements/domain/entities/settlement_entity.dart';
import 'package:splitzy/features/settlements/domain/repository/settlements_repository.dart';

// ── Get Group Settlements ────────────────────────────────────
class GetGroupSettlementsUsecase
    implements UseCase<List<SettlementEntity>, GetGroupSettlementsParams> {
  final SettlementsRepository _repo;
  const GetGroupSettlementsUsecase(this._repo);

  @override
  Future<Either<Failure, List<SettlementEntity>>> call(
          GetGroupSettlementsParams params) =>
      _repo.getGroupSettlements(params.groupId);
}

class GetGroupSettlementsParams extends Equatable {
  final String groupId;
  const GetGroupSettlementsParams({required this.groupId});

  @override
  List<Object?> get props => [groupId];
}

// ── Create Settlement ────────────────────────────────────────
class CreateSettlementUsecase
    implements UseCase<SettlementEntity, CreateSettlementParams> {
  final SettlementsRepository _repo;
  const CreateSettlementUsecase(this._repo);

  @override
  Future<Either<Failure, SettlementEntity>> call(
          CreateSettlementParams params) =>
      _repo.createSettlement(
        groupId: params.groupId,
        paidBy: params.paidBy,
        paidTo: params.paidTo,
        amount: params.amount,
        note: params.note,
      );
}

class CreateSettlementParams extends Equatable {
  final String groupId;
  final String paidBy;
  final String paidTo;
  final double amount;
  final String? note;

  const CreateSettlementParams({
    required this.groupId,
    required this.paidBy,
    required this.paidTo,
    required this.amount,
    this.note,
  });

  @override
  List<Object?> get props => [groupId, paidBy, paidTo, amount, note];
}

// ── Watch Group Settlements (Stream) ─────────────────────────
class WatchGroupSettlementsUsecase {
  final SettlementsRepository _repo;
  const WatchGroupSettlementsUsecase(this._repo);

  Stream<Either<Failure, List<SettlementEntity>>> call(String groupId) =>
      _repo.watchGroupSettlements(groupId);
}
