import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/errors.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:splitzy/features/friends/domain/entities/friend_request_entity.dart';
import 'package:splitzy/features/friends/domain/usecases/friends_usecases.dart';
import 'package:splitzy/features/friends/presentation/cubit/incoming_requests_cubit.dart';

class MockWatchIncomingRequestsUsecase extends Mock
    implements WatchIncomingRequestsUsecase {}

void main() {
  late MockWatchIncomingRequestsUsecase mockWatchUsecase;
  late StreamController<Either<Failure, List<FriendRequestEntity>>>
      streamController;

  final tRequester =
      User(id: 'user-1', email: 'alice@example.com', name: 'Alice');
  final tAddressee =
      User(id: 'user-2', email: 'bob@example.com', name: 'Bob');
  final tRequest = FriendRequestEntity(
    id: 'req-1',
    requester: tRequester,
    addressee: tAddressee,
    status: FriendRequestStatus.pending,
    createdAt: DateTime(2024, 1, 1),
  );

  const tFailure = ServerFailure(message: 'Watch failed');

  setUp(() {
    mockWatchUsecase = MockWatchIncomingRequestsUsecase();
    streamController = StreamController<Either<Failure, List<FriendRequestEntity>>>();
    when(() => mockWatchUsecase.call()).thenAnswer((_) => streamController.stream);
  });

  tearDown(() async {
    await streamController.close();
  });

  IncomingRequestsCubit buildCubit() =>
      IncomingRequestsCubit(mockWatchUsecase);

  group('IncomingRequestsCubit', () {
    test('initial state is DefaultState', () {
      final cubit = buildCubit();
      expect(cubit.state, isA<DefaultState<List<FriendRequestEntity>>>());
      cubit.close();
    });

    test('emits Success when stream yields Right(requests)', () async {
      final cubit = buildCubit();

      streamController.add(Right([tRequest]));
      await Future.delayed(Duration.zero);

      expect(cubit.state, isA<Success<List<FriendRequestEntity>>>());
      expect(
        (cubit.state as Success<List<FriendRequestEntity>>).data,
        [tRequest],
      );
      await cubit.close();
    });

    test('emits Error when stream yields Left(failure)', () async {
      final cubit = buildCubit();

      streamController.add(const Left(tFailure));
      await Future.delayed(Duration.zero);

      expect(cubit.state, isA<Error<List<FriendRequestEntity>>>());
      expect(
        (cubit.state as Error<List<FriendRequestEntity>>).message,
        tFailure.message,
      );
      await cubit.close();
    });

    test('emits multiple states as stream emits multiple events', () async {
      final cubit = buildCubit();

      final states = <UiStates<List<FriendRequestEntity>>>[];
      final sub = cubit.stream.listen(states.add);

      streamController.add(Right([tRequest]));
      await Future.delayed(Duration.zero);
      streamController.add(const Left(tFailure));
      await Future.delayed(Duration.zero);
      streamController.add(Right([]));
      await Future.delayed(Duration.zero);

      await sub.cancel();
      await cubit.close();

      expect(states, [
        isA<Success<List<FriendRequestEntity>>>(),
        isA<Error<List<FriendRequestEntity>>>(),
        isA<Success<List<FriendRequestEntity>>>(),
      ]);
    });
  });
}
