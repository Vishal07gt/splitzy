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
import 'package:splitzy/features/groups/data/datasource/groups_remote_data_source_impl.dart';
import 'package:splitzy/features/groups/data/repository/groups_repository_impl.dart';
import 'package:splitzy/features/groups/domain/usecases/groups_usecases.dart';
import 'package:splitzy/features/groups/presentation/cubit/group_detail_cubit.dart';
import 'package:splitzy/features/groups/presentation/cubit/groups_cubit.dart';
import 'package:splitzy/features/expenses/data/datasource/expenses_remote_data_source_impl.dart';
import 'package:splitzy/features/expenses/data/repository/expenses_repository_impl.dart';
import 'package:splitzy/features/expenses/domain/usecases/expenses_usecases.dart';
import 'package:splitzy/features/expenses/presentation/cubit/expense_detail_cubit.dart';
import 'package:splitzy/features/expenses/presentation/cubit/expenses_cubit.dart';
import 'package:splitzy/features/settlements/data/datasource/settlements_remote_data_source_impl.dart';
import 'package:splitzy/features/settlements/data/repository/settlements_repository_impl.dart';
import 'package:splitzy/features/settlements/domain/usecases/settlements_usecases.dart';
import 'package:splitzy/features/settlements/presentation/cubit/settlements_cubit.dart';
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

  // ── Groups ──────────────────────────────────────────────────
  sl.registerLazySingleton(() => GroupsRemoteDatasourceImpl(sl<SupabaseClient>()));
  sl.registerLazySingleton(() => GroupsRepositoryImpl(sl<GroupsRemoteDatasourceImpl>()));
  sl.registerLazySingleton(() => GetGroupsUsecase(sl<GroupsRepositoryImpl>()));
  sl.registerLazySingleton(() => GetGroupUsecase(sl<GroupsRepositoryImpl>()));
  sl.registerLazySingleton(() => CreateGroupUsecase(sl<GroupsRepositoryImpl>()));
  sl.registerLazySingleton(() => AddMemberUsecase(sl<GroupsRepositoryImpl>()));
  sl.registerLazySingleton(() => WatchGroupsUsecase(sl<GroupsRepositoryImpl>()));

  sl.registerFactory(() => GroupsCubit(
    getGroupsUsecase: sl<GetGroupsUsecase>(),
    createGroupUsecase: sl<CreateGroupUsecase>(),
  ));
  sl.registerFactory(() => GroupDetailCubit(
    getGroupUsecase: sl<GetGroupUsecase>(),
    addMemberUsecase: sl<AddMemberUsecase>(),
  ));

  // ── Expenses ────────────────────────────────────────────────
  sl.registerLazySingleton(() => ExpensesRemoteDatasourceImpl(sl<SupabaseClient>()));
  sl.registerLazySingleton(() => ExpensesRepositoryImpl(sl<ExpensesRemoteDatasourceImpl>()));
  sl.registerLazySingleton(() => GetGroupExpensesUsecase(sl<ExpensesRepositoryImpl>()));
  sl.registerLazySingleton(() => GetExpenseUsecase(sl<ExpensesRepositoryImpl>()));
  sl.registerLazySingleton(() => CreateExpenseUsecase(sl<ExpensesRepositoryImpl>()));
  sl.registerLazySingleton(() => WatchGroupExpensesUsecase(sl<ExpensesRepositoryImpl>()));

  sl.registerFactory(() => ExpensesCubit(
    getGroupExpensesUsecase: sl<GetGroupExpensesUsecase>(),
    createExpenseUsecase: sl<CreateExpenseUsecase>(),
  ));
  sl.registerFactory(() => ExpenseDetailCubit(
    getExpenseUsecase: sl<GetExpenseUsecase>(),
  ));

  // ── Settlements ─────────────────────────────────────────────
  sl.registerLazySingleton(() => SettlementsRemoteDatasourceImpl(sl<SupabaseClient>()));
  sl.registerLazySingleton(() => SettlementsRepositoryImpl(sl<SettlementsRemoteDatasourceImpl>()));
  sl.registerLazySingleton(() => GetGroupSettlementsUsecase(sl<SettlementsRepositoryImpl>()));
  sl.registerLazySingleton(() => CreateSettlementUsecase(sl<SettlementsRepositoryImpl>()));
  sl.registerLazySingleton(() => WatchGroupSettlementsUsecase(sl<SettlementsRepositoryImpl>()));

  sl.registerFactory(() => SettlementsCubit(
    getGroupSettlementsUsecase: sl<GetGroupSettlementsUsecase>(),
    createSettlementUsecase: sl<CreateSettlementUsecase>(),
  ));
}
