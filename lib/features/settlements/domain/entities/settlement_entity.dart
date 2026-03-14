import 'package:equatable/equatable.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';

class SettlementEntity extends Equatable {
  final String id;
  final String groupId;
  final String paidBy;
  final User? paidByUser;
  final String paidTo;
  final User? paidToUser;
  final double amount;
  final String? note;
  final DateTime createdAt;

  const SettlementEntity({
    required this.id,
    required this.groupId,
    required this.paidBy,
    this.paidByUser,
    required this.paidTo,
    this.paidToUser,
    required this.amount,
    this.note,
    required this.createdAt,
  });

  @override
  List<Object?> get props =>
      [id, groupId, paidBy, paidTo, amount, note, createdAt];
}
