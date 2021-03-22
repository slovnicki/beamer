import 'package:beamer/beamer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final location1 = Location1(pathBlueprint: '/l1');
  final location2 = Location2(pathBlueprint: '/l2/:id');
  final customStateLocation = CustomStateLocation();
  final router = BeamerRouterDelegate(
    beamLocations: [
      location1,
      location2,
      customStateLocation,
    ],
  );
  router.setNewRoutePath((location1..prepare()).state.uri);

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
      expect(location2.state.pathParameters.containsKey('id'), true);
      expect(location2.state.pathParameters['id'], '1');
      expect(location2.state.queryParameters.containsKey('q'), true);
      expect(location2.state.queryParameters['q'], 't');
      expect(location2.state.data, {'x': 'y'});
    });

    test(
        'beaming to the same location type will not add it to history but will update current location',
        () {
      final historyLength = router.beamHistory.length;
      router.beamToNamed('/l2/2?q=t&r=s', data: {'x': 'z'});
      expect(router.beamHistory.length, historyLength);
      expect(
          router.currentLocation.state.pathParameters.containsKey('id'), true);
      expect(router.currentLocation.state.pathParameters['id'], '2');
      expect(
          router.currentLocation.state.queryParameters.containsKey('q'), true);
      expect(router.currentLocation.state.queryParameters['q'], 't');
      expect(
          router.currentLocation.state.queryParameters.containsKey('r'), true);
      expect(router.currentLocation.state.queryParameters['r'], 's');
      expect(router.currentLocation.state.data, {'x': 'z'});
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

    test('duplicate locations are removed from history', () {
      expect(router.beamHistory.length, 1);
      expect(router.beamHistory[0], isA<Location1>());
      router.beamToNamed('/l2');
      expect(router.beamHistory.length, 2);
      expect(router.beamHistory[0], isA<Location1>());
      router.beamToNamed('/l1');
      expect(router.beamHistory.length, 2);
      expect(router.beamHistory[0], isA<Location2>());
    });

    test(
        'beamTo replaceCurrent removes previous history state before appending new',
        () {
      expect(router.beamHistory.length, 2);
      expect(router.beamHistory[0], location2);
      expect(router.currentLocation, location1);
      router.beamTo(location2, replaceCurrent: true);
      expect(router.beamHistory.length, 1);
      expect(router.currentLocation, location2);
    });
  });

  test('stacked beam takes just last page for currentPages', () {
    router.beamToNamed('/l1/one', stacked: false);
    expect(router.currentLocation.pagesBuilder(null).length, 2);
    //expect(router.currentPages.length, 1);
  });

  test('custom state can be updated', () {
    router.beamToNamed('/custom');
    expect((router.currentLocation as CustomStateLocation).state.customVar,
        'test');
    (router.currentLocation as CustomStateLocation)
        .update((state) => state.copyWith(customVar: 'test-ok'));
    expect((router.currentLocation as CustomStateLocation).state.customVar,
        'test-ok');
  });

  test('beamTo works without setting the BeamState explicitly', () {
    router.beamTo(NoStateLocation());
    expect(router.currentLocation.state, isNotNull);
    router.beamBack();
  });
}
