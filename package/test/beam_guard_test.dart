import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'test_locations.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  const pathBlueprint = '/l1/one';
  final testLocation =
      Location1(const RouteInformation(location: pathBlueprint));
  final testLocationWithQuery = Location1(
      const RouteInformation(location: pathBlueprint + '?query=true'));

  group('shouldGuard', () {
    test('is true if the location has a blueprint matching the guard', () {
      final guard = BeamGuard(
        pathPatterns: [pathBlueprint],
        check: (_, __) => true,
        beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
      );

      expect(guard.shouldGuard(testLocation), isTrue);
    });

    test(
        'is true if the location (which has a query part) has a blueprint matching the guard',
        () {
      final guard = BeamGuard(
        pathPatterns: [pathBlueprint],
        check: (_, __) => true,
        beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
      );

      expect(guard.shouldGuard(testLocationWithQuery), isTrue);
    });

    test(
        'is true if the location has a blueprint matching the guard using regexp',
        () {
      final guard = BeamGuard(
        pathPatterns: [RegExp(pathBlueprint)],
        check: (_, __) => true,
        beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
      );

      expect(guard.shouldGuard(testLocation), isTrue);
    });

    test(
        'is true if the location (which has a query part) has a blueprint matching the guard using regexp',
        () {
      final guard = BeamGuard(
        pathPatterns: [RegExp(pathBlueprint)],
        check: (_, __) => true,
        beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
      );

      expect(guard.shouldGuard(testLocationWithQuery), isTrue);
    });

    test("is false if the location doesn't have a blueprint matching the guard",
        () {
      final guard = BeamGuard(
        pathPatterns: ['/not-a-match'],
        check: (_, __) => true,
        beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
      );

      expect(guard.shouldGuard(testLocation), isFalse);
    });

    test(
        "is false if the location (which has a query part) doesn't have a blueprint matching the guard",
        () {
      final guard = BeamGuard(
        pathPatterns: ['/not-a-match'],
        check: (_, __) => true,
        beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
      );

      expect(guard.shouldGuard(testLocationWithQuery), isFalse);
    });

    test(
        "is false if the location doesn't have a blueprint matching the guard using regexp",
        () {
      final guard = BeamGuard(
        pathPatterns: [RegExp('/not-a-match')],
        check: (_, __) => true,
        beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
      );

      expect(guard.shouldGuard(testLocation), isFalse);
    });

    test(
        "is false if the location (which has a query part) doesn't have a blueprint matching the guard using regexp",
        () {
      final guard = BeamGuard(
        pathPatterns: ['/not-a-match'],
        check: (_, __) => true,
        beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
      );

      expect(guard.shouldGuard(testLocationWithQuery), isFalse);
    });

    group('with wildcards', () {
      test('is true if the location has a match up to the wildcard', () {
        final guard = BeamGuard(
          pathPatterns: [
            pathBlueprint.substring(
                  0,
                  pathBlueprint.indexOf('/'),
                ) +
                '/*',
          ],
          check: (_, __) => true,
          beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
        );

        expect(guard.shouldGuard(testLocation), isTrue);
      });

      test(
          'is true if the location has a match up to the wildcard using regexp',
          () {
        final guard = BeamGuard(
          pathPatterns: [RegExp('(/[a-z]*|[0-9]*/one)')],
          check: (_, __) => true,
          beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
        );

        expect(guard.shouldGuard(testLocation), isTrue);
      });

      test("is false if the location doesn't have a match against the wildcard",
          () {
        final guard = BeamGuard(
          pathPatterns: [
            '/not-a-match/*',
          ],
          check: (_, __) => true,
          beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
        );

        expect(guard.shouldGuard(testLocation), isFalse);
      });

      test(
          "is false if the location doesn't have a match against the wildcard using regexp",
          () {
        final guard = BeamGuard(
          pathPatterns: [
            RegExp('(/[a-z]*[0-9]/no-match)'),
          ],
          check: (_, __) => true,
          beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
        );

        expect(guard.shouldGuard(testLocation), isFalse);
      });
    });

    group('when the guard is set to block other locations', () {
      test('is false if the location has a blueprint matching the guard', () {
        final guard = BeamGuard(
          pathPatterns: [
            pathBlueprint,
          ],
          check: (_, __) => true,
          beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
          guardNonMatching: true,
        );

        expect(guard.shouldGuard(testLocation), isFalse);
      });

      test(
          'is false if the location has a blueprint matching the guard using regexp',
          () {
        final guard = BeamGuard(
          pathPatterns: [
            RegExp(pathBlueprint),
          ],
          check: (_, __) => true,
          beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
          guardNonMatching: true,
        );

        expect(guard.shouldGuard(testLocation), isFalse);
      });

      test(
          "is true if the location doesn't have a blueprint matching the guard",
          () {
        final guard = BeamGuard(
          pathPatterns: ['/not-a-match'],
          check: (_, __) => true,
          beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
          guardNonMatching: true,
        );

        expect(guard.shouldGuard(testLocation), isTrue);
      });

      test(
          "is true if the location doesn't have a blueprint matching the guard using regexp",
          () {
        final guard = BeamGuard(
          pathPatterns: [RegExp('/not-a-match')],
          check: (_, __) => true,
          beamTo: (context, _, __, ___) => Location2(const RouteInformation()),
          guardNonMatching: true,
        );

        expect(guard.shouldGuard(testLocation), isTrue);
      });

      group('with wildcards', () {
        test('is false if the location has a match up to the wildcard', () {
          final guard = BeamGuard(
            pathPatterns: [
              pathBlueprint.substring(
                    0,
                    pathBlueprint.indexOf('/'),
                  ) +
                  '/*',
            ],
            check: (_, __) => true,
            beamTo: (context, _, __, ___) =>
                Location2(const RouteInformation()),
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testLocation), isFalse);
        });

        test(
            'is false if the location has a match up to the wildcard using regexp',
            () {
          final guard = BeamGuard(
            pathPatterns: [
              RegExp('/[a-z]+'),
            ],
            check: (_, __) => true,
            beamTo: (context, _, __, ___) =>
                Location2(const RouteInformation()),
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testLocation), isFalse);
        });

        test(
            "is true if the location doesn't have a match against the wildcard",
            () {
          final guard = BeamGuard(
            pathPatterns: [
              '/not-a-match/*',
            ],
            check: (_, __) => true,
            beamTo: (context, _, __, ___) =>
                Location2(const RouteInformation()),
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testLocation), isTrue);
        });

        test(
            "is true if the location doesn't have a match against the wildcard using regexp",
            () {
          final guard = BeamGuard(
            pathPatterns: [
              RegExp('/not-a-match/[a-z]+'),
            ],
            check: (_, __) => true,
            beamTo: (context, _, __, ___) =>
                Location2(const RouteInformation()),
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testLocation), isTrue);
        });
      });
    });

    group('guard updates location', () {
      testWidgets('with beamTo', (tester) async {
        final router = BeamerDelegate(
          initialPath: '/l1',
          locationBuilder: (routeInformation, _) {
            if (routeInformation.location?.contains('l1') ?? false) {
              return Location1(routeInformation);
            }
            return Location2(routeInformation);
          },
          guards: [
            BeamGuard(
              pathPatterns: ['/l2'],
              check: (context, loc) => false,
              beamTo: (context, _, __, ___) =>
                  Location1(const RouteInformation(location: '/l1')),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(
          routerDelegate: router,
          routeInformationParser: BeamerParser(),
        ));

        expect(router.currentBeamLocation, isA<Location1>());
        router.beamToNamed('/l2');
        await tester.pump();
        expect(router.currentBeamLocation, isA<Location1>());
      });

      testWidgets("with beamTo that doesn't replace", (tester) async {
        final router = BeamerDelegate(
          removeDuplicateHistory: false,
          initialPath: '/l1',
          locationBuilder: (routeInformation, _) {
            if (routeInformation.location?.contains('l1') ?? false) {
              return Location1(routeInformation);
            }
            return Location2(routeInformation);
          },
          guards: [
            BeamGuard(
              pathPatterns: ['/l2'],
              check: (context, loc) => false,
              beamTo: (context, _, __, ___) =>
                  Location1(const RouteInformation(location: '/l1')),
              replaceCurrentStack: false,
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(
          routerDelegate: router,
          routeInformationParser: BeamerParser(),
        ));

        expect(router.currentBeamLocation, isA<Location1>());
        router.beamToNamed('/l2');
        await tester.pump();
        expect(router.currentBeamLocation, isA<Location1>());
        expect(router.beamingHistory.length, 2);
      });

      testWidgets('with beamToNamed', (tester) async {
        final router = BeamerDelegate(
          initialPath: '/l1',
          locationBuilder: (routeInformation, _) {
            if (routeInformation.location?.contains('l1') ?? false) {
              return Location1(routeInformation);
            }
            return Location2(routeInformation);
          },
          guards: [
            BeamGuard(
              pathPatterns: ['/l2'],
              check: (context, loc) => false,
              beamToNamed: (_, __, ___) => '/l1',
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(
          routerDelegate: router,
          routeInformationParser: BeamerParser(),
        ));

        expect(router.currentBeamLocation, isA<Location1>());
        router.beamToNamed('/l2');
        await tester.pump();
        expect(router.currentBeamLocation, isA<Location1>());
      });
    });
  });

  group('interconnected guarding', () {
    testWidgets('guards will run a recursion', (tester) async {
      final delegate = BeamerDelegate(
        initialPath: '/1',
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/1': (context, state, data) => const Text('1'),
            '/2': (context, state, data) => const Text('2'),
            '/3': (context, state, data) => const Text('3'),
          },
        ),
        guards: [
          // 2 will redirect to 3
          // 3 will redirect to 1
          BeamGuard(
            pathPatterns: ['/2'],
            check: (_, __) => false,
            beamToNamed: (_, __, ___) => '/3',
          ),
          BeamGuard(
            pathPatterns: ['/3'],
            check: (_, __) => false,
            beamToNamed: (_, __, ___) => '/1',
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: BeamerParser(),
      ));

      expect(delegate.configuration.location, '/1');
      delegate.beamToNamed('/2');
      await tester.pump();
      expect(delegate.configuration.location, '/1');
    });
  });

  group('guards that block', () {
    testWidgets('nothing happens when guard should just block', (tester) async {
      final delegate = BeamerDelegate(
        initialPath: '/1',
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/1': (context, state, data) => const Text('1'),
            '/2': (context, state, data) => const Text('2'),
          },
        ),
        guards: [
          BeamGuard(
            pathPatterns: ['/2'],
            check: (_, __) => false,
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: BeamerParser(),
      ));

      expect(delegate.configuration.location, '/1');
      expect(
          delegate.currentBeamLocation.state.routeInformation.location, '/1');
      expect(delegate.beamingHistory.length, 1);
      expect(delegate.beamingHistory.last.history.length, 1);

      delegate.beamToNamed('/2');
      await tester.pump();

      expect(delegate.configuration.location, '/1');
      expect(
          delegate.currentBeamLocation.state.routeInformation.location, '/1');
      expect(delegate.beamingHistory.length, 1);
      expect(delegate.beamingHistory.last.history.length, 1);
    });
  });

  group('origin & target location update', () {
    testWidgets(
        'should preserve origin location query params when forwarded in beamToNamed',
        (tester) async {
      final delegate = BeamerDelegate(
        initialPath: '/1',
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/1': (context, state, data) => const Text('1'),
            '/2': (context, state, data) => const Text('2'),
          },
        ),
        guards: [
          BeamGuard(
            pathPatterns: ['/2'],
            check: (context, location) => false,
            beamToNamed: (origin, target, _) {
              final targetState = target.state as BeamState;
              final destinationUri =
                  Uri(path: '/1', queryParameters: targetState.queryParameters)
                      .toString();

              return destinationUri;
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: BeamerParser(),
      ));

      expect(delegate.configuration.location, '/1');
      expect(
          delegate.currentBeamLocation.state.routeInformation.location, '/1');

      delegate.beamToNamed('/2?param1=a&param2=b');
      await tester.pump();

      expect(delegate.configuration.location, '/1?param1=a&param2=b');
      expect(delegate.currentBeamLocation.state.routeInformation.location,
          '/1?param1=a&param2=b');
    });

    testWidgets(
        'should preserve origin location query params when forwarded in beamTo',
        (tester) async {
      final delegate = BeamerDelegate(
        initialPath: '/l1',
        locationBuilder: (routeInformation, _) {
          if (routeInformation.location?.contains('l1') ?? false) {
            return Location1(routeInformation);
          }
          return Location2(routeInformation);
        },
        guards: [
          BeamGuard(
            pathPatterns: ['/l2'],
            check: (context, location) => false,
            beamTo: (context, origin, target, _) {
              final targetState = target.state as BeamState;
              final destinationUri = Uri(
                  path: '/l1', queryParameters: targetState.queryParameters);

              return Location2()..state = BeamState.fromUri(destinationUri);
            },
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: BeamerParser(),
      ));

      expect(delegate.configuration.location, '/l1');
      expect(
          delegate.currentBeamLocation.state.routeInformation.location, '/l1');

      delegate.beamToNamed('/l2?param1=a&param2=b');
      await tester.pump();

      expect(delegate.configuration.location, '/l1?param1=a&param2=b');
      expect(delegate.currentBeamLocation.state.routeInformation.location,
          '/l1?param1=a&param2=b');
    });
  });

  group('Apply', () {
    BeamerDelegate _createDelegate(BeamGuard guard) {
      return BeamerDelegate(
        initialPath: '/allowed',
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/allowed': (_, __, ___) => Container(),
            '/guarded': (_, __, ___) => Container(),
          },
        ),
        guards: [guard],
      );
    }

    BeamLocation _createGuardedBeamLocation(BeamerDelegate delegate) {
      return delegate.locationBuilder(
          const RouteInformation(location: '/guarded'), null);
    }

    test('does nothing', () {
      final guard = BeamGuard(
        pathPatterns: ['/guarded'],
        check: (_, __) => false,
      );

      final delegate = _createDelegate(guard);
      final guardedBeamLocation = _createGuardedBeamLocation(delegate);

      delegate.beamToNamed('/allowed');

      guard.apply(
        MockBuildContext(),
        delegate,
        delegate.currentBeamLocation,
        delegate.currentPages,
        guardedBeamLocation,
        null,
      );

      expect(
        delegate.currentBeamLocation.state.routeInformation.location,
        '/allowed',
      );
      expect(delegate.beamingHistoryCompleteLength, 1);
    });

    test('redirects to allowed and adds to beamingHistory', () {
      final guard = BeamGuard(
        pathPatterns: ['/guarded'],
        check: (_, __) => false,
        beamToNamed: (_, __, ___) => '/allowed',
        replaceCurrentStack: false,
      );

      final delegate = _createDelegate(guard);
      final guardedBeamLocation = _createGuardedBeamLocation(delegate);

      delegate.beamToNamed('/allowed');

      guard.apply(
        MockBuildContext(),
        delegate,
        delegate.currentBeamLocation,
        delegate.currentPages,
        guardedBeamLocation,
        null,
      );

      expect(
        delegate.currentBeamLocation.state.routeInformation.location,
        '/allowed',
      );
      expect(delegate.beamingHistoryCompleteLength, 1);
    });

    test("redirects to showPage BeamLocation and doesn't replace", () {
      final guard = BeamGuard(
        pathPatterns: ['/guarded'],
        check: (_, __) => false,
        showPage: BeamPage(key: const ValueKey('page'), child: Container()),
        replaceCurrentStack: false,
      );

      final delegate = _createDelegate(guard);
      final guardedBeamLocation = _createGuardedBeamLocation(delegate);

      delegate.beamToNamed('/allowed');

      guard.apply(
        MockBuildContext(),
        delegate,
        delegate.currentBeamLocation,
        delegate.currentPages,
        guardedBeamLocation,
        null,
      );

      expect(
        delegate.currentBeamLocation.state.routeInformation.location,
        '/guarded',
      );
      expect(delegate.currentBeamLocation, isA<GuardShowPage>());
      expect(delegate.beamingHistoryCompleteLength, 2);
    });

    test('redirects to showPage BeamLocation and replaces', () {
      final guard = BeamGuard(
        pathPatterns: ['/guarded'],
        check: (_, __) => false,
        showPage: BeamPage(key: const ValueKey('page'), child: Container()),
      );

      final delegate = _createDelegate(guard);
      final guardedBeamLocation = _createGuardedBeamLocation(delegate);

      delegate.beamToNamed('/allowed');

      guard.apply(
        MockBuildContext(),
        delegate,
        delegate.currentBeamLocation,
        delegate.currentPages,
        guardedBeamLocation,
        null,
      );

      expect(
        delegate.currentBeamLocation.state.routeInformation.location,
        '/guarded',
      );
      expect(delegate.currentBeamLocation, isA<GuardShowPage>());
      expect(delegate.beamingHistoryCompleteLength, 1);
    });
  });

  testWidgets(
    "Unapplied guards doesn't break guarding process",
    (tester) async {
      final routerDelegate = BeamerDelegate(
        initialPath: '/s1',
        locationBuilder: RoutesLocationBuilder(
          routes: <Pattern, dynamic Function(BuildContext, BeamState, Object?)>{
            '/s1': (_, __, ___) => Container(),
            '/s1/*': (_, __, ___) => Container(),
          },
        ),
        guards: <BeamGuard>[
          BeamGuard(
            pathPatterns: <Pattern>['/x'],
            guardNonMatching: true,
            check: (_, __) => true,
            beamToNamed: (_, __, ___) => '/s1',
          ),
          BeamGuard(
            pathPatterns: <Pattern>['/s1/s2'],
            check: (_, __) => false,
            beamToNamed: (_, to, __) {
              return to.state.routeInformation.location! + '/s3';
            },
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: routerDelegate,
        ),
      );

      expect(routerDelegate.configuration.location, '/s1');

      routerDelegate.beamToNamed('/s1/s2');
      await tester.pumpAndSettle();

      expect(routerDelegate.configuration.location, '/s1/s2/s3');
    },
  );

  group('Initial guarding is correct', () {
    testWidgets(
      'When initially on guarded path, calls update twice',
      (tester) async {
        var updateCounter = 0;

        final delegate = BeamerDelegate(
          initialPath: '/guarded',
          routeListener: (_, __) => updateCounter++,
          locationBuilder: RoutesLocationBuilder(
            routes: <Pattern,
                dynamic Function(BuildContext, BeamState, Object?)>{
              '/ok': (_, __, ___) => Container(),
              '/guarded': (_, __, ___) => Container(),
            },
          ),
          guards: <BeamGuard>[
            BeamGuard(
              pathPatterns: <Pattern>['/guarded'],
              check: (_, __) => false,
              beamToNamed: (_, __, ___) => '/ok',
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routeInformationParser: BeamerParser(),
            routerDelegate: delegate,
          ),
        );

        expect(delegate.configuration.location, '/ok');
        expect(delegate.beamingHistory.length, 1);
        expect(updateCounter, 2);
      },
    );

    testWidgets(
      'When initially on OK path, calls update once',
      (tester) async {
        var updateCounter = 0;

        final delegate = BeamerDelegate(
          initialPath: '/ok',
          routeListener: (_, __) => updateCounter++,
          locationBuilder: RoutesLocationBuilder(
            routes: <Pattern,
                dynamic Function(BuildContext, BeamState, Object?)>{
              '/ok': (_, __, ___) => Container(),
              '/guarded': (_, __, ___) => Container(),
            },
          ),
          guards: <BeamGuard>[
            BeamGuard(
              pathPatterns: <Pattern>['/guarded'],
              check: (_, __) => false,
              beamToNamed: (_, __, ___) => '/ok',
            ),
          ],
        );

        await tester.pumpWidget(
          MaterialApp.router(
            routeInformationParser: BeamerParser(),
            routerDelegate: delegate,
          ),
        );

        expect(delegate.configuration.location, '/ok');
        expect(delegate.beamingHistory.length, 1);
        expect(updateCounter, 1);
      },
    );
  });

  testWidgets('Bug with lagging route check, issue #532', (tester) async {
    var checkTriggered = false;
    final delegate = BeamerDelegate(
      locationBuilder: BeamerLocationBuilder(
        beamLocations: [
          SimpleBeamLocation(),
        ],
      ),
      guards: [
        BeamGuard(
          pathPatterns: ['/route'],
          check: (_, __) {
            checkTriggered = true;
            return false;
          },
          beamToNamed: (_, __, ___) => '/',
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ),
    );

    expect(delegate.configuration.location, '/');

    delegate.beamToNamed('/route');
    await tester.pumpAndSettle();
    expect(checkTriggered, true);

    checkTriggered = false;
    delegate.beamToNamed('/route/deeper');
    await tester.pumpAndSettle();
    expect(checkTriggered, false);
  });
}
