import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/features/auth/data/datasource/auth_remote_datasoure.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart'
    show User;
import 'package:splitzy/features/auth/domain/repository/auth_repository.dart';

abstract class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl(this.authRemoteDataSource);

  @override
  Future<Either<Failure, User>> signInWithCredentials(
    String email,
    String password,
  ) async {
    try {
      final result = await authRemoteDataSource.signInWithCredentials(
        email,
        password,
      );
      return right(result);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}
