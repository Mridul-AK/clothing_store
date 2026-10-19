import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({required super.email, required super.displayName});

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    email: json['email'] as String,
    displayName: json['display_name'] as String,
  );

  Map<String, dynamic> toJson() => {
    'email': email,
    'display_name': displayName,
  };
}
