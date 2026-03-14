import 'package:equatable/equatable.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';

class GroupEntity extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final String createdBy;
  final DateTime createdAt;
  final List<User> members;

  const GroupEntity({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.createdBy,
    required this.createdAt,
    this.members = const [],
  });

  @override
  List<Object?> get props => [id, name, avatarUrl, createdBy, createdAt, members];
}
