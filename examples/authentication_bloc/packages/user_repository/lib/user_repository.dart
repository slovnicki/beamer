import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';

class UserRepository {
  User? _user;

  Future<User?> getUser() async {
    if (_user != null) return _user;
    return Future.delayed(
      const Duration(milliseconds: 250),
      () => _user = User(
        id: const Uuid().v4(),
      ),
    );
  }
}

class User extends Equatable {
  final String id;
  // final String email;
  final bool confirmed;
  final bool hasAccess;

  const User({
    required this.id,
    // required this.email,
    this.confirmed = false,
    this.hasAccess = false,
  });

  @override
  List<Object?> get props => [
        // email,
        id,
        confirmed,
        hasAccess,
      ];

  static const empty = User(id: '');
}
