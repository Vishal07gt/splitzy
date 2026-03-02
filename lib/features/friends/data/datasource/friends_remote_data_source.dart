
import 'package:splitzy/features/friends/data/models/friend_model.dart';import 'package:splitzy/features/friends/data/models/friend_request_model.dart';

import '../../../auth/domain/entities/user_entity.dart';

abstract class FriendsRemoteDatasource {
  Future<List<User>> searchUsers(String query);
  Future<void> sendFriendRequest(String addresseeId);
  Future<void> acceptFriendRequest(String friendshipId);
  Future<void> rejectFriendRequest(String friendshipId);
  Future<List<FriendModel>> getFriends();
  Stream<List<FriendRequestModel>> watchIncomingRequests();
}