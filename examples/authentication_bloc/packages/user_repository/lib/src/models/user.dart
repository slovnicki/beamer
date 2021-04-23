import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final bool confirmed;
  final bool hasAccess;

  const User({
    required this.id,
    this.confirmed = false,
    this.hasAccess = false,
  });

  @override
  List<Object?> get props => [
        id,
        confirmed,
        hasAccess,
      ];

  static const empty = User(id: '');
}
