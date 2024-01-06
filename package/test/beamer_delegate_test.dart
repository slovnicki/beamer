import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final lastCurrentPagesFromBuildListner = List.empty(growable: true);
  RouteInformation? lastRouteInfoFromRouteListener;
  BeamLocation? lastBeamLocationFromRouteListener;
  late BeamerDelegate delegate;

  setUp(() {
    delegate = BeamerDelegate(
      initialPath: '/l1',
      routeListener: (RouteInformation info, BeamerDelegate delegate) {
        lastRouteInfoFromRouteListener = info;
        lastBeamLocationFromRouteListener = delegate.currentBeamLocation;
      },
      buildListener: (_, BeamerDelegate delegate) {
        lastCurrentPagesFromBuildListner.addAll(delegate.currentPages);
      },
      locationBuilder: (routeInformation, __) {
        if (routeInformation.uri.path.contains('l1')) {
          return Location1(routeInformation);
        }
        if (routeInformation.uri.path.contains('l2')) {
          return Location2(routeInformation);
        }
        if (CustomStateLocation().canHandle(routeInformation.uri)) {
          return CustomStateLocation(routeInformation);
        }
        return NotFound(path: routeInformation.uri.toString());
      },
    );
    lastCurrentPagesFromBuildListner.clear();
  });

  group('initialization & beaming', () {
    testWidgets('initialLocation is set', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      expect(delegate.currentBeamLocation, isA<Location1>());
    });

    test('beamTo changes locations', () {
      delegate.beamTo(Location2(RouteInformation(uri: Uri.parse('/l2'))));
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
        'popBeamLocation leads to previous location and all helpers are correct',
        () {
      delegate.beamToNamed('/l1');
      delegate.beamToNamed('/l2');

      expect(delegate.canPopBeamLocation, true);
      expect(delegate.popBeamLocation(), true);
      expect(delegate.currentBeamLocation, isA<Location1>());

      expect(delegate.canPopBeamLocation, false);
      expect(delegate.popBeamLocation(), false);
      expect(delegate.currentBeamLocation, isA<Location1>());
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

  testWidgets('routeListener is called when update is called', (tester) async {
    final routeInfo = RouteInformation(uri: Uri.parse('/l1'));
    delegate.update(configuration: routeInfo);
    expect(lastBeamLocationFromRouteListener, isA<Location1>());
    expect(lastRouteInfoFromRouteListener!.uri.path, equals('/l1'));
  });

  testWidgets('buildListener is called when build is called', (tester) async {
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ),
    );
    expect(lastCurrentPagesFromBuildListner.last.key, const ValueKey('l1'));
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

  group('popToNamed parameter', () {
    testWidgets('forces pop to specified location', (tester) async {
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

    testWidgets('is a one-time thing', (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (_, __, ___) => Container(),
            '/test': (_, __, ___) => Container(),
            '/test/one': (_, __, ___) => Container(),
            '/test/one/two': (_, __, ___) => Container(),
          },
        ),
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/test/one/two', popToNamed: '/test');
      await tester.pump();
      expect(delegate.configuration.uri.path, '/test/one/two');
      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.configuration.uri.path, '/test');

      delegate.beamToNamed('/test/one/two');
      await tester.pump();
      expect(delegate.configuration.uri.path, '/test/one/two');
      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.configuration.uri.path, '/test/one');
    });
  });

  test('beamBack keeps data and can override it', () {
    delegate.beamToNamed('/l1', data: {'x': 'y'});
    delegate.beamToNamed('/l2');

    expect(delegate.beamBack(), true);
    expect(delegate.configuration.uri,
        delegate.currentBeamLocation.state.routeInformation.uri);
    expect(delegate.configuration.uri.path, '/l1');
    expect(delegate.currentBeamLocation.data, {'x': 'y'});

    delegate.beamToNamed('/l2');

    expect(delegate.beamBack(), true);
    expect(delegate.configuration.uri,
        delegate.currentBeamLocation.state.routeInformation.uri);
    expect(delegate.configuration.uri.path, '/l1');
    expect(delegate.currentBeamLocation.data, {'x': 'y'});

    delegate.beamToNamed('/l2');

    expect(delegate.beamBack(data: {'xx': 'yy'}), true);
    expect(delegate.configuration.uri,
        delegate.currentBeamLocation.state.routeInformation.uri);
    expect(delegate.configuration.uri.path, '/l1');
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
      notFoundRedirect: Location1(RouteInformation(uri: Uri.parse('/'))),
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
    expect(delegate.configuration.uri.path, '/');
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
    expect(delegate.configuration.uri.path, '/');
  });

  testWidgets("popping drawer doesn't change BeamState", (tester) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final delegate = BeamerDelegate(
      locationBuilder: RoutesLocationBuilder(
        routes: {
          '/': (context, state, data) => Container(),
          '/test': (context, state, data) => Scaffold(
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
    expect(delegate.configuration.uri.path, '/test');

    scaffoldKey.currentState?.openDrawer();
    await tester.pumpAndSettle();
    expect(scaffoldKey.currentState?.isDrawerOpen, isTrue);
    expect(delegate.configuration.uri.path, '/test');

    delegate.navigatorKey.currentState?.pop();
    await tester.pumpAndSettle();
    expect(scaffoldKey.currentState?.isDrawerOpen, isFalse);
    expect(delegate.configuration.uri.path, '/test');
  });

  group('Keeping data', () {
    final delegate = BeamerDelegate(
      locationBuilder: (routeInformation, _) {
        if (routeInformation.uri.path.contains('l1')) {
          return Location1(routeInformation);
        }
        if (routeInformation.uri.path.contains('l2')) {
          return Location2(routeInformation);
        }
        return NotFound(path: routeInformation.uri.path);
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
            '/': (context, state, data) => const Text('/'),
            '/test': (context, state, data) => const Text('/test'),
            '/test2': (context, state, data) => const Text('/test2'),
          },
        ),
      );
      final rootDelegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '*': (context, state, data) => BeamPage(
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
      // initial will update history with /

      rootDelegate.beamToNamed('/test');
      await tester.pump();
      expect(find.text('/test'), findsOneWidget);
      expect(rootDelegate.configuration.uri.path, '/test');
      expect(childDelegate.configuration.uri.path, '/test');
      expect(childDelegate.beamingHistory.last.history.length, 2);

      rootDelegate.beamToNamed('/test2');
      await tester.pump();
      expect(find.text('/test2'), findsOneWidget);
      expect(rootDelegate.configuration.uri.path, '/test2');
      expect(childDelegate.configuration.uri.path, '/test2');
      expect(childDelegate.beamingHistory.last.history.length, 3);
    });

    testWidgets("navigation on parent doesn't update nested Beamer",
        (tester) async {
      final childDelegate = BeamerDelegate(
        initializeFromParent: false,
        updateFromParent: false,
        updateParent: false,
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
            '/test2': (context, state, data) => Container(),
          },
        ),
      );
      final rootDelegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '*': (context, state, data) => BeamPage(
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
      await tester.pumpAndSettle();
      expect(rootDelegate.configuration.uri.path, '/test');
      expect(childDelegate.configuration.uri.path, childDelegate.initialPath);
      expect(childDelegate.beamingHistory.last.history.length, 1);

      rootDelegate.beamToNamed('/test2');
      await tester.pump();
      expect(rootDelegate.configuration.uri.path, '/test2');
      expect(childDelegate.configuration.uri.path, childDelegate.initialPath);
      expect(childDelegate.beamingHistory.last.history.length, 1);
    });
  });

  group('update without rebuild', () {
    test('no rebuild updates route information (configuration) to anything',
        () {
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (_, __, ___) => Container(),
            '/test': (_, __, ___) => Container(),
          },
        ),
      );

      expect(delegate.configuration.uri.path, '/');

      delegate.update(
        configuration: RouteInformation(uri: Uri.parse('/test')),
        rebuild: false,
      );
      expect(delegate.configuration.uri.path, '/test');

      delegate.update(
        configuration: RouteInformation(uri: Uri.parse('/any')),
        rebuild: false,
      );
      expect(delegate.configuration.uri.path, '/any');
    });

    testWidgets(
        'updating route information without updating parent or rebuilding',
        (tester) async {
      final childDelegate = BeamerDelegate(
        updateParent: false,
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
            '/test2': (context, state, data) => Container(),
          },
        ),
      );
      final rootDelegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '*': (context, state, data) => BeamPage(
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

      expect(rootDelegate.configuration.uri.path, '/test');
      expect(childDelegate.configuration.uri.path, '/test');
      expect(childDelegate.parent, rootDelegate);

      childDelegate.beamToNamed('/test2');
      await tester.pump();

      expect(rootDelegate.configuration.uri.path, '/test');
      expect(childDelegate.configuration.uri.path, '/test2');

      childDelegate.update(
        configuration: RouteInformation(uri: Uri.parse('/xx')),
        rebuild: false,
      );
      expect(rootDelegate.configuration.uri.path, '/test');
      expect(childDelegate.configuration.uri.path, '/xx');
    });
  });

  group('clearBeamingHistoryOn:', () {
    testWidgets('history is cleared when beamToNamed', (tester) async {
      final delegate = BeamerDelegate(
        initialPath: '/test',
        clearBeamingHistoryOn: {'/'},
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
            '/test/deeper': (context, state, data) => Container(),
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
      expect(delegate.configuration.uri.path, '/test/deeper');
      expect(delegate.beamingHistory.last.history.length, 2);

      delegate.beamToNamed('/');
      await tester.pump(const Duration(milliseconds: 16));
      expect(delegate.configuration.uri.path, '/');
      expect(delegate.beamingHistory.last.history.length, 1);
    });

    testWidgets('history is always cleared when popToNamed', (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
            '/test/deeper': (context, state, data) => Container(),
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
      expect(delegate.configuration.uri.path, '/test');
      expect(delegate.beamingHistory.last.history.length, 2);

      delegate.beamToNamed('/test/deeper');
      await tester.pump();
      expect(delegate.configuration.uri.path, '/test/deeper');
      expect(delegate.beamingHistory.last.history.length, 3);

      delegate.popToNamed('/');
      await tester.pump(const Duration(milliseconds: 16));
      expect(delegate.configuration.uri.path, '/');
      expect(delegate.beamingHistory.last.history.length, 1);
    });

    testWidgets('history is cleared regardless, if option is set',
        (tester) async {
      final delegate = BeamerDelegate(
        clearBeamingHistoryOn: {'/'},
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
            '/test/deeper': (context, state, data) => Container(),
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
      expect(delegate.configuration.uri.path, '/test');
      expect(delegate.beamingHistory.last.history.length, 2);

      delegate.beamToNamed('/test/deeper');
      await tester.pump();
      expect(delegate.configuration.uri.path, '/test/deeper');
      expect(delegate.beamingHistory.last.history.length, 3);

      delegate.beamToNamed('/');
      await tester.pump(const Duration(milliseconds: 16));
      expect(delegate.configuration.uri.path, '/');
      expect(delegate.beamingHistory.last.history.length, 1);

      delegate.beamToNamed('/test/deeper');
      await tester.pump();
      expect(delegate.configuration.uri.path, '/test/deeper');
      expect(delegate.beamingHistory.last.history.length, 2);

      delegate.popToNamed('/');
      await tester.pump(const Duration(seconds: 1));
      expect(delegate.configuration.uri.path, '/');
      expect(delegate.beamingHistory.last.history.length, 1);
    });

    testWidgets('history is cleared regardless, if option is set',
        (tester) async {
      final delegate = BeamerDelegate(
        clearBeamingHistoryOn: {'/test'},
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
            '/test/deeper': (context, state, data) => Container(),
          },
        ),
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );

      expect(delegate.configuration.uri.path, '/');
      expect(delegate.beamingHistory.last.history.length, 1);

      delegate.beamToNamed('/test');
      await tester.pump();
      expect(delegate.configuration.uri.path, '/test');
      expect(delegate.beamingHistory.last.history.length, 1);

      delegate.beamToNamed('/test/deeper');
      await tester.pump();
      expect(delegate.configuration.uri.path, '/test/deeper');
      expect(delegate.beamingHistory.last.history.length, 2);

      delegate.beamToNamed('/');
      await tester.pump(const Duration(milliseconds: 16));
      expect(delegate.configuration.uri.path, '/');
      expect(delegate.beamingHistory.last.history.length, 3);

      delegate.beamToNamed('/test');
      await tester.pump();
      expect(delegate.configuration.uri.path, '/test');
      expect(delegate.beamingHistory.last.history.length, 1);
    });
  });

  testWidgets('updateListenable', (tester) async {
    final guardCheck = ValueNotifier<bool>(true);

    final delegate = BeamerDelegate(
      initialPath: '/r1',
      locationBuilder: RoutesLocationBuilder(
        routes: {
          '/r1': (context, state, data) => Container(),
          '/r2': (context, state, data) => Container(),
        },
      ),
      guards: [
        BeamGuard(
          pathPatterns: ['/r1'],
          check: (_, __) => guardCheck.value,
          beamToNamed: (_, __) => '/r2',
        ),
      ],
      updateListenable: guardCheck,
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.configuration.uri.path, '/r1');

    guardCheck.value = false;

    expect(delegate.configuration.uri.path, '/r2');
  });

  group('Relative beaming', () {
    test('incoming configuration is appended when it does not start with /',
        () {
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/t1': (context, state, data) => Container(),
            '/t1/t2': (context, state, data) => Container(),
          },
        ),
      );

      delegate.beamToNamed('t1');
      expect(delegate.configuration.uri.path, '/t1');
      expect(
          delegate.currentBeamLocation.state.routeInformation.uri.path, '/t1');

      delegate.beamToNamed('t2');
      expect(delegate.configuration.uri.path, '/t1/t2');
      expect(delegate.currentBeamLocation.state.routeInformation.uri.path,
          '/t1/t2');
    });
  });

  test('Properly preserve history part when using popToNamed(...)', () {
    final delegate = BeamerDelegate(
      locationBuilder: RoutesLocationBuilder(
        routes: {
          '/': (context, state, data) => Container(),
          '/t1': (context, state, data) => Container(),
          '/t2': (context, state, data) => Container(),
          '/t3': (context, state, data) => Container(),
        },
      ),
    );
    delegate.beamToNamed('/t1');
    delegate.beamToNamed('/t2');
    delegate.beamToNamed('/t3');
    delegate.popToNamed('/t2');

    expect(
        delegate.currentBeamLocation.history
            .map((HistoryElement e) => e.routeInformation.uri.path),
        orderedEquals(<String>['/t1', '/t2']));
  });
}
