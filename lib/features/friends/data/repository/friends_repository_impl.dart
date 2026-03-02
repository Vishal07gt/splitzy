import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/friends/data/datasource/friends_remote_data_source.dart';
import 'package:splitzy/features/friends/domain/entities/friend_entity.dart';
import 'package:splitzy/features/friends/domain/entities/friend_request_entity.dart';
import 'package:splitzy/features/friends/domain/repository/friends_repository.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  final FriendsRemoteDatasource _datasource;
  const FriendsRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, List<User>>> searchUsers(String query) async {
    try {
      final users = await _datasource.searchUsers(query);
      return Right(users);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendFriendRequest(String addresseeId) async {
    try {
      await _datasource.sendFriendRequest(addresseeId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptFriendRequest(String friendshipId) async {
    try {
      await _datasource.acceptFriendRequest(friendshipId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> rejectFriendRequest(String friendshipId) async {
    try {
      await _datasource.rejectFriendRequest(friendshipId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FriendEntity>>> getFriends() async {
    try {
      final friends = await _datasource.getFriends();
      return Right(friends);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<FriendRequestEntity>>> watchIncomingRequests() {
    return _datasource.watchIncomingRequests().map(
          (requests) => Right<Failure, List<FriendRequestEntity>>(requests),
    ).handleError(
          (e) => Left<Failure, List<FriendRequestEntity>>(
        ServerFailure(message: e.toString()),
      ),
    );
  }
}