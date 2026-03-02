import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/auth/domain/repository/auth_repository.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_with_credentials_usecase.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_up_with_credentials_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepo;
  late SignUpWithCredentialsUsecase signUpUsecase;
  late SignInWithCredentialsUsecase signInUsecase;

  final tUser = User(id: 'user1', email: 'alice@example.com', name: 'Alice');
  const tFailure = ServerFailure(message: 'Auth failed');

  setUp(() {
    mockRepo = MockAuthRepository();
    signUpUsecase = SignUpWithCredentialsUsecase(mockRepo);
    signInUsecase = SignInWithCredentialsUsecase(mockRepo);
  });

  // ── SignUpWithCredentialsUsecase ──────────────────────────────────

  group('SignUpWithCredentialsUsecase', () {
    const tParams = SignUpParams(
      email: 'alice@example.com',
      password: 'password123',
      name: 'Alice',
    );

    test('calls repo.signUpWithCredentials with the correct params', () async {
      when(() => mockRepo.signUpWithCredentials(params: tParams))
          .thenAnswer((_) async => Right(tUser));

      await signUpUsecase(tParams);

      verify(() => mockRepo.signUpWithCredentials(params: tParams)).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns Right(user) on success', () async {
      when(() => mockRepo.signUpWithCredentials(params: tParams))
          .thenAnswer((_) async => Right(tUser));

      final result = await signUpUsecase(tParams);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('expected Right'),
        (user) {
          expect(user.id, tUser.id);
          expect(user.email, tUser.email);
          expect(user.name, tUser.name);
        },
      );
    });

    test('returns Left(failure) on error', () async {
      when(() => mockRepo.signUpWithCredentials(params: tParams))
          .thenAnswer((_) async => const Left(tFailure));

      final result = await signUpUsecase(tParams);

      expect(result, const Left(tFailure));
    });
  });

  // ── SignInWithCredentialsUsecase ──────────────────────────────────

  group('SignInWithCredentialsUsecase', () {
    const tParams = SignInParams(
      email: 'alice@example.com',
      password: 'password123',
    );

    test('calls repo.signInWithCredentials with the correct params', () async {
      when(() => mockRepo.signInWithCredentials(params: tParams))
          .thenAnswer((_) async => Right(tUser));

      await signInUsecase(tParams);

      verify(() => mockRepo.signInWithCredentials(params: tParams)).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns Right(user) on success', () async {
      when(() => mockRepo.signInWithCredentials(params: tParams))
          .thenAnswer((_) async => Right(tUser));

      final result = await signInUsecase(tParams);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('expected Right'),
        (user) {
          expect(user.id, tUser.id);
          expect(user.email, tUser.email);
          expect(user.name, tUser.name);
        },
      );
    });

    test('returns Left(failure) on error', () async {
      when(() => mockRepo.signInWithCredentials(params: tParams))
          .thenAnswer((_) async => const Left(tFailure));

      final result = await signInUsecase(tParams);

      expect(result, const Left(tFailure));
    });
  });
}
