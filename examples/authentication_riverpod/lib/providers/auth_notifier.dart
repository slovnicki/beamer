import 'package:authentication_riverpod/models/user.model.dart';
import 'package:authentication_riverpod/providers/provider.dart';
import 'package:authentication_riverpod/services/repository.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState._(
      {this.user = UserModel.empty, this.status = AuthStatus.loading});

  const AuthState.loading() : this._();

  const AuthState.authenticated(UserModel user)
      : this._(user: user, status: AuthStatus.authenticated);

  const AuthState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  final UserModel user;
  final AuthStatus status;

  @override
  List<Object?> get props => [user, status];
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(Ref ref)
      : repo = ref.read(appRepositoryProvider),
        super(AuthState.loading()) {
    checkUserAuth();
  }

  Future<void> checkUserAuth() async {
    /// this is where you can check if you have the cached token on the phone
    /// on app startup
    /// for now we assume no such caching is done
    state = AuthState.unauthenticated();
  }

  Future<void> loginUser(String username, String password) async {
    state = AuthState.loading();

    UserModel user = await repo.loginUser(username, password);

    if (user == UserModel.empty) {
      state = AuthState.unauthenticated();
    } else {
      /// do your pre-checks about the user before marking the state as
      /// authenticated
      state = AuthState.authenticated(user);
    }
  }

  Future<void> logoutUser() async {
    await repo.logoutUser();
    state = AuthState.unauthenticated();
  }

  AppRepository repo;
}
