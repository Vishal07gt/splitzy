import 'package:splitzy/features/auth/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;

class UserModel extends User {
  UserModel({required super.id, required super.email, required super.name});

  factory UserModel.fromjson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], email: json['email'], name: json['name']);
  }

  factory UserModel.fromUser(supa.User user) {
    return UserModel(id: user.id, email: user.email ?? "", name: user.userMetadata?['name'] ?? '');
  }

}
