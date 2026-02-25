import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_with_credentials_usecase.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_up_with_credentials_usecase.dart';

class AuthBloc extends Cubit<UiStates<User>> {
  AuthBloc({
    required this.signUpWithCredentialsUsecase,
    required this.signInWithCredentialsUsecase,
  }) : super(DefaultState());

  final SignUpWithCredentialsUsecase signUpWithCredentialsUsecase;
  final SignInWithCredentialsUsecase signInWithCredentialsUsecase;

  Future<void> signUpWithCredentials({required SignUpParams params}) async {
    emit(Progress());
    final result = await signUpWithCredentialsUsecase(params);
    result.fold((l) => emit(Error(l.message)), (r) => emit(Success(r)));
  }

  Future<void> signInWithCredentials({required SignInParams params}) async {
    emit(Progress());
    final result = await signInWithCredentialsUsecase(params);
    result.fold((l) => emit(Error(l.message)), (r) => emit(Success(r)));
  }
}
