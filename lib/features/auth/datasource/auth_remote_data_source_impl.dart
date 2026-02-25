import 'package:splitzy/features/auth/data/model/user_model.dart'
    show UserModel;
import 'package:splitzy/features/auth/datasource/auth_remote_data_source.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_with_credentials_usecase.dart'
    show SignInParams;
import 'package:splitzy/features/auth/domain/usecases/sign_up_with_credentials_usecase.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final supa.SupabaseClient supabase;
  const AuthRemoteDataSourceImpl(this.supabase);

  @override
  Future<UserModel> signUpWithCredentials({
    required SignUpParams params,
  }) async {
    try {
      final result = await supabase.auth.signUp(
        email: params.email,
        password: params.password,
        data: {'name': params.name},
      );
      return UserModel.fromUser(result.user!);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<UserModel> signInWithCredentials({
    required SignInParams params,
  }) async {
    try {
      final result = await supabase.auth.signInWithPassword(
        email: params.email,
        password: params.password,
      );
      return UserModel.fromjson(result.user!.toJson());
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
