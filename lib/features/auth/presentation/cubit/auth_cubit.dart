import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_with_credentials_usecase.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_up_with_credentials_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class AuthCubit extends Cubit<UiStates<User?>> {
  final SignUpWithCredentialsUsecase signUpUsecase;
  final SignInWithCredentialsUsecase signInUsecase;
  final GoTrueClient _authClient;

  StreamSubscription? _authSubscription;

  AuthCubit({
    required this.signUpUsecase,
    required this.signInUsecase,
    required GoTrueClient authClient,
  })  : _authClient = authClient,
        super(DefaultState<User?>()) {
    _initAuthState();
  }

  void _initAuthState() {
    // Check current session synchronously
    final session = _authClient.currentSession;
    if (session != null) {
      emit(Success<User?>(_userFromSession(session)));
    }

    // Subscribe to auth state changes
    _authSubscription = _authClient.onAuthStateChange.listen(
      (data) {
        if (data.session != null) {
          emit(Success<User?>(_userFromSession(data.session!)));
        } else {
          emit(DefaultState<User?>());
        }
      },
    );
  }

  User _userFromSession(Session session) => User(
        id: session.user.id,
        email: session.user.email ?? '',
        name: session.user.userMetadata?['name'] ?? '',
      );

  Future<void> signIn(SignInParams params) async {
    emit(Progress<User?>());
    final result = await signInUsecase.call(params);
    result.fold(
      (failure) => emit(Error<User?>(failure.message)),
      (user) => emit(Success<User?>(user)),
    );
  }

  Future<void> signUp(SignUpParams params) async {
    emit(Progress<User?>());
    final result = await signUpUsecase.call(params);
    result.fold(
      (failure) => emit(Error<User?>(failure.message)),
      (user) => emit(Success<User?>(user)),
    );
  }

  Future<void> signOut() async {
    await _authClient.signOut();
    emit(DefaultState<User?>());
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
