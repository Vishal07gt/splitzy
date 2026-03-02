import 'package:splitzy/features/auth/data/model/user_model.dart';
import 'package:splitzy/features/friends/domain/entities/friend_request_entity.dart';

// ── FriendRequestModel ────────────────────────────────────────
class FriendRequestModel extends FriendRequestEntity {
  const FriendRequestModel({
    required super.id,
    required super.requester,
    required super.addressee,
    required super.status,
    required super.createdAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) {
    return FriendRequestModel(
      id:        json['id'] as String,
      requester: UserModel.fromjson(json['requester'] as Map<String, dynamic>),
      addressee: UserModel.fromjson(json['addressee'] as Map<String, dynamic>),
      status:    _parseStatus(json['status'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  static FriendRequestStatus _parseStatus(String status) {
    switch (status) {
      case 'accepted': return FriendRequestStatus.accepted;
      case 'rejected': return FriendRequestStatus.rejected;
      default:         return FriendRequestStatus.pending;
    }
  }
}