import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/features/auth/data/model/user_model.dart';
import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class MockSupabaseUser extends Mock implements supa.User {}

void main() {
  late MockSupabaseUser mockUser;

  setUp(() {
    mockUser = MockSupabaseUser();
    // Stub all getters accessed by UserModel.fromUser
    when(() => mockUser.id).thenReturn('user-id-1');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.userMetadata).thenReturn({'name': 'Test User'});
  });

  group('UserModel direct construction', () {
    test('is a User entity', () {
      final model = UserModel(id: '1', email: 'a@b.com', name: 'Alice');
      expect(model, isA<User>());
    });

    test('fields are accessible', () {
      final model = UserModel(id: '42', email: 'alice@example.com', name: 'Alice');
      expect(model.id, '42');
      expect(model.email, 'alice@example.com');
      expect(model.name, 'Alice');
    });
  });

  group('UserModel.fromjson', () {
    test('maps all fields from JSON', () {
      final json = {'id': 'json-id', 'email': 'json@example.com', 'name': 'JSON User'};
      final model = UserModel.fromjson(json);
      expect(model.id, 'json-id');
      expect(model.email, 'json@example.com');
      expect(model.name, 'JSON User');
    });

    test('handles empty strings in JSON', () {
      final json = {'id': '', 'email': '', 'name': ''};
      final model = UserModel.fromjson(json);
      expect(model.id, '');
      expect(model.email, '');
      expect(model.name, '');
    });
  });

  group('UserModel.fromUser', () {
    test('maps id and email from supa.User', () {
      final model = UserModel.fromUser(mockUser);
      expect(model.id, 'user-id-1');
      expect(model.email, 'test@example.com');
    });

    test('maps name from userMetadata', () {
      final model = UserModel.fromUser(mockUser);
      expect(model.name, 'Test User');
    });

    test('defaults email to empty string when supa.User.email is null', () {
      when(() => mockUser.email).thenReturn(null);
      final model = UserModel.fromUser(mockUser);
      expect(model.email, '');
    });

    test('defaults name to empty string when userMetadata is null', () {
      when(() => mockUser.userMetadata).thenReturn(null);
      final model = UserModel.fromUser(mockUser);
      expect(model.name, '');
    });

    test('defaults name to empty string when name key is missing from userMetadata', () {
      when(() => mockUser.userMetadata).thenReturn({'other_key': 'value'});
      final model = UserModel.fromUser(mockUser);
      expect(model.name, '');
    });
  });
}
