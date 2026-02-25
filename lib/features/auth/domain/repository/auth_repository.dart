import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart'
    show User;

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithCredentials(
    String email,
    String password,
  );
}
