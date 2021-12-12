import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final delegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/': (context, state, data) => Container(),
        RegExp('/test'): (context, state, data) => Container(),
        RegExp('/path-param/(?<test>[a-z]+)'): (context, state, data) => Text(
              state.pathParameters['test'] ?? 'failure',
            ),
      },
    ),
  );
  delegate.setNewRoutePath(const RouteInformation(location: '/'));

  group('General', () {
    testWidgets('/ can be at the end of URI and will be ignored when matching',
        (tester) async {
      await tester.pumpWidget(MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ));

      delegate.beamToNamed('/test/');
      await tester.pump();
      expect(delegate.currentPages.length, 2);
    });

    testWidgets(
        '/ can be at the end of URI and will be ignored when matching, without RegExp',
        (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
          },
        ),
      );
      delegate.setNewRoutePath(const RouteInformation(location: '/'));

      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/test/');
      await tester.pump();
      expect(delegate.currentPages.length, 2);
    });
  });

  group('Keys', () {
    testWidgets('each BeamPage has a differenet ValueKey', (tester) async {
      await tester.pumpWidget(MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ));
      delegate.beamToNamed('/test');
      await tester.pump();
      expect(delegate.currentPages.length, 2);
      final keysSet = <dynamic>{};
      for (var page in delegate.currentPages) {
        keysSet.add((page.key as ValueKey).value);
      }
      expect(keysSet.length, equals(2));
    });
  });

  group('Query', () {
    test('location takes query', () {
      expect((delegate.currentBeamLocation.state as BeamState).queryParameters,
          equals({}));
      delegate.beamToNamed('/?q=t');
      expect((delegate.currentBeamLocation.state as BeamState).queryParameters,
          equals({'q': 't'}));
    });

    testWidgets('location includes query in page key', (tester) async {
      await tester.pumpWidget(MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ));
      expect(delegate.currentPages.last.key, isA<ValueKey>());
      expect((delegate.currentPages.last.key as ValueKey).value,
          equals(const ValueKey('/?q=t').value));
    });
  });

  group('NotFound', () {
    test('can be recognized', () {
      delegate.beamToNamed('/unknown');
      expect(delegate.currentBeamLocation, isA<NotFound>());

      delegate.beamToNamed('/Test/unknown');
      expect(delegate.currentBeamLocation, isA<NotFound>());
    });

    testWidgets('delegate builds notFoundPage', (tester) async {
      await tester.pumpWidget(MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ));
      delegate.beamToNamed('/not-found');
      expect(find.text('Not found'), findsOneWidget);
    });

    test('* in path segment will override NotFound', () {
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test/*': (context, state, data) => Container(),
          },
        ),
      );

      delegate.beamToNamed('/test/anything');
      expect(delegate.currentBeamLocation, isA<RoutesBeamLocation>());
    });

    test('only * will override NotFound', () {
      final delegate1 = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/*': (context, state, data) => Container(),
          },
        ),
      );
      delegate1.setNewRoutePath(const RouteInformation(location: '/anything'));
      expect(delegate1.currentBeamLocation, isA<RoutesBeamLocation>());

      final delegate2 = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '*': (context, state, data) => Container(),
          },
        ),
      );
      delegate2.setNewRoutePath(const RouteInformation(location: '/anything'));
      expect(delegate2.currentBeamLocation, isA<RoutesBeamLocation>());
    });

    test('path parameters are not considered NotFound', () {
      final delegate1 = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/test/:testId': (context, state, data) => Container(),
          },
        ),
      );
      delegate1.setNewRoutePath(const RouteInformation(location: '/test/1'));
      expect(delegate1.currentBeamLocation, isA<RoutesBeamLocation>());
    });
  });

  group('RegExp', () {
    test('can utilize path parameters', () {
      delegate.beamToNamed('/path-param/success');
      expect((delegate.currentBeamLocation.state as BeamState).pathParameters,
          contains('test'));
    });
  });
}
