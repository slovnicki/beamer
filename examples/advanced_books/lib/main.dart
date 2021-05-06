import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'locations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final routerDelegate = BeamerRouterDelegate(
    locationBuilder: BeamerLocationBuilder(
      beamLocations: [
        HomeLocation(),
        BooksLocation(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: routerDelegate,
      routeInformationParser: BeamerRouteInformationParser(),
    );
  }
}
