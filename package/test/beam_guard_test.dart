import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

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
        beamTo: (context, _, __) => Location2(const RouteInformation()),
      );

      expect(guard.shouldGuard(testLocation), isTrue);
    });

    test(
        'is true if the location (which has a query part) has a blueprint matching the guard',
        () {
      final guard = BeamGuard(
        pathPatterns: [pathBlueprint],
        check: (_, __) => true,
        beamTo: (context, _, __) => Location2(const RouteInformation()),
      );

      expect(guard.shouldGuard(testLocationWithQuery), isTrue);
    });

    test(
        'is true if the location has a blueprint matching the guard using regexp',
        () {
      final guard = BeamGuard(
        pathPatterns: [RegExp(pathBlueprint)],
        check: (_, __) => true,
        beamTo: (context, _, __) => Location2(const RouteInformation()),
      );

      expect(guard.shouldGuard(testLocation), isTrue);
    });

    test(
        'is true if the location (which has a query part) has a blueprint matching the guard using regexp',
        () {
      final guard = BeamGuard(
        pathPatterns: [RegExp(pathBlueprint)],
        check: (_, __) => true,
        beamTo: (context, _, __) => Location2(const RouteInformation()),
      );

      expect(guard.shouldGuard(testLocationWithQuery), isTrue);
    });

    test("is false if the location doesn't have a blueprint matching the guard",
        () {
      final guard = BeamGuard(
        pathPatterns: ['/not-a-match'],
        check: (_, __) => true,
        beamTo: (context, _, __) => Location2(const RouteInformation()),
      );

      expect(guard.shouldGuard(testLocation), isFalse);
    });

    test(
        "is false if the location (which has a query part) doesn't have a blueprint matching the guard",
        () {
      final guard = BeamGuard(
        pathPatterns: ['/not-a-match'],
        check: (_, __) => true,
        beamTo: (context, _, __) => Location2(const RouteInformation()),
      );

      expect(guard.shouldGuard(testLocationWithQuery), isFalse);
    });

    test(
        "is false if the location doesn't have a blueprint matching the guard using regexp",
        () {
      final guard = BeamGuard(
        pathPatterns: [RegExp('/not-a-match')],
        check: (_, __) => true,
        beamTo: (context, _, __) => Location2(const RouteInformation()),
      );

      expect(guard.shouldGuard(testLocation), isFalse);
    });

    test(
        "is false if the location (which has a query part) doesn't have a blueprint matching the guard using regexp",
        () {
      final guard = BeamGuard(
        pathPatterns: ['/not-a-match'],
        check: (_, __) => true,
        beamTo: (context, _, __) => Location2(const RouteInformation()),
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
          beamTo: (context, _, __) => Location2(const RouteInformation()),
        );

        expect(guard.shouldGuard(testLocation), isTrue);
      });

      test(
          'is true if the location has a match up to the wildcard using regexp',
          () {
        final guard = BeamGuard(
          pathPatterns: [RegExp('(/[a-z]*|[0-9]*/one)')],
          check: (_, __) => true,
          beamTo: (context, _, __) => Location2(const RouteInformation()),
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
          beamTo: (context, _, __) => Location2(const RouteInformation()),
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
          beamTo: (context, _, __) => Location2(const RouteInformation()),
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
          beamTo: (context, _, __) => Location2(const RouteInformation()),
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
          beamTo: (context, _, __) => Location2(const RouteInformation()),
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
          beamTo: (context, _, __) => Location2(const RouteInformation()),
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
          beamTo: (context, _, __) => Location2(const RouteInformation()),
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
            beamTo: (context, _, __) => Location2(const RouteInformation()),
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
            beamTo: (context, _, __) => Location2(const RouteInformation()),
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
            beamTo: (context, _, __) => Location2(const RouteInformation()),
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
            beamTo: (context, _, __) => Location2(const RouteInformation()),
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testLocation), isTrue);
        });
      });
    });

    group('guard updates location on build', () {
      testWidgets('guard beamTo changes the location on build', (tester) async {
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
              beamTo: (context, _, __) =>
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

      testWidgets('guard beamToNamed changes the location on build',
          (tester) async {
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
              beamToNamed: (_, __) => '/l1',
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
            '/1': (context, state) => const Text('1'),
            '/2': (context, state) => const Text('2'),
            '/3': (context, state) => const Text('3'),
          },
        ),
        guards: [
          // 2 will redirect to 3
          // 3 will redirect to 1
          BeamGuard(
            pathPatterns: ['/2'],
            check: (_, __) => false,
            beamToNamed:(_, __) => '/3',
          ),
          BeamGuard(
            pathPatterns: ['/3'],
            check: (_, __) => false,
            beamToNamed:(_, __) => '/1',
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
            '/1': (context, state) => const Text('1'),
            '/2': (context, state) => const Text('2'),
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
    testWidgets('should preserve origin location query params when forwarded in beamToNamed', (tester) async {
      final delegate = BeamerDelegate(
        initialPath: '/1',
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/1': (context, state) => const Text('1'),
            '/2': (context, state) => const Text('2'),
          },
        ),
        guards: [
          BeamGuard(
            pathPatterns: ['/2'],
            check: (context, location) => false,
            beamToNamed: (originLocation, targetLocation) {
              final targetState = targetLocation.state as BeamState;
              final destinationUri = Uri(path: '/1', queryParameters: targetState.queryParameters).toString();

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
      expect(delegate.currentBeamLocation.state.routeInformation.location, '/1');

      delegate.beamToNamed('/2?param1=a&param2=b');
      await tester.pump();

      expect(delegate.configuration.location, '/1?param1=a&param2=b');
      expect(delegate.currentBeamLocation.state.routeInformation.location, '/1?param1=a&param2=b');
    });

    testWidgets('should preserve origin location query params when forwarded in beamTo', (tester) async {
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
            beamTo: (context, originLocation, targetLocation) {
              final targetState = targetLocation.state as BeamState;
              final destinationUri = Uri(path: '/l1', queryParameters: targetState.queryParameters);

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
      expect(delegate.currentBeamLocation.state.routeInformation.location, '/l1');

      delegate.beamToNamed('/l2?param1=a&param2=b');
      await tester.pump();

      expect(delegate.configuration.location, '/l1?param1=a&param2=b');
      expect(delegate.currentBeamLocation.state.routeInformation.location, '/l1?param1=a&param2=b');
    });
  });
}
