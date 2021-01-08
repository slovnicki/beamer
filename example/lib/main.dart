import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:example/beamer_location.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: BeamerRouteInformationParser(
        beamLocations: [
          HomeLocation(),
          FirstLocation(),
          SecondLocation(),
        ],
      ),
      routerDelegate: BeamerRouterDelegate(
        initialLocation: HomeLocation(),
      ),
    );
  }
}
