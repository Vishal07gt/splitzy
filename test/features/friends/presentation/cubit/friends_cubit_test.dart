import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/core/usecases/usecase.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/friends/domain/entities/friend_entity.dart';
import 'package:splitzy/features/friends/domain/usecases/friends_usecases.dart';
import 'package:splitzy/features/friends/presentation/cubit/friends_cubit.dart';

class MockGetFriendsUsecase extends Mock implements GetFriendsUsecase {}

class MockSendFriendRequestUsecase extends Mock
    implements SendFriendRequestUsecase {}

class MockAcceptFriendRequestUsecase extends Mock
    implements AcceptFriendRequestUsecase {}

class MockRejectFriendRequestUsecase extends Mock
    implements RejectFriendRequestUsecase {}

void main() {
  late MockGetFriendsUsecase mockGetFriendsUsecase;
  late MockSendFriendRequestUsecase mockSendFriendRequestUsecase;
  late MockAcceptFriendRequestUsecase mockAcceptFriendRequestUsecase;
  late MockRejectFriendRequestUsecase mockRejectFriendRequestUsecase;

  final tUser = User(id: 'user-1', email: 'alice@example.com', name: 'Alice');
  final tFriend = FriendEntity(
    friendshipId: 'f-1',
    friend: tUser,
    source: FriendSource.manual,
    since: DateTime(2024, 1, 1),
  );

  const tFailure = ServerFailure(message: 'Something went wrong');

  setUp(() {
    mockGetFriendsUsecase = MockGetFriendsUsecase();
    mockSendFriendRequestUsecase = MockSendFriendRequestUsecase();
    mockAcceptFriendRequestUsecase = MockAcceptFriendRequestUsecase();
    mockRejectFriendRequestUsecase = MockRejectFriendRequestUsecase();

    registerFallbackValue(NoParams());
    registerFallbackValue(
        const SendFriendRequestParams(addresseeId: 'fallback'));
    registerFallbackValue(
        const FriendRequestActionParams(friendshipId: 'fallback'));
  });

  FriendsCubit buildCubit() => FriendsCubit(
        getFriendsUsecase: mockGetFriendsUsecase,
        sendFriendRequestUsecase: mockSendFriendRequestUsecase,
        acceptFriendRequestUsecase: mockAcceptFriendRequestUsecase,
        rejectFriendRequestUsecase: mockRejectFriendRequestUsecase,
      );

  group('FriendsCubit', () {
    // ── Init (constructor calls loadFriends) ─────────────────────

    test('state is Success after init when loadFriends succeeds', () async {
      when(() => mockGetFriendsUsecase.call(any()))
          .thenAnswer((_) async => Right([tFriend]));

      final cubit = buildCubit();
      await Future.delayed(Duration.zero);

      expect(cubit.state, isA<Success<List<FriendEntity>>>());
      expect((cubit.state as Success<List<FriendEntity>>).data, [tFriend]);
      await cubit.close();
    });

    test('state is Error after init when loadFriends fails', () async {
      when(() => mockGetFriendsUsecase.call(any()))
          .thenAnswer((_) async => const Left(tFailure));

      final cubit = buildCubit();
      await Future.delayed(Duration.zero);

      expect(cubit.state, isA<Error<List<FriendEntity>>>());
      expect((cubit.state as Error<List<FriendEntity>>).message,
          tFailure.message);
      await cubit.close();
    });

    // ── loadFriends (explicit call) ──────────────────────────────

    test('loadFriends emits [Progress, Success] on success', () async {
      when(() => mockGetFriendsUsecase.call(any()))
          .thenAnswer((_) async => Right([tFriend]));

      final cubit = buildCubit();
      await Future.delayed(Duration.zero); // let constructor's load settle

      final states = <UiStates<List<FriendEntity>>>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.loadFriends();
      await Future.delayed(Duration.zero); // drain async stream queue

      await sub.cancel();
      await cubit.close();

      expect(states, [
        isA<Progress<List<FriendEntity>>>(),
        isA<Success<List<FriendEntity>>>(),
      ]);
    });

    test('loadFriends emits [Progress, Error] on failure', () async {
      when(() => mockGetFriendsUsecase.call(any()))
          .thenAnswer((_) async => const Left(tFailure));

      final cubit = buildCubit();
      await Future.delayed(Duration.zero);

      final states = <UiStates<List<FriendEntity>>>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.loadFriends();
      await Future.delayed(Duration.zero); // drain async stream queue

      await sub.cancel();
      await cubit.close();

      expect(states, [
        isA<Progress<List<FriendEntity>>>(),
        isA<Error<List<FriendEntity>>>(),
      ]);
    });

    // ── sendRequest ──────────────────────────────────────────────

    test('sendRequest calls usecase with correct addresseeId', () async {
      when(() => mockGetFriendsUsecase.call(any()))
          .thenAnswer((_) async => Right([]));
      when(() => mockSendFriendRequestUsecase.call(any()))
          .thenAnswer((_) async => const Right(null));

      final cubit = buildCubit();
      await Future.delayed(Duration.zero);

      await cubit.sendRequest('user-2');

      verify(() => mockSendFriendRequestUsecase
              .call(const SendFriendRequestParams(addresseeId: 'user-2')))
          .called(1);
      await cubit.close();
    });

    // ── acceptRequest ─────────────────────────────────────────────

    test('acceptRequest calls loadFriends on success', () async {
      when(() => mockGetFriendsUsecase.call(any()))
          .thenAnswer((_) async => Right([tFriend]));
      when(() => mockAcceptFriendRequestUsecase.call(any()))
          .thenAnswer((_) async => const Right(null));

      final cubit = buildCubit();
      await Future.delayed(Duration.zero);

      await cubit.acceptRequest('f-1');
      // acceptRequest calls loadFriends() without awaiting it, so give it
      // time to complete before verifying.
      await Future.delayed(const Duration(milliseconds: 50));

      // getFriendsUsecase: once from constructor, once from acceptRequest
      verify(() => mockGetFriendsUsecase.call(any())).called(2);
      await cubit.close();
    });

    test('acceptRequest emits Error on failure', () async {
      when(() => mockGetFriendsUsecase.call(any()))
          .thenAnswer((_) async => Right([]));
      when(() => mockAcceptFriendRequestUsecase.call(any()))
          .thenAnswer((_) async => const Left(tFailure));

      final cubit = buildCubit();
      await Future.delayed(Duration.zero);

      final states = <UiStates<List<FriendEntity>>>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.acceptRequest('f-1');
      await Future.delayed(Duration.zero); // drain async stream queue

      await sub.cancel();
      await cubit.close();

      expect(states, [isA<Error<List<FriendEntity>>>()]);
    });
  });
}
