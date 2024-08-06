import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:interceptors/main.dart';

class BeamInterceptExampleApp extends StatelessWidget {
  const BeamInterceptExampleApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: beamerDelegate,
      routeInformationParser: BeamerParser(),
      backButtonDispatcher: BeamerBackButtonDispatcher(delegate: beamerDelegate),
      debugShowCheckedModeBanner: false,
      builder: (context, child) => Scaffold(
        appBar: AppBar(),
        body: child,
      ),
    );
  }
}
