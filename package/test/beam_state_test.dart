import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  test('construct', () {
    final state = BeamState(
      pathBlueprintSegments: ['test', ':x'],
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
    expect(state2.data, {'x': 'y'});
  });

  test('copyWith', () {
    final state = BeamState.fromUriString('/l2', beamLocation: Location2());
    final copy = state.copyWith();
    expect(copy.pathBlueprintSegments[0], 'l2');
  });

  test('copyForLocation', () {
    final state = BeamState.fromUriString('/l2/xx');
    final copy = state.copyForLocation(Location2());
    expect(copy.pathParameters['id'], 'xx');
  });
}
