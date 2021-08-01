import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('beaming with relative URI works', (tester) async {
    // final innerDelegate = BeamerDelegate(
    //   locationBuilder: RoutesLocationBuilder(
    //     routes: {
    //       '/test': (context, state) => const Text('/test'),
    //       '1': (context, state) => const Text('1'),
    //       '2': (context, state) => const Text('2'),
    //     },
    //   ),
    // );
    // final rootDelegate = BeamerDelegate(
    //   locationBuilder: RoutesLocationBuilder(
    //     routes: {
    //       '/': (context, state) => const Text('/'),
    //       '/test*': (context, state) => Beamer(
    //             routerDelegate: innerDelegate,
    //           ),
    //     },
    //   ),
    // );
    // await tester.pumpWidget(
    //   MaterialApp.router(
    //     routeInformationParser: BeamerParser(),
    //     routerDelegate: rootDelegate,
    //   ),
    // );

    // expect(rootDelegate.configuration.location, '/');
    // expect(find.text('/'), findsOneWidget);

    // rootDelegate.beamToNamed('/test');
    // await tester.pump();
    // expect(rootDelegate.configuration.location, '/test');
    // expect(find.text('/test'), findsOneWidget);
  });
}
