import 'package:splitzy/features/auth/data/model/user_model.dart';
import 'package:splitzy/features/groups/domain/entities/group_entity.dart';

class GroupModel extends GroupEntity {
  const GroupModel({
    required super.id,
    required super.name,
    super.avatarUrl,
    required super.createdBy,
    required super.createdAt,
    super.members,
  });

  factory GroupModel.fromJson(Map<String, dynamic> json) {
    final membersJson = json['group_members'] as List?;
    final members = membersJson
            ?.map((m) => UserModel.fromjson(
                (m['user'] ?? m) as Map<String, dynamic>))
            .toList() ??
        [];

    return GroupModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      createdBy: json['created_by'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      members: members,
    );
  }
}
