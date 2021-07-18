import 'dart:convert';

import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final parser = BeamerParser();

  test('parsing from RouteInformation to RouteInformation', () async {
    final routeInformation = await parser.parseRouteInformation(
      const RouteInformation(
        location: '/test',
        state: {'x': 'y'},
      ),
    );

    expect(routeInformation.location, equals('/test'));
    expect(routeInformation.state, equals({'x': 'y'}));
  });

  test('parsing from RouteInformation to RouteInformation', () {
    final routeInformation = parser.restoreRouteInformation(
      const RouteInformation(
        location: '/test',
        state: {'x': 'y'},
      ),
    );

    expect(routeInformation.location, equals('/test'));
    expect(routeInformation.state, equals({'x': 'y'}));
  });
}
