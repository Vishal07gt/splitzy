import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/core/usecases/usecase.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/friends/domain/entities/friend_entity.dart';
import 'package:splitzy/features/friends/domain/entities/friend_request_entity.dart';
import 'package:splitzy/features/friends/domain/repository/friends_repository.dart';
import 'package:splitzy/features/friends/domain/usecases/friends_usecases.dart';

class MockFriendsRepository extends Mock implements FriendsRepository {}

void main() {
  late MockFriendsRepository mockRepo;
  late SearchUsersUsecase searchUsersUsecase;
  late SendFriendRequestUsecase sendFriendRequestUsecase;
  late AcceptFriendRequestUsecase acceptFriendRequestUsecase;
  late RejectFriendRequestUsecase rejectFriendRequestUsecase;
  late GetFriendsUsecase getFriendsUsecase;
  late WatchIncomingRequestsUsecase watchIncomingRequestsUsecase;

  // Shared test data
  final tUser = User(id: 'user1', email: 'alice@example.com', name: 'Alice');
  final tOtherUser = User(id: 'user2', email: 'bob@example.com', name: 'Bob');
  const tFailure = ServerFailure(message: 'Something went wrong');

  setUp(() {
    mockRepo = MockFriendsRepository();
    searchUsersUsecase = SearchUsersUsecase(mockRepo);
    sendFriendRequestUsecase = SendFriendRequestUsecase(mockRepo);
    acceptFriendRequestUsecase = AcceptFriendRequestUsecase(mockRepo);
    rejectFriendRequestUsecase = RejectFriendRequestUsecase(mockRepo);
    getFriendsUsecase = GetFriendsUsecase(mockRepo);
    watchIncomingRequestsUsecase = WatchIncomingRequestsUsecase(mockRepo);
  });

  // ── SearchUsersUsecase ──────────────────────────────────────────

  group('SearchUsersUsecase', () {
    const tQuery = 'alice';
    final tParams = SearchUsersParams(query: tQuery);

    test('calls repo.searchUsers with the correct query', () async {
      when(() => mockRepo.searchUsers(tQuery))
          .thenAnswer((_) async => Right([tUser]));

      await searchUsersUsecase(tParams);

      verify(() => mockRepo.searchUsers(tQuery)).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns Right(users) on success', () async {
      final tUsers = [tUser];
      when(() => mockRepo.searchUsers(tQuery))
          .thenAnswer((_) async => Right(tUsers));

      final result = await searchUsersUsecase(tParams);

      expect(result.isRight(), true);
      result.fold((_) => fail('expected Right'), (users) {
        expect(users, tUsers);
      });
    });

    test('returns Left(failure) on error', () async {
      when(() => mockRepo.searchUsers(tQuery))
          .thenAnswer((_) async => const Left(tFailure));

      final result = await searchUsersUsecase(tParams);

      expect(result, const Left(tFailure));
    });
  });

  // ── SendFriendRequestUsecase ────────────────────────────────────

  group('SendFriendRequestUsecase', () {
    const tAddresseeId = 'user2';
    final tParams = SendFriendRequestParams(addresseeId: tAddresseeId);

    test('calls repo.sendFriendRequest with the correct addresseeId', () async {
      when(() => mockRepo.sendFriendRequest(tAddresseeId))
          .thenAnswer((_) async => const Right(null));

      await sendFriendRequestUsecase(tParams);

      verify(() => mockRepo.sendFriendRequest(tAddresseeId)).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns Right on success', () async {
      when(() => mockRepo.sendFriendRequest(tAddresseeId))
          .thenAnswer((_) async => const Right(null));

      final result = await sendFriendRequestUsecase(tParams);

      expect(result.isRight(), true);
    });

    test('returns Left(failure) on error', () async {
      when(() => mockRepo.sendFriendRequest(tAddresseeId))
          .thenAnswer((_) async => const Left(tFailure));

      final result = await sendFriendRequestUsecase(tParams);

      expect(result, const Left(tFailure));
    });
  });

  // ── AcceptFriendRequestUsecase ──────────────────────────────────

  group('AcceptFriendRequestUsecase', () {
    const tFriendshipId = 'friendship1';
    final tParams = FriendRequestActionParams(friendshipId: tFriendshipId);

    test('calls repo.acceptFriendRequest with the correct friendshipId',
        () async {
      when(() => mockRepo.acceptFriendRequest(tFriendshipId))
          .thenAnswer((_) async => const Right(null));

      await acceptFriendRequestUsecase(tParams);

      verify(() => mockRepo.acceptFriendRequest(tFriendshipId)).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns Right on success', () async {
      when(() => mockRepo.acceptFriendRequest(tFriendshipId))
          .thenAnswer((_) async => const Right(null));

      final result = await acceptFriendRequestUsecase(tParams);

      expect(result.isRight(), true);
    });

    test('returns Left(failure) on error', () async {
      when(() => mockRepo.acceptFriendRequest(tFriendshipId))
          .thenAnswer((_) async => const Left(tFailure));

      final result = await acceptFriendRequestUsecase(tParams);

      expect(result, const Left(tFailure));
    });
  });

  // ── RejectFriendRequestUsecase ──────────────────────────────────

  group('RejectFriendRequestUsecase', () {
    const tFriendshipId = 'friendship1';
    final tParams = FriendRequestActionParams(friendshipId: tFriendshipId);

    test('calls repo.rejectFriendRequest with the correct friendshipId',
        () async {
      when(() => mockRepo.rejectFriendRequest(tFriendshipId))
          .thenAnswer((_) async => const Right(null));

      await rejectFriendRequestUsecase(tParams);

      verify(() => mockRepo.rejectFriendRequest(tFriendshipId)).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns Right on success', () async {
      when(() => mockRepo.rejectFriendRequest(tFriendshipId))
          .thenAnswer((_) async => const Right(null));

      final result = await rejectFriendRequestUsecase(tParams);

      expect(result.isRight(), true);
    });

    test('returns Left(failure) on error', () async {
      when(() => mockRepo.rejectFriendRequest(tFriendshipId))
          .thenAnswer((_) async => const Left(tFailure));

      final result = await rejectFriendRequestUsecase(tParams);

      expect(result, const Left(tFailure));
    });
  });

  // ── GetFriendsUsecase ───────────────────────────────────────────

  group('GetFriendsUsecase', () {
    final tFriend = FriendEntity(
      friendshipId: 'friendship1',
      friend: tUser,
      source: FriendSource.manual,
      since: DateTime(2024, 1, 1),
    );
    final tFriends = [tFriend];

    test('calls repo.getFriends', () async {
      when(() => mockRepo.getFriends())
          .thenAnswer((_) async => Right(tFriends));

      await getFriendsUsecase(NoParams());

      verify(() => mockRepo.getFriends()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns Right(friends) on success', () async {
      when(() => mockRepo.getFriends())
          .thenAnswer((_) async => Right(tFriends));

      final result = await getFriendsUsecase(NoParams());

      expect(result.isRight(), true);
      result.fold((_) => fail('expected Right'), (friends) {
        expect(friends, tFriends);
      });
    });

    test('returns Left(failure) on error', () async {
      when(() => mockRepo.getFriends())
          .thenAnswer((_) async => const Left(tFailure));

      final result = await getFriendsUsecase(NoParams());

      expect(result, const Left(tFailure));
    });
  });

  // ── WatchIncomingRequestsUsecase ────────────────────────────────

  group('WatchIncomingRequestsUsecase', () {
    final tRequest = FriendRequestEntity(
      id: 'req1',
      requester: tUser,
      addressee: tOtherUser,
      status: FriendRequestStatus.pending,
      createdAt: DateTime(2024, 6, 1),
    );
    final tRequests = [tRequest];

    test('emits Right(requests) from the repository stream', () async {
      when(() => mockRepo.watchIncomingRequests())
          .thenAnswer((_) => Stream.fromIterable([Right(tRequests)]));

      final stream = watchIncomingRequestsUsecase.call();

      await expectLater(
        stream,
        emits(predicate<Either<Failure, List<FriendRequestEntity>>>(
          (e) => e.isRight(),
          'is Right',
        )),
      );
      verify(() => mockRepo.watchIncomingRequests()).called(1);
    });

    test('emits Left(failure) when the stream yields an error', () async {
      when(() => mockRepo.watchIncomingRequests())
          .thenAnswer((_) => Stream.fromIterable([const Left(tFailure)]));

      final stream = watchIncomingRequestsUsecase.call();

      await expectLater(stream, emits(const Left(tFailure)));
    });

    test('emits multiple events in order', () async {
      when(() => mockRepo.watchIncomingRequests()).thenAnswer((_) =>
          Stream.fromIterable([
            Right(tRequests),
            const Left(tFailure),
          ]));

      final stream = watchIncomingRequestsUsecase.call();

      await expectLater(
        stream,
        emitsInOrder([
          predicate<Either<Failure, List<FriendRequestEntity>>>(
              (e) => e.isRight()),
          const Left(tFailure),
        ]),
      );
    });
  });

  // ── Params Equality ─────────────────────────────────────────────

  group('SearchUsersParams', () {
    test('equal when query matches', () {
      expect(
        const SearchUsersParams(query: 'john'),
        const SearchUsersParams(query: 'john'),
      );
    });

    test('not equal when query differs', () {
      expect(
        const SearchUsersParams(query: 'john'),
        isNot(const SearchUsersParams(query: 'jane')),
      );
    });

    test('props exposes query', () {
      expect(const SearchUsersParams(query: 'alice').props, ['alice']);
    });
  });

  group('SendFriendRequestParams', () {
    test('equal when addresseeId matches', () {
      expect(
        const SendFriendRequestParams(addresseeId: 'abc'),
        const SendFriendRequestParams(addresseeId: 'abc'),
      );
    });

    test('not equal when addresseeId differs', () {
      expect(
        const SendFriendRequestParams(addresseeId: 'abc'),
        isNot(const SendFriendRequestParams(addresseeId: 'xyz')),
      );
    });

    test('props exposes addresseeId', () {
      expect(
          const SendFriendRequestParams(addresseeId: 'uid').props, ['uid']);
    });
  });

  group('FriendRequestActionParams', () {
    test('equal when friendshipId matches', () {
      expect(
        const FriendRequestActionParams(friendshipId: 'f1'),
        const FriendRequestActionParams(friendshipId: 'f1'),
      );
    });

    test('not equal when friendshipId differs', () {
      expect(
        const FriendRequestActionParams(friendshipId: 'f1'),
        isNot(const FriendRequestActionParams(friendshipId: 'f2')),
      );
    });

    test('props exposes friendshipId', () {
      expect(
          const FriendRequestActionParams(friendshipId: 'fid').props, ['fid']);
    });
  });
}
