import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'location_builders.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final routerDelegate = BeamerRouterDelegate(
    // As locationBuilder you can either use SimpleLocationBuilder or BeamerLocationBuilder.
    // They are interchangeable, depending on personal taste (in this case).
    //
    // OPTION A: SimpleLocationBuilder
    locationBuilder: simpleLocationBuilder,
    //
    // OPTION B: BeamerLocationBuilder
    //locationBuilder: beamerLocationBuilder,
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
