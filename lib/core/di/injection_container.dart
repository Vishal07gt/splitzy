import 'package:get_it/get_it.dart';
import 'package:splitzy/features/auth/data/datasource/auth_remote_data_source_impl.dart';
import 'package:splitzy/features/auth/data/repository/auth_repository_impl.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_with_credentials_usecase.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_up_with_credentials_usecase.dart';
import 'package:splitzy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:splitzy/features/friends/data/datasource/friends_remote_data_source_impl.dart';
import 'package:splitzy/features/friends/data/repository/friends_repository_impl.dart';
import 'package:splitzy/features/friends/domain/usecases/friends_usecases.dart';
import 'package:splitzy/features/friends/presentation/cubit/friends_cubit.dart';
import 'package:splitzy/features/friends/presentation/cubit/incoming_requests_cubit.dart';
import 'package:splitzy/features/friends/presentation/cubit/search_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final sl = GetIt.instance;

Future<void> configureDependencies() async {
  // ── External ───────────────────────────────────────────────
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ── Auth ───────────────────────────────────────────────────
  sl.registerLazySingleton(() => AuthRemoteDataSourceImpl(sl<SupabaseClient>()));
  sl.registerLazySingleton(() => AuthRepositoryImpl(sl<AuthRemoteDataSourceImpl>()));
  sl.registerLazySingleton(() => SignUpWithCredentialsUsecase(sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(() => SignInWithCredentialsUsecase(sl<AuthRepositoryImpl>()));
  sl.registerLazySingleton(() => AuthCubit(
    signUpUsecase: sl<SignUpWithCredentialsUsecase>(),
    signInUsecase: sl<SignInWithCredentialsUsecase>(),
    authClient: sl<SupabaseClient>().auth,
  ));

  // ── Friends ────────────────────────────────────────────────
  sl.registerLazySingleton(() => FriendsRemoteDatasourceImpl(sl<SupabaseClient>()));
  sl.registerLazySingleton(() => FriendsRepositoryImpl(sl<FriendsRemoteDatasourceImpl>()));
  sl.registerLazySingleton(() => SearchUsersUsecase(sl<FriendsRepositoryImpl>()));
  sl.registerLazySingleton(() => SendFriendRequestUsecase(sl<FriendsRepositoryImpl>()));
  sl.registerLazySingleton(() => AcceptFriendRequestUsecase(sl<FriendsRepositoryImpl>()));
  sl.registerLazySingleton(() => RejectFriendRequestUsecase(sl<FriendsRepositoryImpl>()));
  sl.registerLazySingleton(() => GetFriendsUsecase(sl<FriendsRepositoryImpl>()));
  sl.registerLazySingleton(() => WatchIncomingRequestsUsecase(sl<FriendsRepositoryImpl>()));

  sl.registerFactory(() => FriendsCubit(
    getFriendsUsecase: sl<GetFriendsUsecase>(),
    sendFriendRequestUsecase: sl<SendFriendRequestUsecase>(),
    acceptFriendRequestUsecase: sl<AcceptFriendRequestUsecase>(),
    rejectFriendRequestUsecase: sl<RejectFriendRequestUsecase>(),
  ));
  sl.registerFactory(() => SearchCubit(sl<SearchUsersUsecase>()));
  sl.registerFactory(() => IncomingRequestsCubit(sl<WatchIncomingRequestsUsecase>()));
}
