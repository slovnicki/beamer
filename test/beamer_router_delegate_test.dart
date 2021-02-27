import 'package:beamer/beamer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final location1 = Location1(pathBlueprint: '/l1');
  final location2 = Location2(pathBlueprint: '/l2/:id');
  final router = BeamerRouterDelegate(
    initialLocation: location1,
  );
  router.setNewRoutePath(location1);

  group('initialization & beaming', () {
    test('initialLocation is set', () {
      expect(router.currentLocation, location1);
    });

    test('beamTo changes locations', () {
      router.beamTo(location2);
      expect(router.currentLocation, location2);
    });

    test('beamBack leads to previous location', () {
      router.beamTo(location2);

      bool success = router.beamBack();
      expect(success, true);
      expect(router.currentLocation, location2);

      success = router.beamBack();
      expect(success, true);
      expect(router.currentLocation, location1);

      success = router.beamBack();
      expect(success, false);
      expect(router.currentLocation, location1);
    });
  });
}
