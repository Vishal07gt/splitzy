import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/features/settlements/data/datasource/settlements_remote_data_source.dart';
import 'package:splitzy/features/settlements/domain/entities/settlement_entity.dart';
import 'package:splitzy/features/settlements/domain/repository/settlements_repository.dart';

class SettlementsRepositoryImpl implements SettlementsRepository {
  final SettlementsRemoteDatasource _datasource;
  const SettlementsRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<SettlementEntity>>> getGroupSettlements(
      String groupId) async {
    try {
      final settlements = await _datasource.getGroupSettlements(groupId);
      return Right(settlements);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, SettlementEntity>> createSettlement({
    required String groupId,
    required String paidBy,
    required String paidTo,
    required double amount,
    String? note,
  }) async {
    try {
      final settlement = await _datasource.createSettlement(
        groupId: groupId,
        paidBy: paidBy,
        paidTo: paidTo,
        amount: amount,
        note: note,
      );
      return Right(settlement);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<SettlementEntity>>> watchGroupSettlements(
      String groupId) {
    return _datasource.watchGroupSettlements(groupId).map(
      (settlements) => Right<Failure, List<SettlementEntity>>(settlements),
    ).handleError(
      (e) => Left<Failure, List<SettlementEntity>>(
        ServerFailure(message: e.toString()),
      ),
    );
  }
}
