import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/core/usecases/usecase.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart'
    show User;
import 'package:splitzy/features/auth/domain/repository/auth_repository.dart';

class SignUpWithCredentialsUsecase implements UseCase<User, SignUpParams> {
  final AuthRepository _repository;

  SignUpWithCredentialsUsecase(this._repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) {
    return _repository.signUpWithCredentials(params: params);
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String name;

  const SignUpParams({
    required this.email,
    required this.password,
    required this.name,
  });
}
