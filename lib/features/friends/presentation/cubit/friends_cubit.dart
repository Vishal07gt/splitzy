import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/core/usecases/usecase.dart';
import 'package:splitzy/features/friends/domain/entities/friend_entity.dart';
import 'package:splitzy/features/friends/domain/usecases/friends_usecases.dart';

class FriendsCubit extends Cubit<UiStates<List<FriendEntity>>> {
  final GetFriendsUsecase getFriendsUsecase;
  final SendFriendRequestUsecase sendFriendRequestUsecase;
  final AcceptFriendRequestUsecase acceptFriendRequestUsecase;
  final RejectFriendRequestUsecase rejectFriendRequestUsecase;

  FriendsCubit({
    required this.getFriendsUsecase,
    required this.sendFriendRequestUsecase,
    required this.acceptFriendRequestUsecase,
    required this.rejectFriendRequestUsecase,
  }) : super(Progress<List<FriendEntity>>()) {
    loadFriends();
  }

  Future<void> loadFriends() async {
    emit(Progress<List<FriendEntity>>());
    final result = await getFriendsUsecase.call(NoParams());
    result.fold(
      (failure) => emit(Error<List<FriendEntity>>(failure.message)),
      (friends) => emit(Success<List<FriendEntity>>(friends)),
    );
  }

  Future<void> sendRequest(String addresseeId) async {
    await sendFriendRequestUsecase.call(
      SendFriendRequestParams(addresseeId: addresseeId),
    );
    // search page handles UI feedback — no state change on success
  }

  Future<void> acceptRequest(String friendshipId) async {
    final result = await acceptFriendRequestUsecase.call(
      FriendRequestActionParams(friendshipId: friendshipId),
    );
    result.fold(
      (failure) => emit(Error<List<FriendEntity>>(failure.message)),
      (_) => loadFriends(),
    );
  }

  Future<void> rejectRequest(String friendshipId) async {
    await rejectFriendRequestUsecase.call(
      FriendRequestActionParams(friendshipId: friendshipId),
    );
  }
}
