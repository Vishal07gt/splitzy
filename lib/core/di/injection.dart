import 'package:get_it/get_it.dart';
import 'package:splitzy/features/auth/data/repository/auth_repository_impl.dart';
import 'package:splitzy/features/auth/datasource/auth_remote_data_source_impl.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_with_credentials_usecase.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_up_with_credentials_usecase.dart';
import 'package:splitzy/features/auth/presentation/blocs/auth_bloc/auth_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

void authInjection() {
  // Datasource
  sl.registerLazySingleton<AuthRemoteDataSourceImpl>(
    () => AuthRemoteDataSourceImpl(sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepositoryImpl>(
    () => AuthRepositoryImpl(sl<AuthRemoteDataSourceImpl>()),
  );

  // Usecases
  sl.registerLazySingleton(
    () => SignUpWithCredentialsUsecase(sl<AuthRepositoryImpl>()),
  );
  sl.registerLazySingleton(
    () => SignInWithCredentialsUsecase(sl<AuthRepositoryImpl>()),
  );

  // Bloc — factory so a fresh instance is created each time it's needed
  sl.registerFactory(
    () => AuthBloc(
      signUpWithCredentialsUsecase: sl(),
      signInWithCredentialsUsecase: sl(),
    ),
  );
}

void setupInjection() {
  // External
  sl.registerLazySingleton(() => Supabase.instance.client);

  // Features
  authInjection();
}
