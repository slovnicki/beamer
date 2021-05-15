import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import 'locations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final routerDelegate = BeamerDelegate(
    locationBuilder: (state) => HomeLocation(state),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
    );
  }
}
