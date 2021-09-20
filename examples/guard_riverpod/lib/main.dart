
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guard_riverpod/locations.dart';

void main() {
  final container = ProviderContainer();

  // Passing `ref.read`, which is a `Reader` instance, so that we can use
  // riverpod as we see fit.
  final routerDelegate = createDelegate(container.read);
  final routeInformationParser = BeamerParser();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: MyApp(routeInformationParser, routerDelegate),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp(this.routeInformationParser, this.routerDelegate);

  final RouteInformationParser<Object> routeInformationParser;
  final RouterDelegate<Object> routerDelegate;

  final _scaffoldKey = GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: routerDelegate,
      routeInformationParser: routeInformationParser,
      scaffoldMessengerKey: _scaffoldKey,
    );
  }
}

BeamerDelegate createDelegate(Reader read) => BeamerDelegate(
  initialPath: '/$firstRoute',
  // If we wanted to, we could even pass the `Reader` to locations, if they
  // needed to.
  locationBuilder: BeamerLocationBuilder(beamLocations: [MyLocation()]),
  guards: [
    BeamGuard(
      pathPatterns: ['/$firstRoute/$secondRoute'], 
      // Only allow to navigate past `firstRoute` if the `navigationProvider` is `true`.
      check: (_, __) => read(navigationToSecondProvider).state,
    ),
  ],
);