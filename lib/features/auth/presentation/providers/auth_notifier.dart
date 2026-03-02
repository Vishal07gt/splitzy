import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_with_credentials_usecase.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_up_with_credentials_usecase.dart';
import 'package:splitzy/features/auth/data/repository/auth_repository_impl.dart';
import 'package:splitzy/features/auth/data/datasource/auth_remote_data_source_impl.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

part 'auth_notifier.g.dart';

// ── Dependency Providers ──────────────────────────────────────
// These replace get_it — Riverpod handles DI natively

@riverpod
SupabaseClient supabaseClient(SupabaseClientRef ref) {
  return Supabase.instance.client;
}

@riverpod
AuthRemoteDataSourceImpl authRemoteDataSource(AuthRemoteDataSourceRef ref) {
  return AuthRemoteDataSourceImpl(ref.watch(supabaseClientProvider));
}

@riverpod
AuthRepositoryImpl authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));
}

@riverpod
SignUpWithCredentialsUsecase signUpUsecase(SignUpUsecaseRef ref) {
  return SignUpWithCredentialsUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
SignInWithCredentialsUsecase signInUsecase(SignInUsecaseRef ref) {
  return SignInWithCredentialsUsecase(ref.watch(authRepositoryProvider));
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  @override
  AsyncValue<User?> build() {
    ref.listen(supabaseClientProvider, (_, client) {
      client.auth.onAuthStateChange.listen((data) {
        if (data.session != null) {
          final s = data.session!.user;
          state = AsyncValue.data(User(
            id:    s.id,
            email: s.email ?? '',
            name:  s.userMetadata?['name'] ?? '',
          ));
        } else {
          state = const AsyncValue.data(null);
        }
      });
    });

    // Initial state — check if already logged in
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return const AsyncValue.data(null);

    return AsyncValue.data(User(
      id:    session.user.id,
      email: session.user.email ?? '',
      name:  session.user.userMetadata?['name'] ?? '',
    ));
  }

  Future<void> signUpWithCredentials({required SignUpParams params}) async {
    state = const AsyncValue.loading();
    final result = await ref.read(signUpUsecaseProvider).call(params);
    result.fold(
          (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
          (user)    => state = AsyncValue.data(user),
    );
  }

  Future<void> signInWithCredentials({required SignInParams params}) async {
    state = const AsyncValue.loading();
    final result = await ref.read(signInUsecaseProvider).call(params);
    result.fold(
          (failure) => state = AsyncValue.error(failure.message, StackTrace.current),
          (user)    => state = AsyncValue.data(user),
    );
  }

  Future<void> signOut() async {
    await Supabase.instance.client.auth.signOut();
    state = const AsyncValue.data(null);
  }
}