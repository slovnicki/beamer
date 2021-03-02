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

    test('beamBack leads to previous location and all gelpers are correct', () {
      router.beamTo(location2);

      expect(router.canBeamBack, true);
      expect(router.beamBackLocation, isA<Location2>());
      bool success = router.beamBack();
      expect(success, true);
      expect(router.currentLocation, location2);

      expect(router.canBeamBack, true);
      expect(router.beamBackLocation, isA<Location1>());
      success = router.beamBack();
      expect(success, true);
      expect(router.currentLocation, location1);

      expect(router.canBeamBack, false);
      expect(router.beamBackLocation, null);
      success = router.beamBack();
      expect(success, false);
      expect(router.currentLocation, location1);
    });
  });
}
