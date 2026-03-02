import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/friends/domain/usecases/friends_usecases.dart';
import 'package:splitzy/features/friends/presentation/cubit/search_cubit.dart';

class MockSearchUsersUsecase extends Mock implements SearchUsersUsecase {}

void main() {
  late MockSearchUsersUsecase mockSearchUsersUsecase;

  final tUser = User(id: 'user-1', email: 'alice@example.com', name: 'Alice');
  const tFailure = ServerFailure(message: 'Search failed');

  setUp(() {
    mockSearchUsersUsecase = MockSearchUsersUsecase();
    registerFallbackValue(const SearchUsersParams(query: ''));
  });

  SearchCubit buildCubit() => SearchCubit(mockSearchUsersUsecase);

  group('SearchCubit', () {
    test('initial state is Success with empty list', () {
      final cubit = buildCubit();
      expect(cubit.state, isA<Success<List<User>>>());
      expect((cubit.state as Success<List<User>>).data, isEmpty);
      cubit.close();
    });

    blocTest<SearchCubit, UiStates<List<User>>>(
      'search with blank query emits Success([])',
      build: () => buildCubit(),
      act: (cubit) => cubit.search('   '),
      expect: () => [
        predicate<UiStates<List<User>>>(
          (s) => s is Success<List<User>> && s.data.isEmpty,
          'Success with empty list',
        ),
      ],
    );

    blocTest<SearchCubit, UiStates<List<User>>>(
      'search with query emits [Progress, Success] on usecase Right',
      setUp: () {
        when(() => mockSearchUsersUsecase.call(any()))
            .thenAnswer((_) async => Right([tUser]));
      },
      build: () => buildCubit(),
      act: (cubit) => cubit.search('alice'),
      expect: () => [isA<Progress<List<User>>>(), isA<Success<List<User>>>()],
    );

    blocTest<SearchCubit, UiStates<List<User>>>(
      'search with query emits [Progress, Error] on usecase Left',
      setUp: () {
        when(() => mockSearchUsersUsecase.call(any()))
            .thenAnswer((_) async => const Left(tFailure));
      },
      build: () => buildCubit(),
      act: (cubit) => cubit.search('alice'),
      expect: () => [isA<Progress<List<User>>>(), isA<Error<List<User>>>()],
    );

    blocTest<SearchCubit, UiStates<List<User>>>(
      'clear emits Success([])',
      build: () => buildCubit(),
      act: (cubit) => cubit.clear(),
      expect: () => [
        predicate<UiStates<List<User>>>(
          (s) => s is Success<List<User>> && s.data.isEmpty,
          'Success with empty list',
        ),
      ],
    );
  });
}
