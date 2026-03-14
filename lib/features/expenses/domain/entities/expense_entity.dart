import 'package:equatable/equatable.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/expenses/domain/entities/expense_split_entity.dart';

enum SplitType { equal, exact, percent, shares }

class ExpenseEntity extends Equatable {
  final String id;
  final String? groupId;
  final String description;
  final double amount;
  final String paidBy;
  final User? paidByUser;
  final String category;
  final SplitType splitType;
  final String? receiptUrl;
  final String createdBy;
  final DateTime createdAt;
  final List<ExpenseSplitEntity> splits;

  const ExpenseEntity({
    required this.id,
    this.groupId,
    required this.description,
    required this.amount,
    required this.paidBy,
    this.paidByUser,
    this.category = 'general',
    this.splitType = SplitType.equal,
    this.receiptUrl,
    required this.createdBy,
    required this.createdAt,
    this.splits = const [],
  });

  @override
  List<Object?> get props => [
        id, groupId, description, amount, paidBy, category,
        splitType, receiptUrl, createdBy, createdAt, splits,
      ];
}
