import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/errors.dart';

void main() {
  group('Failure', () {
    test('equality — same message', () {
      expect(
        const Failure(message: 'error'),
        const Failure(message: 'error'),
      );
    });

    test('inequality — different message', () {
      expect(
        const Failure(message: 'error'),
        isNot(const Failure(message: 'other')),
      );
    });

    test('props exposes message', () {
      expect(const Failure(message: 'oops').props, ['oops']);
    });

    test('message field is accessible', () {
      const f = Failure(message: 'test message');
      expect(f.message, 'test message');
    });
  });

  group('NetWorkFailure', () {
    test('is a Failure', () {
      expect(const NetWorkFailure(message: 'no network'), isA<Failure>());
    });

    test('equality — same message', () {
      expect(
        const NetWorkFailure(message: 'no network'),
        const NetWorkFailure(message: 'no network'),
      );
    });

    test('inequality — different message', () {
      expect(
        const NetWorkFailure(message: 'no network'),
        isNot(const NetWorkFailure(message: 'timeout')),
      );
    });

    test('cross-type inequality — vs Failure with same message', () {
      expect(
        const NetWorkFailure(message: 'x'),
        isNot(const Failure(message: 'x')),
      );
    });
  });

  group('ServerFailure', () {
    test('is a Failure', () {
      expect(const ServerFailure(message: 'server error'), isA<Failure>());
    });

    test('equality — same message', () {
      expect(
        const ServerFailure(message: 'server error'),
        const ServerFailure(message: 'server error'),
      );
    });

    test('inequality — different message', () {
      expect(
        const ServerFailure(message: 'server error'),
        isNot(const ServerFailure(message: 'other')),
      );
    });

    test('cross-type inequality — vs Failure with same message', () {
      expect(
        const ServerFailure(message: 'x'),
        isNot(const Failure(message: 'x')),
      );
    });

    test('cross-type inequality — vs NetWorkFailure with same message', () {
      expect(
        const ServerFailure(message: 'x'),
        isNot(const NetWorkFailure(message: 'x')),
      );
    });
  });
}
