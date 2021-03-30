import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import './locations.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: BeamerRouteInformationParser(),
      routerDelegate: RootRouterDelegate(
        locationBuilder: (state) => HomeLocation(state),
      ),
    );
  }
}
