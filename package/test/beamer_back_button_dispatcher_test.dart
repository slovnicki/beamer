import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Root dispatcher', () {
    testWidgets('back button pops', (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: SimpleLocationBuilder(
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
      expect(delegate.currentBeamLocation.state.uri.toString(), '/test');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(delegate.currentBeamLocation.state.uri.toString(), '/');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(delegate.currentBeamLocation.state.uri.toString(), '/');
    });

    testWidgets('back button beams back', (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: SimpleLocationBuilder(
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
      delegate.beamToNamed('/');
      await tester.pump();
      expect(delegate.currentBeamLocation.state.uri.toString(), '/');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(delegate.currentBeamLocation.state.uri.toString(), '/test');
    });

    testWidgets('onBack has priority', (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: SimpleLocationBuilder(
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
      expect(delegate.currentBeamLocation.state.uri.toString(), '/test');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(delegate.currentBeamLocation.state.uri.toString(), '/test');
    });
  });

  group('Child dispatcher', () {
    testWidgets('back button pops', (tester) async {
      final childDelegate = BeamerDelegate(
        locationBuilder: SimpleLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
          },
        ),
      );
      final delegate = BeamerDelegate(
        locationBuilder: SimpleLocationBuilder(
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
      expect(delegate.currentBeamLocation.state.uri.toString(), '/test');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(delegate.currentBeamLocation.state.uri.toString(), '/');
    });

    testWidgets('back button beams back', (tester) async {
      final childDelegate = BeamerDelegate(
        locationBuilder: SimpleLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
          },
        ),
      );
      final delegate = BeamerDelegate(
        locationBuilder: SimpleLocationBuilder(
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
      expect(delegate.currentBeamLocation.state.uri.toString(), '/');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(delegate.currentBeamLocation.state.uri.toString(), '/test');
    });

    testWidgets('onBack has priority', (tester) async {
      final childDelegate = BeamerDelegate(
        locationBuilder: SimpleLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
          },
        ),
      );
      late BeamerBackButtonDispatcher rootBackButtonDispatcher;
      final delegate = BeamerDelegate(
        locationBuilder: SimpleLocationBuilder(
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
      expect(delegate.currentBeamLocation.state.uri.toString(), '/test');

      await rootBackButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(delegate.currentBeamLocation.state.uri.toString(), '/test');
      final value =
          await rootBackButtonDispatcher.invokeCallback(Future.value(false));
      expect(value, true);
    });

    testWidgets('inactive child will return false', (tester) async {
      final childDelegate = BeamerDelegate(
        locationBuilder: SimpleLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
          },
        ),
      );
      late BeamerBackButtonDispatcher rootBackButtonDispatcher;
      final delegate = BeamerDelegate(
        locationBuilder: SimpleLocationBuilder(
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
      expect(delegate.currentBeamLocation.state.uri.toString(), '/');
    });
  });
}
