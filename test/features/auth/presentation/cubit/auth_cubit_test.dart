import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:gotrue/gotrue.dart' as gotrue;
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_with_credentials_usecase.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_up_with_credentials_usecase.dart';
import 'package:splitzy/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class MockSignInUsecase extends Mock implements SignInWithCredentialsUsecase {}

class MockSignUpUsecase extends Mock implements SignUpWithCredentialsUsecase {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

// A fake GoTrueClient used by mocktail for fallback values.
class FakeGoTrueClient extends Fake implements GoTrueClient {}

void main() {
  late MockSignInUsecase mockSignInUsecase;
  late MockSignUpUsecase mockSignUpUsecase;
  late MockGoTrueClient mockAuthClient;

  // Minimal gotrue User required by Session constructor.
  const tGoTrueUser = gotrue.User(
    id: 'user-123',
    appMetadata: <String, dynamic>{},
    userMetadata: <String, dynamic>{'name': 'Test User'},
    aud: 'authenticated',
    createdAt: '2021-01-01T00:00:00.000Z',
    email: 'test@example.com',
  );

  final tSession = Session(
    accessToken: 'test-access-token',
    tokenType: 'bearer',
    user: tGoTrueUser,
  );

  const tFailure = ServerFailure(message: 'Auth failed');
  final tUser = User(id: 'uid', email: 'test@example.com', name: 'Test');

  setUpAll(() {
    registerFallbackValue(
        const SignInParams(email: '', password: ''));
    registerFallbackValue(
        const SignUpParams(email: '', password: '', name: ''));
  });

  setUp(() {
    mockSignInUsecase = MockSignInUsecase();
    mockSignUpUsecase = MockSignUpUsecase();
    mockAuthClient = MockGoTrueClient();

    // Default stubs so _initAuthState() succeeds without hitting Supabase.
    when(() => mockAuthClient.currentSession).thenReturn(null);
    when(() => mockAuthClient.onAuthStateChange)
        .thenAnswer((_) => Stream.empty());
  });

  AuthCubit buildCubit() => AuthCubit(
        signUpUsecase: mockSignUpUsecase,
        signInUsecase: mockSignInUsecase,
        authClient: mockAuthClient,
      );

  group('AuthCubit', () {
    // ── Init ────────────────────────────────────────────────────

    test('initial state is DefaultState when no session', () {
      final cubit = buildCubit();
      expect(cubit.state, isA<DefaultState<User?>>());
      cubit.close();
    });

    test('initial state is Success when currentSession exists', () {
      when(() => mockAuthClient.currentSession).thenReturn(tSession);

      final cubit = buildCubit();

      expect(cubit.state, isA<Success<User?>>());
      expect((cubit.state as Success<User?>).data?.id, 'user-123');
      cubit.close();
    });

    // ── onAuthStateChange stream ─────────────────────────────────

    test('emits Success when onAuthStateChange fires with session', () async {
      final controller = StreamController<AuthState>();
      when(() => mockAuthClient.onAuthStateChange)
          .thenAnswer((_) => controller.stream);

      final cubit = buildCubit();
      expect(cubit.state, isA<DefaultState<User?>>());

      controller.add(AuthState(AuthChangeEvent.signedIn, tSession));
      await Future.delayed(Duration.zero);

      expect(cubit.state, isA<Success<User?>>());
      expect((cubit.state as Success<User?>).data?.id, 'user-123');

      await controller.close();
      await cubit.close();
    });

    test('emits DefaultState when onAuthStateChange fires without session',
        () async {
      final controller = StreamController<AuthState>();
      when(() => mockAuthClient.onAuthStateChange)
          .thenAnswer((_) => controller.stream);

      final cubit = buildCubit();

      controller.add(const AuthState(AuthChangeEvent.signedOut, null));
      await Future.delayed(Duration.zero);

      expect(cubit.state, isA<DefaultState<User?>>());

      await controller.close();
      await cubit.close();
    });

    // ── signIn ───────────────────────────────────────────────────

    blocTest<AuthCubit, UiStates<User?>>(
      'signIn emits [Progress, Success] on usecase Right',
      setUp: () {
        when(() => mockSignInUsecase.call(any()))
            .thenAnswer((_) async => Right(tUser));
      },
      build: () => buildCubit(),
      act: (cubit) => cubit.signIn(
        const SignInParams(email: 'test@example.com', password: 'pass123'),
      ),
      expect: () => [isA<Progress<User?>>(), isA<Success<User?>>()],
    );

    blocTest<AuthCubit, UiStates<User?>>(
      'signIn emits [Progress, Error] on usecase Left',
      setUp: () {
        when(() => mockSignInUsecase.call(any()))
            .thenAnswer((_) async => const Left(tFailure));
      },
      build: () => buildCubit(),
      act: (cubit) => cubit.signIn(
        const SignInParams(email: 'test@example.com', password: 'wrong'),
      ),
      expect: () => [isA<Progress<User?>>(), isA<Error<User?>>()],
    );

    // ── signUp ───────────────────────────────────────────────────

    blocTest<AuthCubit, UiStates<User?>>(
      'signUp emits [Progress, Success] on usecase Right',
      setUp: () {
        when(() => mockSignUpUsecase.call(any()))
            .thenAnswer((_) async => Right(tUser));
      },
      build: () => buildCubit(),
      act: (cubit) => cubit.signUp(
        const SignUpParams(
          email: 'test@example.com',
          password: 'pass123',
          name: 'Test User',
        ),
      ),
      expect: () => [isA<Progress<User?>>(), isA<Success<User?>>()],
    );

    blocTest<AuthCubit, UiStates<User?>>(
      'signUp emits [Progress, Error] on usecase Left',
      setUp: () {
        when(() => mockSignUpUsecase.call(any()))
            .thenAnswer((_) async => const Left(tFailure));
      },
      build: () => buildCubit(),
      act: (cubit) => cubit.signUp(
        const SignUpParams(
          email: 'test@example.com',
          password: 'short',
          name: 'Test',
        ),
      ),
      expect: () => [isA<Progress<User?>>(), isA<Error<User?>>()],
    );

    // ── signOut ──────────────────────────────────────────────────

    test('signOut calls authClient.signOut and emits DefaultState', () async {
      when(() => mockAuthClient.signOut()).thenAnswer((_) async {});

      final cubit = buildCubit();
      await cubit.signOut();

      verify(() => mockAuthClient.signOut()).called(1);
      expect(cubit.state, isA<DefaultState<User?>>());
      await cubit.close();
    });
  });
}
