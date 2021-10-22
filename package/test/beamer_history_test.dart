import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_locations.dart';

void main() {
  group('Beamer history', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    late BeamerDelegate delegate;

    setUp(() {
      delegate = BeamerDelegate(
        locationBuilder: (routeInformation, __) {
          if (routeInformation.location?.contains('l1') ?? false) {
            return Location1(routeInformation);
          }
          if (routeInformation.location?.contains('l2') ?? false) {
            return Location2(routeInformation);
          }
          if (CustomStateLocation()
              .canHandle(Uri.parse(routeInformation.location ?? '/'))) {
            return CustomStateLocation(routeInformation);
          }
          return NotFound(path: routeInformation.location ?? '/');
        },
      );
      delegate.setNewRoutePath(const RouteInformation(location: '/l1'));
    });

    test('beaming to the same location type will not add it to history', () {
      final historyLength = delegate.beamingHistory.length;
      delegate.beamToNamed('/l2/2?q=t&r=s', data: {'x': 'z'});
      expect(delegate.beamingHistory.length, historyLength);
    });

    test('duplicate locations are removed from history', () {
      expect(delegate.beamingHistory.length, 1);
      expect(delegate.beamingHistory[0], isA<Location1>());
      delegate.beamToNamed('/l2');
      expect(delegate.beamingHistory.length, 2);
      expect(delegate.beamingHistory[0], isA<Location1>());
      delegate.beamToNamed('/l1');
      expect(delegate.beamingHistory.length, 2);
      expect(delegate.beamingHistory[0], isA<Location2>());
    });

    test(
        'beamToReplacement removes currentBeamLocation from history before appending new',
        () {
      expect(delegate.beamingHistory.length, 2);
      expect(delegate.beamingHistory[0], isA<Location2>());
      expect(delegate.currentBeamLocation, isA<Location1>());
      delegate.beamToReplacement(
        Location2(const RouteInformation(location: '/l2')),
      );
      expect(delegate.beamingHistory.length, 1);
      expect(delegate.currentBeamLocation, isA<Location2>());
    });

    test('beamToReplacementNamed removes previous history element', () {
      delegate.beamingHistory.clear();
      delegate.beamToNamed('/l1');
      expect(delegate.beamingHistory.length, 1);
      expect(delegate.beamingHistory[0], isA<Location1>());
      expect(delegate.beamingHistoryCompleteLength, 1);

      delegate.beamToNamed('/l2');
      expect(delegate.beamingHistory.length, 2);
      expect(delegate.beamingHistory[0], isA<Location1>());
      expect(delegate.currentBeamLocation, isA<Location2>());
      expect(delegate.beamingHistoryCompleteLength, 2);

      delegate.beamToNamed('/l2/x');
      expect(delegate.beamingHistory.length, 2);
      expect(delegate.beamingHistory[0], isA<Location1>());
      expect(delegate.currentBeamLocation, isA<Location2>());
      expect(delegate.beamingHistory.last.history.length, 2);
      expect(delegate.beamingHistoryCompleteLength, 3);

      delegate.beamToReplacementNamed('/l2/y');
      expect(delegate.beamingHistory.length, 2);
      expect(delegate.beamingHistory[0], isA<Location1>());
      expect(delegate.currentBeamLocation, isA<Location2>());
      expect(delegate.beamingHistory.last.history.length, 2);
      expect(
          delegate
              .beamingHistory.last.history.last.state.routeInformation.location,
          '/l2/y');
      expect(delegate.beamingHistoryCompleteLength, 3);
    });

    test('beamBack leads to previous beam state and all helpers are correct',
        () {
      delegate.beamingHistory
          .removeRange(0, delegate.beamingHistory.length - 1);
      delegate.beamingHistory.last.history
          .removeRange(0, delegate.beamingHistory.last.history.length - 1);
      expect(delegate.beamingHistoryCompleteLength, 1);
      expect(delegate.currentBeamLocation, isA<Location2>());

      delegate.beamToNamed('/l1');
      delegate.beamToNamed('/l2');

      expect(delegate.beamingHistoryCompleteLength, 2);
      expect(delegate.currentBeamLocation, isA<Location2>());
      expect(delegate.canBeamBack, true);

      delegate.beamToNamed('/l1/one');
      delegate.beamToNamed('/l1/two');
      expect(delegate.beamingHistoryCompleteLength, 3);
      expect(delegate.currentBeamLocation, isA<Location1>());

      delegate.beamToNamed('/l1/two');
      expect(delegate.beamingHistoryCompleteLength, 3);
      expect(delegate.currentBeamLocation, isA<Location1>());

      expect(delegate.beamBack(), true);
      expect(delegate.currentBeamLocation, isA<Location1>());
      expect((delegate.currentBeamLocation.state as BeamState).uri.path,
          equals('/l1/one'));
      expect(delegate.beamingHistoryCompleteLength, 2);

      expect(delegate.beamBack(), true);
      expect(delegate.currentBeamLocation, isA<Location2>());
      expect(delegate.beamingHistoryCompleteLength, 1);
    });
  });
}
