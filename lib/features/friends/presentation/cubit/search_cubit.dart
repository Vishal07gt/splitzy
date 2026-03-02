import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/friends/domain/usecases/friends_usecases.dart';

class SearchCubit extends Cubit<UiStates<List<User>>> {
  final SearchUsersUsecase _searchUsersUsecase;

  SearchCubit(this._searchUsersUsecase) : super(Success<List<User>>([]));

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(Success<List<User>>([]));
      return;
    }
    emit(Progress<List<User>>());
    final result = await _searchUsersUsecase.call(
      SearchUsersParams(query: query),
    );
    result.fold(
      (failure) => emit(Error<List<User>>(failure.message)),
      (users) => emit(Success<List<User>>(users)),
    );
  }

  void clear() => emit(Success<List<User>>([]));
}
