import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final innerDelegate = BeamerDelegate(
    updateParent: false,
    appliedRouteListener: (routeInformation, _) =>
        print('inner: ${routeInformation.location}'),
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/test/1': (context, state) => ElevatedButton(
              onPressed: () => context.beamToNamed('/test/2'),
              child: const Text('/test/1 -> /test/2'),
            ),
        '/test/2': (context, state) => const Text('/test/2'),
      },
    ),
  );
  late final rootDelegate = BeamerDelegate(
    appliedRouteListener: (routeInformation, _) =>
        print('root: ${routeInformation.location}'),
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/': (context, state) => ElevatedButton(
              onPressed: () => context.beamToNamed('/test'),
              child: const Text('/ -> /test'),
            ),
        '/test': (context, state) => ElevatedButton(
              onPressed: () => context.beamToNamed('/test/1'),
              child: const Text('/test -> /test/1'),
            ),
        '/test/*': (context, state) => BeamPage(
              key: const ValueKey('test/x'),
              child: Beamer(
                routerDelegate: innerDelegate,
              ),
            ),
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: rootDelegate,
      routeInformationParser: BeamerParser(),
    );
  }
}

void main() => runApp(MyApp());
