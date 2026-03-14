import 'package:equatable/equatable.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';

class GroupMemberEntity extends Equatable {
  final String groupId;
  final User user;
  final DateTime joinedAt;

  const GroupMemberEntity({
    required this.groupId,
    required this.user,
    required this.joinedAt,
  });

  @override
  List<Object?> get props => [groupId, user, joinedAt];
}
