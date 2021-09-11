import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Root dispatcher', () {
    testWidgets('back button pops', (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
          },
        ),
      );
      final backButtonDispatcher =
          BeamerBackButtonDispatcher(delegate: delegate);
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
          backButtonDispatcher: backButtonDispatcher,
        ),
      );
      delegate.beamToNamed('/test');
      await tester.pump();
      expect(delegate.currentBeamLocation.state.routeInformation.location,
          '/test');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(delegate.currentBeamLocation.state.routeInformation.location, '/');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(delegate.currentBeamLocation.state.routeInformation.location, '/');
    });

    testWidgets('back button beams back if cannot pop', (tester) async {
      final delegate = BeamerDelegate(
        initialPath: '/test/deeper',
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
            '/test/deeper': (context, state) => Container(),
          },
        ),
      );
      final backButtonDispatcher =
          BeamerBackButtonDispatcher(delegate: delegate);
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
          backButtonDispatcher: backButtonDispatcher,
        ),
      );
      delegate.beamToNamed('/');
      await tester.pump();
      expect(delegate.currentBeamLocation.state.routeInformation.location, '/');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(delegate.currentBeamLocation.state.routeInformation.location,
          '/test/deeper');
    });

    testWidgets(
        'back button does not beams back if cannot pop, if fallback is set',
        (tester) async {
      final delegate = BeamerDelegate(
        initialPath: '/test/deeper',
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
            '/test/deeper': (context, state) => Container(),
          },
        ),
      );
      final backButtonDispatcher = BeamerBackButtonDispatcher(
        delegate: delegate,
        fallbackToBeamBack: false,
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
          backButtonDispatcher: backButtonDispatcher,
        ),
      );
      delegate.beamToNamed('/');
      await tester.pump();
      expect(delegate.currentBeamLocation.state.routeInformation.location, '/');

      final didBeamBack =
          await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(didBeamBack, false);
      expect(delegate.currentBeamLocation.state.routeInformation.location, '/');
    });

    testWidgets('onBack has priority', (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
          },
        ),
      );
      final backButtonDispatcher = BeamerBackButtonDispatcher(
        delegate: delegate,
        onBack: (delegate) async => true, // do nothing, but say it's handled
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
          backButtonDispatcher: backButtonDispatcher,
        ),
      );
      delegate.beamToNamed('/test');
      await tester.pump();
      expect(delegate.currentBeamLocation.state.routeInformation.location,
          '/test');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(delegate.currentBeamLocation.state.routeInformation.location,
          '/test');
    });

    testWidgets('alwaysBeamBack will not pop', (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
            '/test2': (context, state) => Container(),
          },
        ),
      );
      final backButtonDispatcher = BeamerBackButtonDispatcher(
        delegate: delegate,
        alwaysBeamBack: true,
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
          backButtonDispatcher: backButtonDispatcher,
        ),
      );
      delegate.beamToNamed('/test');
      await tester.pump(const Duration(seconds: 1));
      expect(delegate.configuration.location, '/test');

      delegate.beamToNamed('/test2');
      await tester.pump(const Duration(seconds: 1));
      expect(delegate.configuration.location, '/test2');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump(const Duration(seconds: 1));
      expect(delegate.configuration.location, '/test');
    });
  });

  group('Child dispatcher', () {
    testWidgets('back button pops', (tester) async {
      final childDelegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
          },
        ),
      );
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '*': (context, state) => Beamer(
                  routerDelegate: childDelegate,
                ),
          },
        ),
      );
      final backButtonDispatcher = BeamerBackButtonDispatcher(
        delegate: delegate,
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
          backButtonDispatcher: backButtonDispatcher,
        ),
      );
      delegate.beamToNamed('/test');
      await tester.pump();
      expect(delegate.currentBeamLocation.state.routeInformation.location,
          '/test');
      expect(childDelegate.currentBeamLocation.state.routeInformation.location,
          '/test');

      final did =
          await backButtonDispatcher.invokeCallback(Future.value(false));
      // print('did: $did');
      // await tester.pump(Duration(seconds: 1));
      // await tester.pump();
      // expect(delegate.currentBeamLocation.state.routeInformation.location, '/');
      // expect(childDelegate.currentBeamLocation.state.routeInformation.location,
      //     '/');
      // TODO
    });

    testWidgets('back button beams back', (tester) async {
      final childDelegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
          },
        ),
      );
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '*': (context, state) => Beamer(
                  routerDelegate: childDelegate,
                ),
          },
        ),
      );
      final backButtonDispatcher = BeamerBackButtonDispatcher(
        delegate: delegate,
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
          backButtonDispatcher: backButtonDispatcher,
        ),
      );
      delegate.beamToNamed('/test');
      await tester.pump();
      childDelegate.beamToNamed('/');
      await tester.pump();
      expect(delegate.currentBeamLocation.state.routeInformation.location, '/');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(delegate.currentBeamLocation.state.routeInformation.location,
          '/test');
    });

    testWidgets('onBack has priority', (tester) async {
      final childDelegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
          },
        ),
      );
      late BeamerBackButtonDispatcher rootBackButtonDispatcher;
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '*': (context, state) => Beamer(
                  routerDelegate: childDelegate,
                  backButtonDispatcher: BeamerChildBackButtonDispatcher(
                    parent: rootBackButtonDispatcher,
                    delegate: childDelegate,
                    onBack: (delegate) async =>
                        true, // do nothing, but say it's handled
                  ),
                ),
          },
        ),
      );
      rootBackButtonDispatcher = BeamerBackButtonDispatcher(
        delegate: delegate,
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
          backButtonDispatcher: rootBackButtonDispatcher,
        ),
      );
      delegate.beamToNamed('/test');
      await tester.pump();
      expect(delegate.currentBeamLocation.state.routeInformation.location,
          '/test');

      await rootBackButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(delegate.currentBeamLocation.state.routeInformation.location,
          '/test');
      final value =
          await rootBackButtonDispatcher.invokeCallback(Future.value(false));
      expect(value, true);
    });

    testWidgets('inactive child will return false', (tester) async {
      final childDelegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
          },
        ),
      );
      late BeamerBackButtonDispatcher rootBackButtonDispatcher;
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '*': (context, state) => Beamer(
                  routerDelegate: childDelegate,
                  backButtonDispatcher: BeamerChildBackButtonDispatcher(
                    parent: rootBackButtonDispatcher,
                    delegate: childDelegate..active = false,
                    onBack: (delegate) async => true,
                  ),
                ),
          },
        ),
      );
      rootBackButtonDispatcher = BeamerBackButtonDispatcher(
        delegate: delegate,
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
          backButtonDispatcher: rootBackButtonDispatcher,
        ),
      );
      delegate.beamToNamed('/test');
      await tester.pump();
      await rootBackButtonDispatcher.invokeCallback(Future.value(false));
      expect(delegate.currentBeamLocation.state.routeInformation.location, '/');
    });
  });
}
