import 'package:fpdart/fpdart.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/features/auth/data/datasource/auth_remote_datasoure.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart'
    show User;
import 'package:splitzy/features/auth/domain/repository/auth_repository.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_with_credentials_usecase.dart';

abstract class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource authRemoteDataSource;

  AuthRepositoryImpl(this.authRemoteDataSource);

  @override
  Future<Either<Failure, User>> signUpWithCredentials({
    required SignUpParams params,
  }) async {
    try {
      final result = await authRemoteDataSource.signUpWithCredentials(
        params: params,
      );
      return right(result);
    } catch (e) {
      return left(Failure(message: e.toString()));
    }
  }
}
