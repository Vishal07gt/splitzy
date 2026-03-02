import 'package:splitzy/features/auth/data/model/user_model.dart';
import 'package:splitzy/features/friends/domain/entities/friend_entity.dart';

class FriendModel extends FriendEntity {
  const FriendModel({
    required super.friendshipId,
    required super.friend,
    required super.source,
    required super.since,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json, String currentUserId) {
    // friendships table joins both users — pick the one that isn't current user
    final isRequester = json['requester_id'] == currentUserId;
    final friendJson  = isRequester ? json['addressee'] : json['requester'];

    return FriendModel(
      friendshipId: json['id'] as String,
      friend: UserModel.fromjson(friendJson as Map<String, dynamic>),
      source: json['source'] == 'group'
          ? FriendSource.group
          : FriendSource.manual,
      since: DateTime.parse(json['created_at'] as String),
    );
  }
}