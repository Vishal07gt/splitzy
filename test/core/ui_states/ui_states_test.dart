import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/ui_states/ui_states.dart';

void main() {
  group('DefaultState', () {
    test('is a UiStates', () {
      expect(DefaultState<int>(), isA<UiStates<int>>());
    });

    test('is not Progress', () {
      expect(DefaultState<int>(), isNot(isA<Progress<int>>()));
    });
  });

  group('Progress', () {
    test('is a UiStates', () {
      expect(Progress<String>(), isA<UiStates<String>>());
    });

    test('is not DefaultState', () {
      expect(Progress<int>(), isNot(isA<DefaultState<int>>()));
    });
  });

  group('Success', () {
    test('is a UiStates', () {
      expect(Success<int>(42), isA<UiStates<int>>());
    });

    test('data field returns the int value', () {
      expect(Success<int>(42).data, 42);
    });

    test('data field works with List', () {
      final list = [1, 2, 3];
      expect(Success<List<int>>(list).data, list);
    });

    test('data field works with nullable type', () {
      expect(Success<String?>('hello').data, 'hello');
      expect(Success<String?>(null).data, isNull);
    });

    test('is not Error', () {
      expect(Success<int>(1), isNot(isA<Error<int>>()));
    });
  });

  group('Error', () {
    test('is a UiStates', () {
      expect(Error<int>('something went wrong'), isA<UiStates<int>>());
    });

    test('message field returns the string', () {
      expect(Error<int>('oops').message, 'oops');
    });

    test('is not Success', () {
      expect(Error<int>('fail'), isNot(isA<Success<int>>()));
    });
  });
}
