import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final parser = BeamerParser();

  test('parsing from RouteInformation to BeamState', () async {
    final beamState = await parser.parseRouteInformation(
      RouteInformation(
        location: '/test',
        state: json.encode({'x': 'y'}),
      ),
    );

    expect(beamState.uri.path, equals('/test'));
    expect(beamState.data, equals({'x': 'y'}));
  });

  test('parsing from BeamState to RouteInformation', () {
    final routeInformation = parser.restoreRouteInformation(
      BeamState.fromUri(
        Uri.parse('/test'),
        data: {'x': 'y'},
      ),
    );

    expect(routeInformation.location, equals('/test'));
    expect(routeInformation.state, equals(json.encode({'x': 'y'})));
  });
}
