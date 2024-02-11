import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'test_locations.dart';

class LocationA extends BeamLocation<BeamState> {
  @override
  List<Pattern> get pathPatterns => ['/a'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      [BeamPage(key: const ValueKey('a'), child: Container())];
}

class LocationB extends BeamLocation<BeamState> {
  @override
  List<Pattern> get pathPatterns => ['/b1', '/b2'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        if (state.pathPatternSegments.contains('b1'))
          BeamPage(key: const ValueKey('b1'), child: Container()),
        if (state.pathPatternSegments.contains('b2'))
          BeamPage(key: const ValueKey('b2'), child: Container()),
      ];
}

void main() {
  group('Beaming history', () {
    TestWidgetsFlutterBinding.ensureInitialized();

    late BeamerDelegate delegate;

    setUp(() {
      delegate = BeamerDelegate(
        locationBuilder: (routeInformation, __) {
          if (routeInformation.location.contains('l1') ?? false) {
            return Location1(routeInformation);
          }
          if (routeInformation.location.contains('l2') ?? false) {
            return Location2(routeInformation);
          }
          if (CustomStateLocation()
              .canHandle(Uri.parse(routeInformation.location ?? '/'))) {
            return CustomStateLocation(routeInformation);
          }
          return NotFound(path: routeInformation.location ?? '/');
        },
      );
    });

    test('beaming to the same location type will not add it to history', () {
      delegate.beamToNamed('/l2');
      final historyLength = delegate.beamingHistory.length;

      delegate.beamToNamed('/l2/2?q=t&r=s', data: {'x': 'z'});
      expect(delegate.beamingHistory.length, historyLength);
    });

    test('duplicate locations are removed from history', () {
      delegate.beamToNamed('/l1');
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
      delegate.beamToNamed('/l2');
      delegate.beamToNamed('/l1');

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
          delegate.beamingHistory.last.history.last.routeInformation.location,
          '/l2/y');
      expect(delegate.beamingHistoryCompleteLength, 3);
    });

    test('beamBack leads to previous beam state and all helpers are correct',
        () {
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

  testWidgets("previously used BeamLocation doesn't keep history",
      (tester) async {
    final delegate = BeamerDelegate(
      initialPath: '/a',
      locationBuilder: BeamerLocationBuilder(
        beamLocations: [LocationA(), LocationB()],
      ),
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: BeamerParser(),
      ),
    );
    expect(delegate.currentBeamLocation, isA<LocationA>());

    delegate.beamToNamed('/b1');
    await tester.pump();
    expect(delegate.currentBeamLocation, isA<LocationB>());
    expect(delegate.currentPages.first.key, const ValueKey('b1'));
    expect(delegate.currentBeamLocation.history.length, 1);

    delegate.beamBack();
    delegate.beamToNamed('/b2');
    await tester.pump();
    expect(delegate.currentBeamLocation, isA<LocationB>());
    expect(delegate.currentPages.first.key, const ValueKey('b2'));
    expect(delegate.currentBeamLocation.history.length, 1);
  });
}
