import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitzy/core/usecases/usecase.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/auth/presentation/providers/auth_notifier.dart';
import 'package:splitzy/features/friends/data/repository/friends_repository_impl.dart';
import 'package:splitzy/features/friends/domain/entities/friend_entity.dart';
import 'package:splitzy/features/friends/domain/entities/friend_request_entity.dart';
import 'package:splitzy/features/friends/domain/usecases/friends_usecases.dart';

import '../../data/datasource/friends_remote_data_source_impl.dart';

part 'friends_notifier.g.dart';

@riverpod
FriendsRemoteDatasourceImpl friendsDatasource(FriendsDatasourceRef ref) {
  return FriendsRemoteDatasourceImpl(ref.watch(supabaseClientProvider));
}

@riverpod
FriendsRepositoryImpl friendsRepository(FriendsRepositoryRef ref) {
  return FriendsRepositoryImpl(ref.watch(friendsDatasourceProvider));
}

@riverpod
SearchUsersUsecase searchUsersUsecase(SearchUsersUsecaseRef ref) {
  return SearchUsersUsecase(ref.watch(friendsRepositoryProvider));
}

@riverpod
SendFriendRequestUsecase sendFriendRequestUsecase(SendFriendRequestUsecaseRef ref) {
  return SendFriendRequestUsecase(ref.watch(friendsRepositoryProvider));
}

@riverpod
AcceptFriendRequestUsecase acceptFriendRequestUsecase(AcceptFriendRequestUsecaseRef ref) {
  return AcceptFriendRequestUsecase(ref.watch(friendsRepositoryProvider));
}

@riverpod
RejectFriendRequestUsecase rejectFriendRequestUsecase(RejectFriendRequestUsecaseRef ref) {
  return RejectFriendRequestUsecase(ref.watch(friendsRepositoryProvider));
}

@riverpod
GetFriendsUsecase getFriendsUsecase(GetFriendsUsecaseRef ref) {
  return GetFriendsUsecase(ref.watch(friendsRepositoryProvider));
}

@riverpod
WatchIncomingRequestsUsecase watchIncomingRequestsUsecase(WatchIncomingRequestsUsecaseRef ref) {
  return WatchIncomingRequestsUsecase(ref.watch(friendsRepositoryProvider));
}

// ── Friends List Notifier ─────────────────────────────────────

@riverpod
class FriendsNotifier extends _$FriendsNotifier {
  @override
  AsyncValue<List<FriendEntity>> build() {
    // auto-load friends on provider creation
    Future.microtask(() => loadFriends());
    return const AsyncValue.loading();
  }

  Future<void> loadFriends() async {
    state = const AsyncValue.loading();
    final result = await ref
        .read(getFriendsUsecaseProvider)
        .call(NoParams());
    result.fold(
          (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
          (friends) => state = AsyncValue.data(friends),
    );
  }

  Future<void> sendRequest(String addresseeId) async {
    final result = await ref
        .read(sendFriendRequestUsecaseProvider)
        .call(SendFriendRequestParams(addresseeId: addresseeId));
    result.fold(
          (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
          (_) => null, // search page handles UI feedback
    );
  }

  Future<void> acceptRequest(String friendshipId) async {
    final result = await ref
        .read(acceptFriendRequestUsecaseProvider)
        .call(FriendRequestActionParams(friendshipId: friendshipId));
    result.fold(
          (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
          (_) => loadFriends(), // refresh friends list after accepting
    );
  }

  Future<void> rejectRequest(String friendshipId) async {
    await ref
        .read(rejectFriendRequestUsecaseProvider)
        .call(FriendRequestActionParams(friendshipId: friendshipId));
  }
}

// ── Search Notifier ───────────────────────────────────────────

@riverpod
class SearchNotifier extends _$SearchNotifier {
  @override
  AsyncValue<List<User>> build() => const AsyncValue.data([]);

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    final result = await ref
        .read(searchUsersUsecaseProvider)
        .call(SearchUsersParams(query: query));
    result.fold(
          (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
          (users)   => state = AsyncValue.data(users),
    );
  }

  void clear() => state = const AsyncValue.data([]);
}

// ── Incoming Requests Stream Provider ────────────────────────

@riverpod
Stream<List<FriendRequestEntity>> incomingRequests(IncomingRequestsRef ref) {
  return ref
      .watch(watchIncomingRequestsUsecaseProvider)
      .call()
      .map((either) => either.fold((_) => [], (requests) => requests));
}