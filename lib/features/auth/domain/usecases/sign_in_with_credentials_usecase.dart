import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/core/usecases/usecase.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart'
    show User;
import 'package:splitzy/features/auth/domain/repository/auth_repository.dart';

class SignInWithCredentialsUsecase implements UseCase<User, SignInParams> {
  final AuthRepository _repository;

  SignInWithCredentialsUsecase(this._repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) {
    return _repository.signInWithCredentials(params.email, params.password);
  }
}

class SignInParams {
  final String email;
  final String password;

  const SignInParams({required this.email, required this.password});
}
