import 'package:equatable/equatable.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';

class BalanceEntity extends Equatable {
  final User user;
  final double totalPaid;
  final double totalOwed;
  final double netBalance; // positive = is owed, negative = owes

  const BalanceEntity({
    required this.user,
    required this.totalPaid,
    required this.totalOwed,
    required this.netBalance,
  });

  @override
  List<Object?> get props => [user, totalPaid, totalOwed, netBalance];
}
