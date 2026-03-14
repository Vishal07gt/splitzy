import 'package:equatable/equatable.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';

class ExpenseSplitEntity extends Equatable {
  final String id;
  final String expenseId;
  final String userId;
  final User? user;
  final double amount;
  final bool isSettled;

  const ExpenseSplitEntity({
    required this.id,
    required this.expenseId,
    required this.userId,
    this.user,
    required this.amount,
    this.isSettled = false,
  });

  @override
  List<Object?> get props => [id, expenseId, userId, amount, isSettled];
}
