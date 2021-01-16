import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:beamer/beamer.dart';

class Location1 extends BeamLocation {
  @override
  List<Page> get pages => [
        BeamPage(
          identifier: 'l1',
          page: Container(),
        )
      ];

  @override
  String get pathBlueprint => '/l1';
}

class Location2 extends BeamLocation {
  @override
  List<Page> get pages => [
        BeamPage(
          identifier: 'l2',
          page: Container(),
        )
      ];

  @override
  String get pathBlueprint => '/l2/:id';
}

void main() {
  final location1 = Location1();
  final location2 = Location2();
  final router = BeamerRouterDelegate(initialLocation: location1);
  final parser = BeamerRouteInformationParser(beamLocations: [
    location1,
    location2,
  ]);

  test('BeamLocation can create valid URI', () {
    location2.pathParameters = {'id': '42'};
    location2.queryParameters = {'q': 'xxx'};
    location2.prepare();
    expect(location2.uri, '/l2/42?q=xxx');
  });

  test('initialLocation is set', () {
    expect(router.currentConfiguration, location1);
  });

  test('beamTo changes locations', () {
    router.beamTo(location2);
    expect(router.currentConfiguration, location2);
  });

  test('beamBack leads to previous location', () {
    router.beamBack();
    expect(router.currentConfiguration, location1);

    router.beamBack();
    expect(router.currentConfiguration, location2);
  });

  test('URI is parsed to BeamLocation', () async {
    var routeInformation = RouteInformation(location: '/l1');
    var location = await parser.parseRouteInformation(routeInformation);
    expect(location, isA<Location1>());

    routeInformation = RouteInformation(location: '/l1?q=xxx');
    location = await parser.parseRouteInformation(routeInformation);
    expect(location, isA<Location1>());

    routeInformation = RouteInformation(location: '/l2');
    location = await parser.parseRouteInformation(routeInformation);
    expect(location, isA<Location2>());

    routeInformation = RouteInformation(location: '/l2/123?q=xxx');
    location = await parser.parseRouteInformation(routeInformation);
    expect(location, isA<Location2>());
  });

  test('BeamLocation carries URL parameters', () async {
    var routeInformation = RouteInformation(location: '/l2');
    var location = await parser.parseRouteInformation(routeInformation);
    expect(location.pathParameters, {});

    routeInformation = RouteInformation(location: '/l2/123');
    location = await parser.parseRouteInformation(routeInformation);
    expect(location.pathParameters, {'id': '123'});

    routeInformation = RouteInformation(location: '/l2/123?q=xxx');
    location = await parser.parseRouteInformation(routeInformation);
    expect(location.pathParameters, {'id': '123'});
    expect(location.queryParameters, {'q': 'xxx'});
  });
}
