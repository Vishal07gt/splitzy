import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/features/auth/data/datasource/auth_remote_data_source.dart';
import 'package:splitzy/features/auth/data/model/user_model.dart';
import 'package:splitzy/features/auth/data/repository/auth_repository_impl.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_with_credentials_usecase.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_up_with_credentials_usecase.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource mockDataSource;
  late AuthRepositoryImpl repository;

  final tUserModel = UserModel(
    id: 'user1',
    email: 'alice@example.com',
    name: 'Alice',
  );

  setUp(() {
    mockDataSource = MockAuthRemoteDataSource();
    repository = AuthRepositoryImpl(mockDataSource);
  });

  // ── signUpWithCredentials ─────────────────────────────────────────

  group('signUpWithCredentials', () {
    const tParams = SignUpParams(
      email: 'alice@example.com',
      password: 'password123',
      name: 'Alice',
    );

    test('delegates to data source with correct params', () async {
      when(() => mockDataSource.signUpWithCredentials(params: tParams))
          .thenAnswer((_) async => tUserModel);

      await repository.signUpWithCredentials(params: tParams);

      verify(() => mockDataSource.signUpWithCredentials(params: tParams)).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });

    test('returns Right(user) when data source succeeds', () async {
      when(() => mockDataSource.signUpWithCredentials(params: tParams))
          .thenAnswer((_) async => tUserModel);

      final result = await repository.signUpWithCredentials(params: tParams);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('expected Right'),
        (user) {
          expect(user.id, tUserModel.id);
          expect(user.email, tUserModel.email);
          expect(user.name, tUserModel.name);
        },
      );
    });

    test('returns Left(Failure) when data source throws Exception', () async {
      when(() => mockDataSource.signUpWithCredentials(params: tParams))
          .thenThrow(Exception('Auth failed'));

      final result = await repository.signUpWithCredentials(params: tParams);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
          expect(failure.message, 'Exception: Auth failed');
        },
        (_) => fail('expected Left'),
      );
    });

    test('returns Left(Failure) when data source throws StateError', () async {
      when(() => mockDataSource.signUpWithCredentials(params: tParams))
          .thenThrow(StateError('bad state'));

      final result = await repository.signUpWithCredentials(params: tParams);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('expected Left'),
      );
    });
  });

  // ── signInWithCredentials ─────────────────────────────────────────

  group('signInWithCredentials', () {
    const tParams = SignInParams(
      email: 'alice@example.com',
      password: 'password123',
    );

    test('delegates to data source with correct params', () async {
      when(() => mockDataSource.signInWithCredentials(params: tParams))
          .thenAnswer((_) async => tUserModel);

      await repository.signInWithCredentials(params: tParams);

      verify(() => mockDataSource.signInWithCredentials(params: tParams)).called(1);
      verifyNoMoreInteractions(mockDataSource);
    });

    test('returns Right(user) when data source succeeds', () async {
      when(() => mockDataSource.signInWithCredentials(params: tParams))
          .thenAnswer((_) async => tUserModel);

      final result = await repository.signInWithCredentials(params: tParams);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('expected Right'),
        (user) {
          expect(user.id, tUserModel.id);
          expect(user.email, tUserModel.email);
          expect(user.name, tUserModel.name);
        },
      );
    });

    test('returns Left(Failure) when data source throws Exception', () async {
      when(() => mockDataSource.signInWithCredentials(params: tParams))
          .thenThrow(Exception('Auth failed'));

      final result = await repository.signInWithCredentials(params: tParams);

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<Failure>());
          expect(failure.message, 'Exception: Auth failed');
        },
        (_) => fail('expected Left'),
      );
    });

    test('returns Left(Failure) when data source throws StateError', () async {
      when(() => mockDataSource.signInWithCredentials(params: tParams))
          .thenThrow(StateError('bad state'));

      final result = await repository.signInWithCredentials(params: tParams);

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<Failure>()),
        (_) => fail('expected Left'),
      );
    });
  });
}
