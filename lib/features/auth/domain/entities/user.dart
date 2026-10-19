import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({required this.email, required this.displayName});

  final String email;
  final String displayName;

  @override
  List<Object?> get props => [email, displayName];
}
