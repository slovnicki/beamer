import 'dart:async';

import 'package:authentication_repository/authentication_repository.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:user_repository/user_repository.dart';
import 'package:equatable/equatable.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends HydratedBloc<AuthenticationEvent, AuthenticationState> {
  final AuthenticationRepository _authenticationRepository;
  final UserRepository _userRepository;

  late StreamSubscription<AuthenticationStatus>
      _authenticationStatusSubscription;

  AuthenticationBloc({
    required authenticationRepository,
    required userRepository,
  })  : assert(authenticationRepository != null),
        _authenticationRepository = authenticationRepository,
        _userRepository = userRepository,
        super(
          const AuthenticationState.unknown(),
        ) {
    _authenticationStatusSubscription = _authenticationRepository.status.listen(
      (status) => add(
        AuthenticationStatusChanged(status),
      ),
    );
    on<AuthenticationStatusChanged>((event, emit) async =>
        emit(await _mapAuthenticationStatusChangedtoState(event)));
    on<AuthenticationUserChanged>(
        (event, emit) => emit(_mapAuthenticationUserChangedToState(event)));
    on<AuthenticationLogoutRequested>(
        (event, emit) => _authenticationRepository.logOut());
  }

  bool isAuthenticated() => state.status == AuthenticationStatus.authenticated;

  void logout() => add(AuthenticationLogoutRequested());

  @override
  Future<void> close() {
    _authenticationStatusSubscription.cancel();
    _authenticationRepository.dispose();
    return super.close();
  }

  Future<AuthenticationState> _mapAuthenticationStatusChangedtoState(
    AuthenticationStatusChanged event,
  ) async {
    switch (event.status) {
      case AuthenticationStatus.unauthenticated:
        return const AuthenticationState.unauthenticated();
      case AuthenticationStatus.authenticated:
        final user = await _tryGetUser();
        return user != null
            ? AuthenticationState.authenticated(user)
            : const AuthenticationState.unauthenticated();
      default:
        return const AuthenticationState.unknown();
    }
  }

  AuthenticationState _mapAuthenticationUserChangedToState(
          AuthenticationUserChanged event) =>
      event.user != User.empty
          ? AuthenticationState.authenticated(event.user)
          : const AuthenticationState.unauthenticated();

  Future<User?> _tryGetUser() async {
    try {
      return await _userRepository.getUser();
    } on Exception {
      return null;
    }
  }

  @override
  AuthenticationState fromJson(Map<String, dynamic> json) =>
      AuthenticationState._(
        status: AuthenticationStatus.values[json['status']],
        user: User.fromJson(json['user']),
      );

  @override
  Map<String, dynamic> toJson(AuthenticationState state) =>
      {'status': state.status.index, 'user': state.user.toJson()};
}
