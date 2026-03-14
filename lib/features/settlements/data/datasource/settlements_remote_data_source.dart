import 'package:splitzy/features/settlements/data/models/settlement_model.dart';

abstract class SettlementsRemoteDatasource {
  Future<List<SettlementModel>> getGroupSettlements(String groupId);
  Future<SettlementModel> createSettlement({
    required String groupId,
    required String paidBy,
    required String paidTo,
    required double amount,
    String? note,
  });
  Stream<List<SettlementModel>> watchGroupSettlements(String groupId);
}
