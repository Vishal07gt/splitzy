import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_with_credentials_usecase.dart';

class AuthBloc extends Cubit<UiStates<User>> {
  AuthBloc({required this.signInWithCredentialsUsecase})
    : super(DefaultState());

  final SignInWithCredentialsUsecase signInWithCredentialsUsecase;

  Future<void> signInWithCredentials(String email, String password) async {
    emit(Progress());
    final result = await signInWithCredentialsUsecase(
      SignInParams(email: email, password: password),
    );
    result.fold((l) => emit(Error(l.message)), (r) => emit(Success(r)));
  }
}
