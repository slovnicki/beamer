import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_stacks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final lastCurrentPagesFromBuildListner = List.empty(growable: true);
  RouteInformation? lastRouteInfoFromRouteListener;
  BeamStack? lastBeamStackFromRouteListener;
  late BeamerDelegate delegate;

  setUp(() {
    delegate = BeamerDelegate(
      initialPath: '/l1',
      routeListener: (RouteInformation info, BeamerDelegate delegate) {
        lastRouteInfoFromRouteListener = info;
        lastBeamStackFromRouteListener = delegate.currentBeamStack;
      },
      buildListener: (_, BeamerDelegate delegate) {
        lastCurrentPagesFromBuildListner.addAll(delegate.currentPages);
      },
      stackBuilder: (routeInformation, __) {
        if (routeInformation.uri.path.contains('l1')) {
          return Stack1(routeInformation);
        }
        if (routeInformation.uri.path.contains('l2')) {
          return Stack2(routeInformation);
        }
        if (CustomStateStack().canHandle(routeInformation.uri)) {
          return CustomStateStack(routeInformation);
        }
        return NotFound(path: routeInformation.uri.toString());
      },
    );
    lastCurrentPagesFromBuildListner.clear();
  });

  group('initialization & beaming', () {
    testWidgets('initialStack is set', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      expect(delegate.currentBeamStack, isA<Stack1>());
    });

    test('beamTo changes stacks', () {
      delegate.beamTo(Stack2(RouteInformation(uri: Uri.parse('/l2'))));
      expect(delegate.currentBeamStack, isA<Stack2>());
    });

    test('beamToNamed updates stacks with correct parameters', () {
      delegate.beamToNamed('/l2/2?q=t', data: {'x': 'y'});
      final stack = delegate.currentBeamStack;
      expect(stack, isA<Stack2>());
      expect((stack.state as BeamState).pathParameters.containsKey('id'), true);
      expect((stack.state as BeamState).pathParameters['id'], '2');
      expect((stack.state as BeamState).queryParameters.containsKey('q'), true);
      expect((stack.state as BeamState).queryParameters['q'], 't');
      expect(stack.data, {'x': 'y'});
    });

    test('popBeamStack leads to previous stack and all helpers are correct', () {
      delegate.beamToNamed('/l1');
      delegate.beamToNamed('/l2');

      expect(delegate.canPopBeamStack, true);
      expect(delegate.popBeamStack(), true);
      expect(delegate.currentBeamStack, isA<Stack1>());

      expect(delegate.canPopBeamStack, false);
      expect(delegate.popBeamStack(), false);
      expect(delegate.currentBeamStack, isA<Stack1>());
    });
  });

  testWidgets('stacked beam takes just last page for currentPages', (tester) async {
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
    expect(lastBeamStackFromRouteListener, isA<Stack1>());
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
    expect((delegate.currentBeamStack as CustomStateStack).state.customVar, 'test');
    (delegate.currentBeamStack as CustomStateStack).update((state) => CustomState(customVar: 'test-ok'));
    expect((delegate.currentBeamStack as CustomStateStack).state.customVar, 'test-ok');
  });

  test('beamTo works without setting the BeamState explicitly', () {
    delegate.beamTo(NoStateStack());
    expect(delegate.currentBeamStack.state, isNotNull);
    delegate.beamBack();
  });

  group('popToNamed parameter', () {
    testWidgets('forces pop to specified stack', (tester) async {
      delegate.beamingHistory.clear();
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/l1/one', popToNamed: '/l2');
      await tester.pump();
      expect(delegate.currentBeamStack, isA<Stack1>());
      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentBeamStack, isA<Stack2>());
    });

    testWidgets('is a one-time thing', (tester) async {
      final delegate = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
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
    expect(delegate.configuration.uri, delegate.currentBeamStack.state.routeInformation.uri);
    expect(delegate.configuration.uri.path, '/l1');
    expect(delegate.currentBeamStack.data, {'x': 'y'});

    delegate.beamToNamed('/l2');

    expect(delegate.beamBack(), true);
    expect(delegate.configuration.uri, delegate.currentBeamStack.state.routeInformation.uri);
    expect(delegate.configuration.uri.path, '/l1');
    expect(delegate.currentBeamStack.data, {'x': 'y'});

    delegate.beamToNamed('/l2');

    expect(delegate.beamBack(data: {'xx': 'yy'}), true);
    expect(delegate.configuration.uri, delegate.currentBeamStack.state.routeInformation.uri);
    expect(delegate.configuration.uri.path, '/l1');
    expect(delegate.currentBeamStack.data, {'xx': 'yy'});
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
    expect(delegate.currentBeamStack, isA<Stack1>());
  });

  testWidgets('notFoundRedirect works', (tester) async {
    final delegate = BeamerDelegate(
      stackBuilder: BeamerStackBuilder(
        beamStacks: [
          Stack1(),
          CustomStateStack(),
        ],
      ),
      notFoundRedirect: Stack1(RouteInformation(uri: Uri.parse('/'))),
    );
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ),
    );
    delegate.beamToNamed('/xxx');
    await tester.pump();
    expect(delegate.currentBeamStack, isA<Stack1>());
    expect(delegate.configuration.uri.path, '/');
  });

  testWidgets('notFoundRedirectNamed works', (tester) async {
    final delegate = BeamerDelegate(
      stackBuilder: BeamerStackBuilder(
        beamStacks: [
          Stack1(),
          CustomStateStack(),
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
    expect(delegate.currentBeamStack, isA<Stack1>());
    expect(delegate.configuration.uri.path, '/');
  });

  testWidgets("popping drawer doesn't change BeamState", (tester) async {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final delegate = BeamerDelegate(
      stackBuilder: RoutesStackBuilder(
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
      stackBuilder: (routeInformation, _) {
        if (routeInformation.uri.path.contains('l1')) {
          return Stack1(routeInformation);
        }
        if (routeInformation.uri.path.contains('l2')) {
          return Stack2(routeInformation);
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
      expect((delegate.currentBeamStack.state as BeamState).uri.path, '/l1/one');
      expect(delegate.currentBeamStack.data, {'x': 'y'});

      delegate.navigatorKey.currentState!.pop();
      await tester.pump();
      expect((delegate.currentBeamStack.state as BeamState).uri.path, '/l1');
      expect(delegate.currentBeamStack.data, {'x': 'y'});
    });

    test('single stack keeps data', () {
      delegate.beamToNamed('/l1', data: {'x': 'y'});
      expect(delegate.currentBeamStack.data, {'x': 'y'});

      delegate.beamToNamed('/l1/one');
      expect(delegate.currentBeamStack.data, {'x': 'y'});
    });

    test('data is not kept throughout stacks', () {
      delegate.beamToNamed('/l1', data: {'x': 'y'});
      expect(delegate.currentBeamStack.data, {'x': 'y'});

      delegate.beamToNamed('/l2');
      expect(delegate.currentBeamStack.data, isNot({'x': 'y'}));
    });

    test('data is not kept if overwritten', () {
      delegate.beamToNamed('/l1', data: {'x': 'y'});
      expect(delegate.currentBeamStack.data, {'x': 'y'});
      delegate.beamToNamed('/l1/one', data: {});
      expect(delegate.currentBeamStack.data, {});

      delegate.beamToNamed('/l1', data: {'x': 'y'});
      expect(delegate.currentBeamStack.data, {'x': 'y'});
      delegate.beamToNamed('/l2', data: {});
      expect(delegate.currentBeamStack.data, {});
    });
  });

  group('Updating from parent', () {
    testWidgets('navigation on parent updates nested Beamer', (tester) async {
      final childDelegate = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
          routes: {
            '/': (context, state, data) => const Text('/'),
            '/test': (context, state, data) => const Text('/test'),
            '/test2': (context, state, data) => const Text('/test2'),
          },
        ),
      );
      final rootDelegate = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
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

    testWidgets("navigation on parent doesn't update nested Beamer", (tester) async {
      final childDelegate = BeamerDelegate(
        initializeFromParent: false,
        updateFromParent: false,
        updateParent: false,
        stackBuilder: RoutesStackBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
            '/test2': (context, state, data) => Container(),
          },
        ),
      );
      final rootDelegate = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
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
    test('no rebuild updates route information (configuration) to anything', () {
      final delegate = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
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

    testWidgets('updating route information without updating parent or rebuilding', (tester) async {
      final childDelegate = BeamerDelegate(
        updateParent: false,
        stackBuilder: RoutesStackBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
            '/test2': (context, state, data) => Container(),
          },
        ),
      );
      final rootDelegate = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
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
        stackBuilder: RoutesStackBuilder(
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
        stackBuilder: RoutesStackBuilder(
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

    testWidgets('history is cleared regardless, if option is set', (tester) async {
      final delegate = BeamerDelegate(
        clearBeamingHistoryOn: {'/'},
        stackBuilder: RoutesStackBuilder(
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

    testWidgets('history is cleared regardless, if option is set', (tester) async {
      final delegate = BeamerDelegate(
        clearBeamingHistoryOn: {'/test'},
        stackBuilder: RoutesStackBuilder(
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
      stackBuilder: RoutesStackBuilder(
        routes: {
          '/r1': (context, state, data) => Container(),
          '/r2': (context, state, data) => Container(),
        },
      ),
      guards: [
        BeamGuard(
          pathPatterns: ['/r1'],
          check: (_, __) => guardCheck.value,
          beamToNamed: (context, _, __, ___) => '/r2',
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
    test('incoming configuration is appended when it does not start with /', () {
      final delegate = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/t1': (context, state, data) => Container(),
            '/t1/t2': (context, state, data) => Container(),
          },
        ),
      );

      delegate.beamToNamed('t1');
      expect(delegate.configuration.uri.path, '/t1');
      expect(delegate.currentBeamStack.state.routeInformation.uri.path, '/t1');

      delegate.beamToNamed('t2');
      expect(delegate.configuration.uri.path, '/t1/t2');
      expect(delegate.currentBeamStack.state.routeInformation.uri.path, '/t1/t2');
    });
  });

  test('Properly preserve history part when using popToNamed(...)', () {
    final delegate = BeamerDelegate(
      stackBuilder: RoutesStackBuilder(
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

    expect(delegate.currentBeamStack.history.map((HistoryElement e) => e.routeInformation.uri.path), orderedEquals(<String>['/t1', '/t2']));
  });

  group('Deep Link', () {
    testWidgets('Deep link is preserved throughout guarding flow', (tester) async {
      var isLoading = true;
      var isAuthenticated = false;
      final delegate = BeamerDelegate(
        stackBuilder: RoutesStackBuilder(
          routes: {
            '/splash': (_, __, ___) => Container(),
            '/login': (_, __, ___) => Container(),
            '/home': (_, __, ___) => Container(),
            '/home/deeper': (_, __, ___) => Container(),
          },
        ),
        guards: [
          BeamGuard(
            pathPatterns: ['/splash'],
            check: (_, __) => isLoading,
            beamToNamed: (context, _, __, deepLink) => isAuthenticated ? (deepLink ?? '/home') : '/login',
          ),
          BeamGuard(
            pathPatterns: ['/login'],
            check: (_, __) => !isAuthenticated && !isLoading,
            beamToNamed: (context, _, __, deepLink) => isAuthenticated ? (deepLink ?? '/home') : '/splash',
          ),
          BeamGuard(
            pathPatterns: ['/splash', '/login'],
            guardNonMatching: true,
            check: (_, __) => isAuthenticated,
            beamToNamed: (context, _, __, ___) => isLoading ? '/splash' : '/login',
          ),
        ],
      );
      delegate.setDeepLink('/home/deeper');
      await tester.pumpWidget(
        MaterialApp.router(
          routerDelegate: delegate,
          routeInformationParser: BeamerParser(),
        ),
      );

      expect(delegate.configuration.uri.toString(), '/splash');

      isLoading = false;
      isAuthenticated = true;
      delegate.update();
      await tester.pumpAndSettle();

      expect(delegate.configuration.uri.toString(), '/home/deeper');
    });
  });
}
