import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/friends/domain/entities/friend_entity.dart';
import 'package:splitzy/features/friends/domain/entities/friend_request_entity.dart';

abstract class FriendsRepository {
  /// Search users by name or email (excludes self + existing friends)
  Future<Either<Failure, List<User>>> searchUsers(String query);

  /// Send a friend request to another user
  Future<Either<Failure, void>> sendFriendRequest(String addresseeId);

  /// Accept an incoming friend request
  Future<Either<Failure, void>> acceptFriendRequest(String friendshipId);

  /// Reject an incoming friend request
  Future<Either<Failure, void>> rejectFriendRequest(String friendshipId);

  /// Get all accepted friends of current user
  Future<Either<Failure, List<FriendEntity>>> getFriends();

  /// Stream of incoming pending friend requests — real-time
  Stream<Either<Failure, List<FriendRequestEntity>>> watchIncomingRequests();
}