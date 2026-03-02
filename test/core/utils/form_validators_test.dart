import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/utils/form_validators.dart';

void main() {
  group('FormValidators.required', () {
    test('returns null for a valid string', () {
      expect(FormValidators.required('hello', 'Name'), isNull);
    });

    test('returns null for whitespace-padded valid string', () {
      expect(FormValidators.required('  hello  ', 'Name'), isNull);
    });

    test('returns error message for null', () {
      expect(FormValidators.required(null, 'Name'), 'Name is required');
    });

    test('returns error message for empty string', () {
      expect(FormValidators.required('', 'Email'), 'Email is required');
    });

    test('returns error message for whitespace-only string', () {
      expect(FormValidators.required('   ', 'Field'), 'Field is required');
    });

    test('interpolates fieldName in the message', () {
      expect(
        FormValidators.required(null, 'Phone Number'),
        'Phone Number is required',
      );
    });
  });

  group('FormValidators.email', () {
    test('returns null for a valid email', () {
      expect(FormValidators.email('user@example.com'), isNull);
    });

    test('returns null for email with subdomain', () {
      expect(FormValidators.email('user@mail.example.co'), isNull);
    });

    test('returns error for null', () {
      expect(FormValidators.email(null), 'Email is required');
    });

    test('returns error for empty string', () {
      expect(FormValidators.email(''), 'Email is required');
    });

    test('returns error for whitespace-only string', () {
      expect(FormValidators.email('   '), 'Email is required');
    });

    test('returns invalid email error for missing @', () {
      expect(FormValidators.email('userexample.com'), 'Enter a valid email');
    });

    test('returns invalid email error for missing domain extension', () {
      expect(FormValidators.email('user@example'), 'Enter a valid email');
    });

    test('returns invalid email error for no local part', () {
      expect(FormValidators.email('@example.com'), 'Enter a valid email');
    });
  });

  group('FormValidators.password', () {
    test('returns null for exactly 6 characters', () {
      expect(FormValidators.password('abcdef'), isNull);
    });

    test('returns null for more than 6 characters', () {
      expect(FormValidators.password('abcdefg'), isNull);
    });

    test('returns error for null', () {
      expect(FormValidators.password(null), 'Password is required');
    });

    test('returns error for empty string', () {
      expect(FormValidators.password(''), 'Password is required');
    });

    test('returns required error for whitespace-only (trims before length check)', () {
      expect(FormValidators.password('   '), 'Password is required');
    });

    test('returns too short error for 5 characters', () {
      expect(
        FormValidators.password('abcde'),
        'Password must be at least 6 characters',
      );
    });

    test('returns too short error for 1 character', () {
      expect(
        FormValidators.password('a'),
        'Password must be at least 6 characters',
      );
    });
  });
}
