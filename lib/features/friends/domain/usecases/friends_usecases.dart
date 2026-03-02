import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/core/usecases/usecase.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/friends/domain/entities/friend_entity.dart';
import 'package:splitzy/features/friends/domain/entities/friend_request_entity.dart';
import 'package:splitzy/features/friends/domain/repository/friends_repository.dart';

// ── Search Users ─────────────────────────────────────────────
class SearchUsersUsecase implements UseCase<List<User>, SearchUsersParams> {
  final FriendsRepository _repo;
  const SearchUsersUsecase(this._repo);

  @override
  Future<Either<Failure, List<User>>> call(SearchUsersParams params) =>
      _repo.searchUsers(params.query);
}

class SearchUsersParams extends Equatable {
  final String query;
  const SearchUsersParams({required this.query});

  @override
  List<Object?> get props => [query];
}

// ── Send Friend Request ───────────────────────────────────────
class SendFriendRequestUsecase implements UseCase<void, SendFriendRequestParams> {
  final FriendsRepository _repo;
  const SendFriendRequestUsecase(this._repo);

  @override
  Future<Either<Failure, void>> call(SendFriendRequestParams params) =>
      _repo.sendFriendRequest(params.addresseeId);
}

class SendFriendRequestParams extends Equatable {
  final String addresseeId;
  const SendFriendRequestParams({required this.addresseeId});

  @override
  List<Object?> get props => [addresseeId];
}

// ── Accept Friend Request ─────────────────────────────────────
class AcceptFriendRequestUsecase implements UseCase<void, FriendRequestActionParams> {
  final FriendsRepository _repo;
  const AcceptFriendRequestUsecase(this._repo);

  @override
  Future<Either<Failure, void>> call(FriendRequestActionParams params) =>
      _repo.acceptFriendRequest(params.friendshipId);
}

// ── Reject Friend Request ─────────────────────────────────────
class RejectFriendRequestUsecase implements UseCase<void, FriendRequestActionParams> {
  final FriendsRepository _repo;
  const RejectFriendRequestUsecase(this._repo);

  @override
  Future<Either<Failure, void>> call(FriendRequestActionParams params) =>
      _repo.rejectFriendRequest(params.friendshipId);
}

class FriendRequestActionParams extends Equatable {
  final String friendshipId;
  const FriendRequestActionParams({required this.friendshipId});

  @override
  List<Object?> get props => [friendshipId];
}

// ── Get Friends ───────────────────────────────────────────────
class GetFriendsUsecase implements UseCase<List<FriendEntity>, NoParams> {
  final FriendsRepository _repo;
  const GetFriendsUsecase(this._repo);

  @override
  Future<Either<Failure, List<FriendEntity>>> call(NoParams params) =>
      _repo.getFriends();
}

// ── Watch Incoming Requests (Stream) ─────────────────────────
class WatchIncomingRequestsUsecase {
  final FriendsRepository _repo;
  const WatchIncomingRequestsUsecase(this._repo);

  Stream<Either<Failure, List<FriendRequestEntity>>> call() =>
      _repo.watchIncomingRequests();
}