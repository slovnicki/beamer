import 'package:deep_links/authenticator.dart';
import 'package:deep_links/beamer_delegate.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

void main() {
  createAuthenticator();
  createBeamerDelegate();
  beamerDelegate.setDeepLink('/home/deeper');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: beamerDelegate,
      routeInformationParser: BeamerParser(),
    );
  }
}
