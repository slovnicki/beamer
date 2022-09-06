import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  test('construct', () {
    final state = BeamState(
      pathPatternSegments: ['test', ':x'],
      pathParameters: {'x': 'y'},
    );
    expect(state.pathParameters['x'], 'y');
  });

  test('fromUriString', () {
    final state = BeamState.fromUriString('/test');
    expect(state.uri.pathSegments[0], 'test');
  });

  test('fromRouteInformation', () {
    final state = BeamState()
        .fromRouteInformation(const RouteInformation(location: '/test'));
    expect(state.uri.pathSegments[0], 'test');

    final state2 = BeamState().fromRouteInformation(const RouteInformation(
      location: '/test',
      state: {'x': 'y'},
    ));
    expect(state2.routeState, {'x': 'y'});
  });

  test('copyWith', () {
    final state = BeamState.fromUriString('/l2', beamLocation: Location2());
    final copy = state.copyWith();
    expect(copy.pathPatternSegments[0], 'l2');
  });

  test('copyForLocation', () {
    final state = BeamState.fromUriString('/l2/xx');
    final copy = state.copyForLocation(Location2(), null);
    expect(copy.pathParameters['id'], 'xx');
  });

  testWidgets('pathParameters are present in RoutesLocationBuilder',
      (tester) async {
    late BeamState _state;
    final delegate = BeamerDelegate(
      locationBuilder: RoutesLocationBuilder(
        routes: {
          '/profile/:address': (context, state, data) {
            _state = state;
            return Container();
          }
        },
      ),
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: BeamerParser(),
      ),
    );

    delegate.beamToNamed('/profile/xxx');
    await tester.pumpAndSettle();

    expect(_state.pathParameters['address'], 'xxx');
  });
}
