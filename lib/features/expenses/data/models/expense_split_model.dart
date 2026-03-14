import 'package:splitzy/features/auth/data/model/user_model.dart';
import 'package:splitzy/features/expenses/domain/entities/expense_split_entity.dart';

class ExpenseSplitModel extends ExpenseSplitEntity {
  const ExpenseSplitModel({
    required super.id,
    required super.expenseId,
    required super.userId,
    super.user,
    required super.amount,
    super.isSettled,
  });

  factory ExpenseSplitModel.fromJson(Map<String, dynamic> json) {
    return ExpenseSplitModel(
      id: json['id'] as String,
      expenseId: json['expense_id'] as String,
      userId: json['user_id'] as String,
      user: json['user'] != null
          ? UserModel.fromjson(json['user'] as Map<String, dynamic>)
          : null,
      amount: (json['amount'] as num).toDouble(),
      isSettled: json['is_settled'] as bool? ?? false,
    );
  }
}
