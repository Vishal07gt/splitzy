import 'package:splitzy/features/auth/domain/entities/user_entity.dart';

class UserModel extends User {
  UserModel({required super.id, required super.email, required super.name});

  factory UserModel.fromjson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], email: json['email'], name: json['name']);
  }
}
