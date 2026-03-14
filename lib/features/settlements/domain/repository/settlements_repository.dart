import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/features/settlements/domain/entities/settlement_entity.dart';

abstract class SettlementsRepository {
  /// Get all settlements for a group
  Future<Either<Failure, List<SettlementEntity>>> getGroupSettlements(
      String groupId);

  /// Record a settlement payment
  Future<Either<Failure, SettlementEntity>> createSettlement({
    required String groupId,
    required String paidBy,
    required String paidTo,
    required double amount,
    String? note,
  });

  /// Stream of settlements for a group — real-time
  Stream<Either<Failure, List<SettlementEntity>>> watchGroupSettlements(
      String groupId);
}
