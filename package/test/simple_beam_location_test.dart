import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final delegate = BeamerRouterDelegate(
    locationBuilder: SimpleLocationBuilder(
      routes: {
        '/': (context) => Container(),
        '/test': (context) => Container(),
      },
    ),
  );
  delegate.setNewRoutePath(Uri.parse('/'));

  group('Query', () {
    test('location takes query', () {
      expect(delegate.currentLocation.state.queryParameters, equals({}));
      delegate.beamToNamed('/?q=t');
      expect(
          delegate.currentLocation.state.queryParameters, equals({'q': 't'}));
    });

    testWidgets('location includes query in page key', (tester) async {
      await tester.pumpWidget(MaterialApp.router(
        routeInformationParser: BeamerRouteInformationParser(),
        routerDelegate: delegate,
      ));
      expect(delegate.currentPages.last.key, isA<ValueKey>());
      expect((delegate.currentPages.last.key as ValueKey).value,
          equals(ValueKey('/?q=t').value));
    });
  });

  group('NotFound', () {
    test('can be recognized with basic example', () {
      delegate.beamToNamed('/unknown-route');
      expect(delegate.currentLocation, isA<NotFound>());
    });

    testWidgets('delegate builds notFoundPage', (tester) async {
      await tester.pumpWidget(MaterialApp.router(
        routeInformationParser: BeamerRouteInformationParser(),
        routerDelegate: delegate,
      ));
      expect(find.text('Not found'), findsOneWidget);
    });

    test('can be recognized with harder example', () {
      delegate.beamToNamed('/test/unknown-route');
      expect(delegate.currentLocation, isA<NotFound>());
    });

    test('but * will override this behavior', () {
      final delegate = BeamerRouterDelegate(
        locationBuilder: SimpleLocationBuilder(
          routes: {
            '/': (context) => Container(),
            '/test/*': (context) => Container(),
          },
        ),
      );
      delegate.setNewRoutePath(Uri.parse('/test/unknown'));
      expect(delegate.currentLocation, isA<SimpleBeamLocation>());
    });

    test('only * will also override NotFound', () {
      final delegate1 = BeamerRouterDelegate(
        locationBuilder: SimpleLocationBuilder(
          routes: {
            '/*': (context) => Container(),
          },
        ),
      );
      delegate1.setNewRoutePath(Uri.parse('/test'));
      expect(delegate1.currentLocation, isA<SimpleBeamLocation>());

      final delegate2 = BeamerRouterDelegate(
        locationBuilder: SimpleLocationBuilder(
          routes: {
            '*': (context) => Container(),
          },
        ),
      );
      delegate2.setNewRoutePath(Uri.parse('/test'));
      expect(delegate2.currentLocation, isA<SimpleBeamLocation>());
    });
  });
}
