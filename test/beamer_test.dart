import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  final location1 = Location1(pathBlueprint: '/l1');
  final location2 = Location2(pathBlueprint: '/l2/:id');
  final router = BeamerRouterDelegate(
    initialLocation: location1,
  );
  final parser = BeamerRouteInformationParser(
    beamLocations: [
      location1,
      location2,
    ],
  );

  test('BeamLocation can create valid URI', () {
    location2.pathParameters = {'id': '42'};
    location2.queryParameters = {'q': 'xxx'};
    location2.prepare();
    expect(location2.uri, '/l2/42?q=xxx');
  });

  test('BeamLocation can create valid URI while using named constructor', () {
    final location2WithParameters = Location2(
      pathBlueprint: '/l2/:id',
      pathParameters: {'id': '42'},
      queryParameters: {'q': 'xxx'},
    );
    location2WithParameters.prepare();
    expect(location2WithParameters.uri, '/l2/42?q=xxx');
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

    routeInformation = RouteInformation(location: '/l1/one');
    location = await parser.parseRouteInformation(routeInformation);
    expect(location, isA<Location1>());

    routeInformation = RouteInformation(location: '/l1/two');
    location = await parser.parseRouteInformation(routeInformation);
    expect(location, isA<Location1>());

    routeInformation = RouteInformation(location: '/l2');
    location = await parser.parseRouteInformation(routeInformation);
    expect(location, isA<Location2>());

    routeInformation = RouteInformation(location: '/l2/123?q=xxx');
    location = await parser.parseRouteInformation(routeInformation);
    expect(location, isA<Location2>());
  });

  test('Parsed BeamLocation creates correct pages', () async {
    var routeInformation = RouteInformation(location: '/l1');
    var location = await parser.parseRouteInformation(routeInformation);
    expect(location.pages.length, 1);

    routeInformation = RouteInformation(location: '/l1?q=xxx');
    location = await parser.parseRouteInformation(routeInformation);
    expect(location.pages.length, 1);

    routeInformation = RouteInformation(location: '/l1/one');
    location = await parser.parseRouteInformation(routeInformation);
    expect(location.pages.length, 2);
    expect(location.pages[1].key, ValueKey('l1-one'));

    routeInformation = RouteInformation(location: '/l1/two');
    location = await parser.parseRouteInformation(routeInformation);
    expect(location.pages.length, 2);
    expect(location.pages[1].key, ValueKey('l1-two'));
  });

  test('Unknown URI yields NotFound location', () async {
    var routeInformation = RouteInformation(location: '/x');
    var location = await parser.parseRouteInformation(routeInformation);
    expect(location, isA<NotFound>());
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
