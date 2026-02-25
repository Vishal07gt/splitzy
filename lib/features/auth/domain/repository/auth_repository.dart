import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart'
    show User;
import 'package:splitzy/features/auth/domain/usecases/sign_in_with_credentials_usecase.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_up_with_credentials_usecase.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signUpWithCredentials({
    required SignUpParams params,
  });

  Future<Either<Failure, User>> signInWithCredentials({
    required SignInParams params,
  });
}
