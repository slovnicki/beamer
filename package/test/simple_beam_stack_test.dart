import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  final delegate = BeamerDelegate(
    stackBuilder: RoutesStackBuilder(
      routes: {
        '/': (context, state, data) => Container(),
        RegExp('/test'): (context, state, data) => Container(),
        RegExp('/path-param/(?<test>[a-z]+)'): (context, state, data) => Text(
              state.pathParameters['test'] ?? 'failure',
            ),
      },
    ),
  );

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
        stackBuilder: RoutesStackBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
          },
        ),
      );
      delegate.setNewRoutePath(RouteInformation(uri: Uri.parse('/')));

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
    testWidgets('each BeamPage has a different ValueKey', (tester) async {
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
    test('stack takes query', () {
      expect((delegate.currentBeamStack.state as BeamState).queryParameters,
          equals({}));
      delegate.beamToNamed('/?q=t');
      expect((delegate.currentBeamStack.state as BeamState).queryParameters,
          equals({'q': 't'}));
    });

    testWidgets('stack includes query in page key', (tester) async {
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
      expect(delegate.currentBeamStack, isA<NotFound>());

      delegate.beamToNamed('/Test/unknown');
      expect(delegate.currentBeamStack, isA<NotFound>());
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
        stackBuilder: RoutesStackBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test/*': (context, state, data) => Container(),
          },
        ),
      );

      delegate.beamToNamed('/test/anything');
      expect(delegate.currentBeamStack, isA<RoutesBeamStack>());
    });

    test('only * will override NotFound', () {
      final delegate1 = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
          routes: {
            '/*': (context, state, data) => Container(),
          },
        ),
      );
      delegate1.setNewRoutePath(RouteInformation(uri: Uri.parse('/anything')));
      expect(delegate1.currentBeamStack, isA<RoutesBeamStack>());

      final delegate2 = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
          routes: {
            '*': (context, state, data) => Container(),
          },
        ),
      );
      delegate2.setNewRoutePath(RouteInformation(uri: Uri.parse('/anything')));
      expect(delegate2.currentBeamStack, isA<RoutesBeamStack>());
    });

    test('path parameters are not considered NotFound', () {
      final delegate1 = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
          routes: {
            '/test/:testId': (context, state, data) => Container(),
          },
        ),
      );
      delegate1.setNewRoutePath(RouteInformation(uri: Uri.parse('/test/1')));
      expect(delegate1.currentBeamStack, isA<RoutesBeamStack>());
    });
  });

  group('RegExp', () {
    test('can utilize path parameters', () {
      delegate.beamToNamed('/path-param/success');
      expect((delegate.currentBeamStack.state as BeamState).pathParameters,
          contains('test'));
    });
  });
}
