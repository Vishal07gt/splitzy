import 'package:equatable/equatable.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';

class DebtEntity extends Equatable {
  final User debtor;
  final User creditor;
  final double amount;

  const DebtEntity({
    required this.debtor,
    required this.creditor,
    required this.amount,
  });

  @override
  List<Object?> get props => [debtor, creditor, amount];
}
