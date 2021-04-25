import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  final location2 = Location2(BeamState(pathBlueprintSegments: ['l2', ':id']));
  group('prepare', () {
    test('BeamLocation can create valid URI', () {
      location2.state = location2.state.copyWith(
        pathParameters: {'id': '42'},
        queryParameters: {'q': 'xxx'},
      );
      expect(location2.state.uri.toString(), '/l2/42?q=xxx');
    });
  });

  group('SimpleBeamLocation', () {
    final delegate = BeamerRouterDelegate(
      locationBuilder: SimpleLocationBuilder(
        routes: {
          '/': (context) => Container(),
        },
      ),
    );
    delegate.setNewRoutePath(Uri.parse('/'));

    test('SimpleBeamLocation takes query', () {
      expect(delegate.currentLocation.state.queryParameters, equals({}));
      delegate.beamToNamed('/?q=t');
      expect(
          delegate.currentLocation.state.queryParameters, equals({'q': 't'}));
    });

    testWidgets('SimpleBeamLocation includes query in page key',
        (tester) async {
      await tester.pumpWidget(MaterialApp.router(
        routeInformationParser: BeamerRouteInformationParser(),
        routerDelegate: delegate,
      ));
      expect(delegate.currentPages.last.key, isA<ValueKey>());
      expect((delegate.currentPages.last.key as ValueKey).value,
          equals(ValueKey('/?q=t').value));
    });
  });
}
