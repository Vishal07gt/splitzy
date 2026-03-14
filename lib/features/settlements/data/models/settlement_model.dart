import 'package:splitzy/features/auth/data/model/user_model.dart';
import 'package:splitzy/features/settlements/domain/entities/settlement_entity.dart';

class SettlementModel extends SettlementEntity {
  const SettlementModel({
    required super.id,
    required super.groupId,
    required super.paidBy,
    super.paidByUser,
    required super.paidTo,
    super.paidToUser,
    required super.amount,
    super.note,
    required super.createdAt,
  });

  factory SettlementModel.fromJson(Map<String, dynamic> json) {
    return SettlementModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      paidBy: json['paid_by'] as String,
      paidByUser: json['paid_by_user'] != null
          ? UserModel.fromjson(
              json['paid_by_user'] as Map<String, dynamic>)
          : null,
      paidTo: json['paid_to'] as String,
      paidToUser: json['paid_to_user'] != null
          ? UserModel.fromjson(
              json['paid_to_user'] as Map<String, dynamic>)
          : null,
      amount: (json['amount'] as num).toDouble(),
      note: json['note'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
