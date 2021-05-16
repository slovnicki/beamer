import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final router = BeamerDelegate(
    locationBuilder: (state) {
      if (state.uri.pathSegments.contains('l1')) {
        return Location1(state);
      }
      if (state.uri.pathSegments.contains('l2')) {
        return Location2(state);
      }
      if (CustomStateLocation().canHandle(state.uri)) {
        return CustomStateLocation();
      }
      return NotFound(path: state.uri.toString());
    },
  );
  router.setNewRoutePath(BeamState.fromUri(Uri.parse('/l1')));

  group('initialization & beaming', () {
    test('initialLocation is set', () {
      expect(router.currentBeamLocation, isA<Location1>());
    });

    test('beamTo changes locations', () {
      router.beamTo(Location2(BeamState.fromUri(Uri.parse('/l2'))));
      expect(router.currentBeamLocation, isA<Location2>());
    });

    test('beamToNamed updates locations with correct parameters', () {
      router.beamToNamed('/l2/2?q=t', data: {'x': 'y'});
      final location = router.currentBeamLocation;
      expect(location, isA<Location2>());
      expect(location.state.pathParameters.containsKey('id'), true);
      expect(location.state.pathParameters['id'], '2');
      expect(location.state.queryParameters.containsKey('q'), true);
      expect(location.state.queryParameters['q'], 't');
      expect(location.state.data, {'x': 'y'});
    });

    test(
        'beaming to the same location type will not add it to history but will update current location',
        () {
      final historyLength = router.beamLocationHistory.length;
      router.beamToNamed('/l2/2?q=t&r=s', data: {'x': 'z'});
      final location = router.currentBeamLocation;
      expect(router.beamLocationHistory.length, historyLength);
      expect(location.state.pathParameters.containsKey('id'), true);
      expect(location.state.pathParameters['id'], '2');
      expect(location.state.queryParameters.containsKey('q'), true);
      expect(location.state.queryParameters['q'], 't');
      expect(location.state.queryParameters.containsKey('r'), true);
      expect(location.state.queryParameters['r'], 's');
      expect(location.state.data, {'x': 'z'});
    });

    test(
        'popBeamLocation leads to previous location and all helpers are correct',
        () {
      expect(router.canPopBeamLocation, true);
      expect(router.popBeamLocation(), true);
      expect(router.currentBeamLocation, isA<Location1>());

      expect(router.canPopBeamLocation, false);
      expect(router.popBeamLocation(), false);
      expect(router.currentBeamLocation, isA<Location1>());
    });

    test('duplicate locations are removed from history', () {
      expect(router.beamLocationHistory.length, 1);
      expect(router.beamLocationHistory[0], isA<Location1>());
      router.beamToNamed('/l2');
      expect(router.beamLocationHistory.length, 2);
      expect(router.beamLocationHistory[0], isA<Location1>());
      router.beamToNamed('/l1');
      expect(router.beamLocationHistory.length, 2);
      expect(router.beamLocationHistory[0], isA<Location2>());
    });

    test(
        'beamTo replaceCurrent removes previous history state before appending new',
        () {
      expect(router.beamLocationHistory.length, 2);
      expect(router.beamLocationHistory[0], isA<Location2>());
      expect(router.currentBeamLocation, isA<Location1>());
      router.beamTo(
        Location2(BeamState.fromUri(Uri.parse('/l2'))),
        replaceCurrent: true,
      );
      expect(router.beamLocationHistory.length, 1);
      expect(router.currentBeamLocation, isA<Location2>());
    });
  });

  testWidgets('stacked beam takes just last page for currentPages',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: router,
      ),
    );
    router.beamToNamed('/l1/one', stacked: false);
    await tester.pump();
    expect(router.currentPages.length, 1);
  });

  test('custom state can be updated', () {
    router.beamToNamed('/custom');
    expect((router.currentBeamLocation as CustomStateLocation).state.customVar,
        'test');
    (router.currentBeamLocation as CustomStateLocation)
        .update((state) => state.copyWith(customVar: 'test-ok'));
    expect((router.currentBeamLocation as CustomStateLocation).state.customVar,
        'test-ok');
  });

  test('beamTo works without setting the BeamState explicitly', () {
    router.beamTo(NoStateLocation());
    expect(router.currentBeamLocation.state, isNotNull);
    router.beamBack();
  });

  test('clearHistory removes all but last entry (current location)', () {
    final currentBeamLocation = router.currentBeamLocation;
    expect(router.beamLocationHistory.length, greaterThan(1));
    router.clearBeamLocationHistory();
    expect(router.beamLocationHistory.length, equals(1));
    expect(router.currentBeamLocation, currentBeamLocation);
  });

  testWidgets('popToNamed forces pop to specified location', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: router,
      ),
    );
    router.beamToNamed('/l1/one', popToNamed: '/l2');
    await tester.pump();
    final historyLength = router.beamLocationHistory.length;
    expect(router.currentBeamLocation, isA<Location1>());
    await router.popRoute();
    await tester.pump();
    expect(router.currentBeamLocation, isA<Location2>());
    expect(router.beamLocationHistory.length, equals(historyLength));
  });

  test('beamBack leads to previous beam state and all helpers are correct', () {
    router.clearBeamStateHistory();
    expect(router.beamStateHistory.length, 1);
    expect(router.currentBeamLocation, isA<Location2>());

    router.beamToNamed('/l1');
    router.beamToNamed('/l2');

    expect(router.beamStateHistory.length, 3);
    expect(router.currentBeamLocation, isA<Location2>());
    expect(router.canBeamBack, true);

    router.beamToNamed('/l1/one');
    router.beamToNamed('/l1/two');
    expect(router.beamStateHistory.length, 5);
    expect(router.currentBeamLocation, isA<Location1>());

    router.beamToNamed('/l1/two');
    expect(router.beamStateHistory.length, 5);
    expect(router.currentBeamLocation, isA<Location1>());

    expect(router.beamBack(), true);
    expect(router.currentBeamLocation, isA<Location1>());
    expect(router.currentBeamLocation.state.uri.path, equals('/l1/one'));
    expect(router.beamStateHistory.length, 4);

    expect(router.beamBack(), true);
    expect(router.currentBeamLocation, isA<Location2>());
    expect(router.beamStateHistory.length, 3);
  });

  testWidgets('popToNamed() beams correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: router,
      ),
    );
    router.popToNamed('/l1/one');
    await tester.pump();
    expect(router.currentBeamLocation, isA<Location1>());
  });
}
