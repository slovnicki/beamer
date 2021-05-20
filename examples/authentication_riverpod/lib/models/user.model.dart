import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String token;
  final String username;

  const UserModel({required this.token, required this.username});

  @override
  List<Object> get props => [token, username];

  @override
  String toString() => "username: $username, token: $token";

  static const empty = UserModel(token: "-", username: "-");
}
