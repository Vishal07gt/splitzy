import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_with_credentials_usecase.dart';

abstract class AuthRemoteDataSource {
  Future<User> signUpWithCredentials({required SignUpParams params});
}
