import 'package:splitzy/features/auth/data/model/user_model.dart';
import 'package:splitzy/features/expenses/data/models/expense_split_model.dart';
import 'package:splitzy/features/expenses/domain/entities/expense_entity.dart';

class ExpenseModel extends ExpenseEntity {
  const ExpenseModel({
    required super.id,
    super.groupId,
    required super.description,
    required super.amount,
    required super.paidBy,
    super.paidByUser,
    super.category,
    super.splitType,
    super.receiptUrl,
    required super.createdBy,
    required super.createdAt,
    super.splits,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    final splitsJson = json['expense_splits'] as List?;
    final splits = splitsJson
            ?.map((s) =>
                ExpenseSplitModel.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    final splitTypeStr = json['split_type'] as String? ?? 'equal';
    final splitType = SplitType.values.firstWhere(
      (e) => e.name == splitTypeStr,
      orElse: () => SplitType.equal,
    );

    return ExpenseModel(
      id: json['id'] as String,
      groupId: json['group_id'] as String?,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      paidBy: json['paid_by'] as String,
      paidByUser: json['paid_by_user'] != null
          ? UserModel.fromjson(
              json['paid_by_user'] as Map<String, dynamic>)
          : null,
      category: json['category'] as String? ?? 'general',
      splitType: splitType,
      receiptUrl: json['receipt_url'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      splits: splits,
    );
  }
}
