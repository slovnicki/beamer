import 'package:beamer/beamer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final location1 = Location1(pathBlueprint: '/l1');
  final location2 = Location2(pathBlueprint: '/l2/:id');
  final router = BeamerRouterDelegate(
    beamLocations: [location1, location2],
  );
  router.setNewRoutePath((location1..prepare()).uri);

  group('initialization & beaming', () {
    test('initialLocation is set', () {
      expect(router.currentLocation, location1);
    });

    test('beamTo changes locations', () {
      router.beamTo(location2);
      expect(router.currentLocation, location2);
    });

    test('beamToNamed updates locations with correct parameters', () {
      router.beamToNamed('/l2/1?q=t', data: {'x': 'y'});
      expect(router.currentLocation, location2);
      expect(location2.pathParameters.containsKey('id'), true);
      expect(location2.pathParameters['id'], '1');
      expect(location2.queryParameters.containsKey('q'), true);
      expect(location2.queryParameters['q'], 't');
      expect(location2.data, {'x': 'y'});
    });

    test(
        'beaming to the same location type will not add it to history but will update current location',
        () {
      final historyLength = router.beamHistory.length;
      router.beamToNamed('/l2/2?q=t&r=s', data: {'x': 'z'});
      expect(router.beamHistory.length, historyLength);
      expect(router.currentLocation.pathParameters.containsKey('id'), true);
      expect(router.currentLocation.pathParameters['id'], '2');
      expect(router.currentLocation.queryParameters.containsKey('q'), true);
      expect(router.currentLocation.queryParameters['q'], 't');
      expect(router.currentLocation.queryParameters.containsKey('r'), true);
      expect(router.currentLocation.queryParameters['r'], 's');
      expect(router.currentLocation.data, {'x': 'z'});
    });

    test('beamBack leads to previous location and all helpers are correct', () {
      expect(router.canBeamBack, true);
      expect(router.beamBackLocation, isA<Location1>());
      expect(router.beamBack(), true);
      expect(router.currentLocation, location1);

      expect(router.canBeamBack, false);
      expect(router.beamBackLocation, null);
      expect(router.beamBack(), false);
      expect(router.currentLocation, location1);
    });
  });

  test('stacked beam takes just last page for currentPages', () {
    router.beamToNamed('/l1/one', stacked: false);
    expect(router.currentLocation.pagesBuilder(null).length, 2);
    //expect(router.currentPages.length, 1);
  });
}
