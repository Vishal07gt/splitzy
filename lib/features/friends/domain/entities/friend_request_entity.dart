import 'package:equatable/equatable.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';

enum FriendRequestStatus { pending, accepted, rejected }

class FriendRequestEntity extends Equatable {
  final String id;
  final User requester;
  final User addressee;
  final FriendRequestStatus status;
  final DateTime createdAt;

  const FriendRequestEntity({
    required this.id,
    required this.requester,
    required this.addressee,
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, requester, addressee, status, createdAt];
}