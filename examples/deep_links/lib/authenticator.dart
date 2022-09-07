import 'dart:async';

import 'package:flutter/material.dart';

late final Authenticator authenticator;

void createAuthenticator([
  AuthenticationStatus status = AuthenticationStatus.loading,
]) {
  authenticator = Authenticator(status);
}

enum AuthenticationStatus { authenticated, notAuthenticated, loading }

class Authenticator extends ValueNotifier<AuthenticationStatus> {
  Authenticator(super.value) {
    if (isLoading) {
      Future.delayed(
        const Duration(seconds: 2),
        () => login(),
      );
    }
  }

  bool get isAuthenticated => value == AuthenticationStatus.authenticated;
  bool get isNotAuthenticated => value == AuthenticationStatus.notAuthenticated;
  bool get isLoading => value == AuthenticationStatus.loading;

  void login() => value = AuthenticationStatus.authenticated;
  void logout() => value = AuthenticationStatus.notAuthenticated;
}
