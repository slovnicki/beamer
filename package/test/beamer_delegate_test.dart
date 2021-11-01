import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final List<BeamPage> lastCurrentPagesFromBuildListner =
      List.empty(growable: true);
  RouteInformation? lastRouteInfoFromRouteListener;
  BeamLocation? lastBeamLocationFromRouteListener;

  final delegate = BeamerDelegate(
    appliedRouteListener: (RouteInformation info, BeamerDelegate delegate) {
      lastRouteInfoFromRouteListener = info;
      lastBeamLocationFromRouteListener = delegate.currentBeamLocation;
    },
    buildListener: (_, BeamerDelegate delegate) {
      lastCurrentPagesFromBuildListner.addAll(delegate.currentPages);
    },
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

  setUp(() {
    lastCurrentPagesFromBuildListner.clear();
  });

  group('initialization & beaming', () {
    test('initialLocation is set', () {
      expect(delegate.currentBeamLocation, isA<Location1>());
    });

    test('beamTo changes locations', () {
      delegate.beamTo(Location2(const RouteInformation(location: '/l2')));
      expect(delegate.currentBeamLocation, isA<Location2>());
    });

    test('beamToNamed updates locations with correct parameters', () {
      delegate.beamToNamed('/l2/2?q=t', data: {'x': 'y'});
      final location = delegate.currentBeamLocation;
      expect(location, isA<Location2>());
      expect(
          (location.state as BeamState).pathParameters.containsKey('id'), true);
      expect((location.state as BeamState).pathParameters['id'], '2');
      expect(
          (location.state as BeamState).queryParameters.containsKey('q'), true);
      expect((location.state as BeamState).queryParameters['q'], 't');
      expect(location.data, {'x': 'y'});
    });

    test(
        'beaming to the same location type will not add it to history but will update current location',
        () {
      final historyLength = delegate.beamingHistory.length;
      delegate.beamToNamed('/l2/2?q=t&r=s', data: {'x': 'z'});
      final location = delegate.currentBeamLocation;
      expect(delegate.beamingHistory.length, historyLength);
      expect(
          (location.state as BeamState).pathParameters.containsKey('id'), true);
      expect((location.state as BeamState).pathParameters['id'], '2');
      expect(
          (location.state as BeamState).queryParameters.containsKey('q'), true);
      expect((location.state as BeamState).queryParameters['q'], 't');
      expect(
          (location.state as BeamState).queryParameters.containsKey('r'), true);
      expect((location.state as BeamState).queryParameters['r'], 's');
      expect(location.data, {'x': 'z'});
    });

    test(
        'popBeamLocation leads to previous location and all helpers are correct',
        () {
      expect(delegate.canPopBeamLocation, true);
      expect(delegate.popBeamLocation(), true);
      expect(delegate.currentBeamLocation, isA<Location1>());

      expect(delegate.canPopBeamLocation, false);
      expect(delegate.popBeamLocation(), false);
      expect(delegate.currentBeamLocation, isA<Location1>());
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
  });

  testWidgets('stacked beam takes just last page for currentPages',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.beamToNamed('/l1/one', stacked: false);
    await tester.pump();
    expect(delegate.currentPages.length, 1);
  });

  testWidgets('routeListener is called when location is applied',
      (tester) async {
    const routeInfo = RouteInformation(location: "/l1");
    delegate.update(configuration: routeInfo);
    expect(lastBeamLocationFromRouteListener, isA<Location1>());
    expect(lastRouteInfoFromRouteListener!.location, equals("/l1"));
  });

  testWidgets('buildListener is called when build is called', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ),
    );
    expect(lastCurrentPagesFromBuildListner.last.key, const ValueKey("l1"));
  });

  test('custom state can be updated', () {
    delegate.beamToNamed('/custom/test');
    expect(
        (delegate.currentBeamLocation as CustomStateLocation).state.customVar,
        'test');
    (delegate.currentBeamLocation as CustomStateLocation)
        .update((state) => CustomState(customVar: 'test-ok'));
    expect(
        (delegate.currentBeamLocation as CustomStateLocation).state.customVar,
        'test-ok');
  });

  test('beamTo works without setting the BeamState explicitly', () {
    delegate.beamTo(NoStateLocation());
    expect(delegate.currentBeamLocation.state, isNotNull);
    delegate.beamBack();
  });

  testWidgets('popToNamed forces pop to specified location', (tester) async {
    delegate.beamingHistory.clear();
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.beamToNamed('/l1/one', popToNamed: '/l2');
    await tester.pump();
    expect(delegate.currentBeamLocation, isA<Location1>());
    delegate.navigator.pop();
    await tester.pump();
    expect(delegate.currentBeamLocation, isA<Location2>());
  });

  test('beamBack leads to previous beam state and all helpers are correct', () {
    delegate.beamingHistory.removeRange(0, delegate.beamingHistory.length - 1);
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

  test('beamBack keeps data and can override it', () {
    delegate.beamingHistory.removeRange(0, delegate.beamingHistory.length - 1);
    delegate.beamingHistory.last.history
        .removeRange(0, delegate.beamingHistory.last.history.length - 1);
    expect(delegate.beamingHistoryCompleteLength, 1);
    expect(delegate.currentBeamLocation, isA<Location2>());

    delegate.beamToNamed('/l1', data: {'x': 'y'});
    delegate.beamToNamed('/l2');

    expect(delegate.beamBack(), true);
    expect(delegate.configuration.location,
        delegate.currentBeamLocation.state.routeInformation.location);
    expect(delegate.configuration.location, '/l1');
    expect(delegate.currentBeamLocation.data, {'x': 'y'});

    delegate.beamToNamed('/l2');

    expect(delegate.beamBack(), true);
    expect(delegate.configuration.location,
        delegate.currentBeamLocation.state.routeInformation.location);
    expect(delegate.configuration.location, '/l1');
    expect(delegate.currentBeamLocation.data, {'x': 'y'});

    delegate.beamToNamed('/l2');

    expect(delegate.beamBack(data: {'xx': 'yy'}), true);
    expect(delegate.configuration.location,
        delegate.currentBeamLocation.state.routeInformation.location);
    expect(delegate.configuration.location, '/l1');
    expect(delegate.currentBeamLocation.data, {'xx': 'yy'});
  });

  testWidgets('popToNamed() beams correctly', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.popToNamed('/l1/one');
    await tester.pump();
    expect(delegate.currentBeamLocation, isA<Location1>());
  });

  testWidgets('notFoundRedirect works', (tester) async {
    final delegate = BeamerDelegate(
      locationBuilder: BeamerLocationBuilder(
        beamLocations: [
          Location1(),
          CustomStateLocation(),
        ],
      ),
      notFoundRedirect: Location1(const RouteInformation()),
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.beamToNamed('/xxx');
    await tester.pump();
    expect(delegate.currentBeamLocation, isA<Location1>());
    expect(delegate.configuration.location, '/');
  });

  testWidgets('notFoundRedirectNamed works', (tester) async {
    final delegate = BeamerDelegate(
      locationBuilder: BeamerLocationBuilder(
        beamLocations: [
          Location1(),
          CustomStateLocation(),
        ],
      ),
      notFoundRedirectNamed: '/',
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.beamToNamed('/xxx');
    await tester.pump();
    expect(delegate.currentBeamLocation, isA<Location1>());
    expect(delegate.configuration.location, '/');
  });

  testWidgets("popping drawer doesn't change BeamState", (tester) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final delegate = BeamerDelegate(
      locationBuilder: RoutesLocationBuilder(
        routes: {
          '/': (context, state) => Container(),
          '/test': (context, state) => Scaffold(
                key: scaffoldKey,
                drawer: const Drawer(),
                body: Container(),
              ),
        },
      ),
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.beamToNamed('/test');
    await tester.pump();
    expect(scaffoldKey.currentState?.isDrawerOpen, isFalse);
    expect(delegate.configuration.location, '/test');

    scaffoldKey.currentState?.openDrawer();
    await tester.pump();
    expect(scaffoldKey.currentState?.isDrawerOpen, isTrue);
    expect(delegate.configuration.location, '/test');

    delegate.navigatorKey.currentState?.pop();
    await tester.pump();
    expect(scaffoldKey.currentState?.isDrawerOpen, isFalse);
    expect(delegate.configuration.location, '/test');
  });

  group('Keeping data', () {
    final delegate = BeamerDelegate(
      locationBuilder: (routeInformation, _) {
        if (routeInformation.location?.contains('l1') ?? false) {
          return Location1(routeInformation);
        }
        if (routeInformation.location?.contains('l2') ?? false) {
          return Location2(routeInformation);
        }
        return NotFound(path: routeInformation.location ?? '/');
      },
    );
    testWidgets('pop keeps data', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/l1/one', data: {'x': 'y'});
      await tester.pump();
      expect((delegate.currentBeamLocation.state as BeamState).uri.path,
          '/l1/one');
      expect(delegate.currentBeamLocation.data, {'x': 'y'});

      delegate.navigatorKey.currentState!.pop();
      await tester.pump();
      expect((delegate.currentBeamLocation.state as BeamState).uri.path, '/l1');
      expect(delegate.currentBeamLocation.data, {'x': 'y'});
    });

    test('single location keeps data', () {
      delegate.beamToNamed('/l1', data: {'x': 'y'});
      expect(delegate.currentBeamLocation.data, {'x': 'y'});

      delegate.beamToNamed('/l1/one');
      expect(delegate.currentBeamLocation.data, {'x': 'y'});
    });

    test('data is not kept throughout locations', () {
      delegate.beamToNamed('/l1', data: {'x': 'y'});
      expect(delegate.currentBeamLocation.data, {'x': 'y'});

      delegate.beamToNamed('/l2');
      expect(delegate.currentBeamLocation.data, isNot({'x': 'y'}));
    });

    test('data is not kept if overwritten', () {
      delegate.beamToNamed('/l1', data: {'x': 'y'});
      expect(delegate.currentBeamLocation.data, {'x': 'y'});
      delegate.beamToNamed('/l1/one', data: {});
      expect(delegate.currentBeamLocation.data, {});

      delegate.beamToNamed('/l1', data: {'x': 'y'});
      expect(delegate.currentBeamLocation.data, {'x': 'y'});
      delegate.beamToNamed('/l2', data: {});
      expect(delegate.currentBeamLocation.data, {});
    });
  });

  group('Updating from parent', () {
    testWidgets('navigation on parent updates nested Beamer', (tester) async {
      final childDelegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
            '/test2': (context, state) => Container(),
          },
        ),
      );
      final rootDelegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '*': (context, state) => BeamPage(
                  key: const ValueKey('always-the-same'),
                  child: Beamer(
                    routerDelegate: childDelegate,
                  ),
                ),
          },
        ),
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: rootDelegate,
        ),
      );

      rootDelegate.beamToNamed('/test');
      await tester.pump();
      expect(rootDelegate.configuration.location, '/test');
      expect(childDelegate.configuration.location, '/test');
      expect(childDelegate.beamingHistory.last.history.length, 1);

      rootDelegate.beamToNamed('/test2');
      await tester.pump();
      expect(rootDelegate.configuration.location, '/test2');
      expect(childDelegate.configuration.location, '/test2');
      expect(childDelegate.beamingHistory.last.history.length, 2);
    });

    testWidgets("navigation on parent doesn't update nested Beamer",
        (tester) async {
      final childDelegate = BeamerDelegate(
        updateFromParent: false,
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
            '/test2': (context, state) => Container(),
          },
        ),
      );
      final rootDelegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '*': (context, state) => BeamPage(
                  key: const ValueKey('always-the-same'),
                  child: Beamer(
                    routerDelegate: childDelegate,
                  ),
                ),
          },
        ),
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: rootDelegate,
        ),
      );

      rootDelegate.beamToNamed('/test'); // initial will update
      await tester.pump();
      expect(rootDelegate.configuration.location, '/test');
      expect(childDelegate.configuration.location, '/test');
      expect(childDelegate.beamingHistory.last.history.length, 1);

      rootDelegate.beamToNamed('/test2');
      await tester.pump();
      expect(rootDelegate.configuration.location, '/test2');
      expect(childDelegate.configuration.location, '/test');
      expect(childDelegate.beamingHistory.last.history.length, 1);
    });
  });

  testWidgets(
      "updating route information without updating parent or rebuilding",
      (tester) async {
    final childDelegate = BeamerDelegate(
      updateParent: false,
      locationBuilder: RoutesLocationBuilder(
        routes: {
          '/': (context, state) => Container(),
          '/test': (context, state) => Container(),
          '/test2': (context, state) => Container(),
        },
      ),
    );
    final rootDelegate = BeamerDelegate(
      locationBuilder: RoutesLocationBuilder(
        routes: {
          '*': (context, state) => BeamPage(
                key: const ValueKey('always-the-same'),
                child: Beamer(
                  routerDelegate: childDelegate,
                ),
              ),
        },
      ),
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: rootDelegate,
      ),
    );

    rootDelegate.beamToNamed('/test');
    await tester.pump();

    expect(rootDelegate.configuration.location, '/test');
    expect(childDelegate.configuration.location, '/test');
    expect(childDelegate.parent, rootDelegate);

    childDelegate.beamToNamed('/test2');
    await tester.pump();

    expect(rootDelegate.configuration.location, '/test');
    expect(childDelegate.configuration.location, '/test2');

    childDelegate.update(
      configuration: const RouteInformation(location: '/xx'),
      rebuild: false,
    );
    expect(rootDelegate.configuration.location, '/test');
    expect(childDelegate.configuration.location, '/xx');
  });

  group('clearBeamingHistoryOn:', () {
    testWidgets("history is cleared when beamToNamed", (tester) async {
      final delegate = BeamerDelegate(
        initialPath: '/test',
        clearBeamingHistoryOn: {'/'},
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
            '/test/deeper': (context, state) => Container(),
          },
        ),
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );

      delegate.beamToNamed('/test/deeper');
      await tester.pump();
      expect(delegate.configuration.location, '/test/deeper');
      expect(delegate.beamingHistory.last.history.length, 2);

      delegate.beamToNamed('/');
      await tester.pump(const Duration(milliseconds: 16));
      expect(delegate.configuration.location, '/');
      expect(delegate.beamingHistory.last.history.length, 1);
    });

    testWidgets("history is always cleared when popToNamed", (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
            '/test/deeper': (context, state) => Container(),
          },
        ),
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );

      delegate.beamToNamed('/test');
      await tester.pump();
      expect(delegate.configuration.location, '/test');
      expect(delegate.beamingHistory.last.history.length, 2);

      delegate.beamToNamed('/test/deeper');
      await tester.pump();
      expect(delegate.configuration.location, '/test/deeper');
      expect(delegate.beamingHistory.last.history.length, 3);

      delegate.popToNamed('/');
      await tester.pump(const Duration(milliseconds: 16));
      expect(delegate.configuration.location, '/');
      expect(delegate.beamingHistory.last.history.length, 1);
    });

    testWidgets("history is cleared regardless, if option is set",
        (tester) async {
      final delegate = BeamerDelegate(
        clearBeamingHistoryOn: {'/'},
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
            '/test/deeper': (context, state) => Container(),
          },
        ),
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );

      delegate.beamToNamed('/test');
      await tester.pump();
      expect(delegate.configuration.location, '/test');
      expect(delegate.beamingHistory.last.history.length, 2);

      delegate.beamToNamed('/test/deeper');
      await tester.pump();
      expect(delegate.configuration.location, '/test/deeper');
      expect(delegate.beamingHistory.last.history.length, 3);

      delegate.beamToNamed('/');
      await tester.pump(const Duration(milliseconds: 16));
      expect(delegate.configuration.location, '/');
      expect(delegate.beamingHistory.last.history.length, 1);

      delegate.beamToNamed('/test/deeper');
      await tester.pump();
      expect(delegate.configuration.location, '/test/deeper');
      expect(delegate.beamingHistory.last.history.length, 2);

      delegate.popToNamed('/');
      await tester.pump(const Duration(seconds: 1));
      expect(delegate.configuration.location, '/');
      expect(delegate.beamingHistory.last.history.length, 1);
    });

    testWidgets("history is cleared regardless, if option is set",
        (tester) async {
      final delegate = BeamerDelegate(
        clearBeamingHistoryOn: {'/test'},
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
            '/test/deeper': (context, state) => Container(),
          },
        ),
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );

      expect(delegate.configuration.location, '/');
      expect(delegate.beamingHistory.last.history.length, 1);

      delegate.beamToNamed('/test');
      await tester.pump();
      expect(delegate.configuration.location, '/test');
      expect(delegate.beamingHistory.last.history.length, 1);

      delegate.beamToNamed('/test/deeper');
      await tester.pump();
      expect(delegate.configuration.location, '/test/deeper');
      expect(delegate.beamingHistory.last.history.length, 2);

      delegate.beamToNamed('/');
      await tester.pump(const Duration(milliseconds: 16));
      expect(delegate.configuration.location, '/');
      expect(delegate.beamingHistory.last.history.length, 3);

      delegate.beamToNamed('/test');
      await tester.pump();
      expect(delegate.configuration.location, '/test');
      expect(delegate.beamingHistory.last.history.length, 1);
    });
  });
}
