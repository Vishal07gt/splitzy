import 'package:equatable/equatable.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';

enum FriendSource { manual, group }

class FriendEntity extends Equatable {
  final String friendshipId;
  final User friend;
  final FriendSource source;
  final DateTime since;

  const FriendEntity({
    required this.friendshipId,
    required this.friend,
    required this.source,
    required this.since,
  });

  @override
  List<Object?> get props => [friendshipId, friend, source, since];
}