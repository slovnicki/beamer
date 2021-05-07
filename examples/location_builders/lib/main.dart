import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import 'location_builders.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final routerDelegate = BeamerRouterDelegate(
    // There are three different options of building the locations.
    // They are interchangeable, depending on personal taste (in this case).
    //
    // OPTION A:
    locationBuilder: simpleLocationBuilder,
    //
    // OPTION B:
    //locationBuilder: beamerLocationBuilder,
    //
    // OPTION C:
    //locationBuilder: (state) => BooksLocation(state: state),
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
