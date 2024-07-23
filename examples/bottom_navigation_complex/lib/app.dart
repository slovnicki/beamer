import 'package:bottom_navigation_complex/routers/app.router.dart';
import 'package:bottom_navigation_complex/screens/splash.screen.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

class App extends StatelessWidget {
  static final BeamerDelegate _router = routerDelegate;

  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: _router,
      routeInformationParser: BeamerParser(),
      builder: (context, child) => SplashScreen(screen: child),
    );
  }
}
