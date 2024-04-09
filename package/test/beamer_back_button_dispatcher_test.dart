import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Root dispatcher', () {
    testWidgets('back button pops', (tester) async {
      final delegate = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
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
      expect(
          delegate.currentBeamStack.state.routeInformation.uri.path, '/test');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pumpAndSettle();
      expect(delegate.currentBeamStack.state.routeInformation.uri.path, '/');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pumpAndSettle();
      expect(delegate.currentBeamStack.state.routeInformation.uri.path, '/');
    });

    testWidgets('back button beams back if cannot pop', (tester) async {
      final delegate = BeamerDelegate(
        initialPath: '/test/deeper',
        stackBuilder: RoutesStackBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
            '/test/deeper': (context, state, data) => Container(),
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
      expect(delegate.currentBeamStack.state.routeInformation.uri.path, '/');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(delegate.currentBeamStack.state.routeInformation.uri.path,
          '/test/deeper');
    });

    testWidgets(
        'back button does not beams back if cannot pop, if fallback is set',
        (tester) async {
      final delegate = BeamerDelegate(
        initialPath: '/test/deeper',
        stackBuilder: RoutesStackBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
            '/test/deeper': (context, state, data) => Container(),
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
      expect(delegate.currentBeamStack.state.routeInformation.uri.path, '/');

      final didBeamBack =
          await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(didBeamBack, false);
      expect(delegate.currentBeamStack.state.routeInformation.uri.path, '/');
    });

    testWidgets('onBack has priority', (tester) async {
      final delegate = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
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
      expect(
          delegate.currentBeamStack.state.routeInformation.uri.path, '/test');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(
          delegate.currentBeamStack.state.routeInformation.uri.path, '/test');
    });

    testWidgets('alwaysBeamBack will not pop', (tester) async {
      final delegate = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
            '/test2': (context, state, data) => Container(),
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
      expect(delegate.configuration.uri.path, '/test');

      delegate.beamToNamed('/test2');
      await tester.pump(const Duration(seconds: 1));
      expect(delegate.configuration.uri.path, '/test2');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump(const Duration(seconds: 1));
      expect(delegate.configuration.uri.path, '/test');
    });
  });

  group('Child dispatcher', () {
    testWidgets('back button pops', (tester) async {
      late BeamerDelegate childDelegate;
      final delegate = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
          routes: {
            '*': (context, state, data) {
              childDelegate = BeamerDelegate(
                stackBuilder: RoutesStackBuilder(
                  routes: {
                    '/': (context, state, data) => Container(),
                    '/test': (context, state, data) => Container(),
                  },
                ),
              );
              return Beamer(routerDelegate: childDelegate);
            },
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
      expect(
          delegate.currentBeamStack.state.routeInformation.uri.path, '/test');
      expect(childDelegate.currentBeamStack.state.routeInformation.uri.path,
          '/test');

      // final did =
      //     await backButtonDispatcher.invokeCallback(Future.value(false));
      // print('did: $did');
      // await tester.pump(Duration(seconds: 1));
      // await tester.pump();
      // expect(delegate.currentBeamStack.state.routeInformation.uri.toString(), '/');
      // expect(childDelegate.currentBeamStack.state.routeInformation.uri.toString(),
      //     '/');
      // TODO
    });

    testWidgets('back button beams back', (tester) async {
      late BeamerDelegate childDelegate;
      final delegate = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
          routes: {
            '*': (context, state, data) {
              childDelegate = BeamerDelegate(
                stackBuilder: RoutesStackBuilder(
                  routes: {
                    '/': (context, state, data) => Container(),
                    '/test': (context, state, data) => Container(),
                  },
                ),
              );
              return Beamer(routerDelegate: childDelegate);
            },
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
      expect(delegate.currentBeamStack.state.routeInformation.uri.path, '/');

      await backButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(
          delegate.currentBeamStack.state.routeInformation.uri.path, '/test');
    });

    testWidgets('onBack has priority', (tester) async {
      late BeamerDelegate childDelegate;
      late BeamerBackButtonDispatcher rootBackButtonDispatcher;
      final delegate = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
          routes: {
            '*': (context, state, data) {
              childDelegate = BeamerDelegate(
                stackBuilder: RoutesStackBuilder(
                  routes: {
                    '/': (context, state, data) => Container(),
                    '/test': (context, state, data) => Container(),
                  },
                ),
              );
              return Beamer(
                routerDelegate: childDelegate,
                backButtonDispatcher: BeamerChildBackButtonDispatcher(
                  parent: rootBackButtonDispatcher,
                  delegate: childDelegate,
                  onBack: (delegate) async =>
                      true, // do nothing, but say it's handled
                ),
              );
            },
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
      expect(
          delegate.currentBeamStack.state.routeInformation.uri.path, '/test');

      await rootBackButtonDispatcher.invokeCallback(Future.value(false));
      await tester.pump();
      expect(
          delegate.currentBeamStack.state.routeInformation.uri.path, '/test');
      final value =
          await rootBackButtonDispatcher.invokeCallback(Future.value(false));
      expect(value, true);
    });

    testWidgets('inactive child will return false', (tester) async {
      late BeamerDelegate childDelegate;
      late BeamerBackButtonDispatcher rootBackButtonDispatcher;
      final delegate = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
          routes: {
            '*': (context, state, data) {
              childDelegate = BeamerDelegate(
                stackBuilder: RoutesStackBuilder(
                  routes: {
                    '/': (context, state, data) => Container(),
                    '/test': (context, state, data) => Container(),
                  },
                ),
              );
              return Beamer(
                routerDelegate: childDelegate,
                backButtonDispatcher: BeamerChildBackButtonDispatcher(
                  parent: rootBackButtonDispatcher,
                  delegate: childDelegate,
                  onBack: (delegate) async => true,
                ),
              );
            },
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
      childDelegate.active = false;
      await rootBackButtonDispatcher.invokeCallback(Future.value(false));
      expect(delegate.currentBeamStack.state.routeInformation.uri.path, '/');
    });
  });
}
