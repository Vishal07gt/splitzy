import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/friends/domain/entities/friend_request_entity.dart';
import 'package:splitzy/features/friends/domain/usecases/friends_usecases.dart';

class IncomingRequestsCubit extends Cubit<UiStates<List<FriendRequestEntity>>> {
  final WatchIncomingRequestsUsecase _watchIncomingRequestsUsecase;
  StreamSubscription? _subscription;

  IncomingRequestsCubit(this._watchIncomingRequestsUsecase)
      : super(DefaultState<List<FriendRequestEntity>>()) {
    _watchRequests();
  }

  void _watchRequests() {
    _subscription = _watchIncomingRequestsUsecase.call().listen((either) {
      either.fold(
        (failure) => emit(Error<List<FriendRequestEntity>>(failure.message)),
        (requests) => emit(Success<List<FriendRequestEntity>>(requests)),
      );
    });
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
