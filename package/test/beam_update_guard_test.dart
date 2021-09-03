import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  const pathBlueprint = '/l1/one';
  const testRouteInfo = const RouteInformation(location: pathBlueprint);
  final testLocation =
      Location1(testRouteInfo);
  const testRouteInfoWithQuery = const RouteInformation(location: pathBlueprint + '?query=true');
  final testLocationWithQuery = Location1(testRouteInfoWithQuery);

  group('shouldGuard', () {
    test('is true if the location has a blueprint matching the guard', () {
      final guard = BeamUpdateGuard(
        pathPatterns: [pathBlueprint],
        check: (_, __) => true,
        redirect:  (_,__){},
      );

      expect(guard.shouldGuard(testRouteInfo), isTrue);
    });

    test(
        'is true if the location (which has a query part) has a blueprint matching the guard',
        () {
      final guard = BeamUpdateGuard(
        pathPatterns: [pathBlueprint],
        check: (_, __) => true,
        redirect:  (_,__){},
      );

      expect(guard.shouldGuard(testRouteInfoWithQuery), isTrue);
    });

    test(
        'is true if the location has a blueprint matching the guard using regexp',
        () {
      final guard = BeamUpdateGuard(
        pathPatterns: [RegExp(pathBlueprint)],
        check: (_, __) => true,
        redirect:  (_,__){},
      );

      expect(guard.shouldGuard(testRouteInfo), isTrue);
    });

    test(
        'is true if the location (which has a query part) has a blueprint matching the guard using regexp',
        () {
      final guard = BeamUpdateGuard(
        pathPatterns: [RegExp(pathBlueprint)],
        check: (_, __) => true,
        redirect:  (_,__){},
      );

      expect(guard.shouldGuard(testRouteInfoWithQuery), isTrue);
    });

    test("is false if the location doesn't have a blueprint matching the guard",
        () {
      final guard = BeamUpdateGuard(
        pathPatterns: ['/not-a-match'],
        check: (_, __) => true,
        redirect:  (_,__){},
      );

      expect(guard.shouldGuard(testRouteInfo), isFalse);
    });

    test(
        "is false if the location (which has a query part) doesn't have a blueprint matching the guard",
        () {
      final guard = BeamUpdateGuard(
        pathPatterns: ['/not-a-match'],
        check: (_, __) => true,
        redirect:  (_,__){},
      );

      expect(guard.shouldGuard(testRouteInfoWithQuery), isFalse);
    });

    test(
        "is false if the location doesn't have a blueprint matching the guard using regexp",
        () {
      final guard = BeamUpdateGuard(
        pathPatterns: [RegExp('/not-a-match')],
        check: (_, __) => true,
        redirect:  (_,__){},
      );

      expect(guard.shouldGuard(testRouteInfo), isFalse);
    });

    test(
        "is false if the location (which has a query part) doesn't have a blueprint matching the guard using regexp",
        () {
      final guard = BeamUpdateGuard(
        pathPatterns: ['/not-a-match'],
        check: (_, __) => true,
        redirect: (_,__){},
      );

      expect(guard.shouldGuard(testRouteInfoWithQuery), isFalse);
    });

    group('with wildcards', () {
      test('is true if the location has a match up to the wildcard', () {
        final guard = BeamUpdateGuard(
          pathPatterns: [
            pathBlueprint.substring(
                  0,
                  pathBlueprint.indexOf('/'),
                ) +
                '/*',
          ],
          check: (_, __) => true,
          redirect: (_,__){},
        );

        expect(guard.shouldGuard(testRouteInfo), isTrue);
      });

      test(
          'is true if the location has a match up to the wildcard using regexp',
          () {
        final guard = BeamUpdateGuard(
          pathPatterns: [RegExp('(/[a-z]*|[0-9]*/one)')],
          check: (_, __) => true,
          redirect: (_,__){},
        );

        expect(guard.shouldGuard(testRouteInfo), isTrue);
      });

      test("is false if the location doesn't have a match against the wildcard",
          () {
        final guard = BeamUpdateGuard(
          pathPatterns: [
            '/not-a-match/*',
          ],
          check: (_, __) => true,
          redirect: (_,__){},
        );

        expect(guard.shouldGuard(testRouteInfo), isFalse);
      });

      test(
          "is false if the location doesn't have a match against the wildcard using regexp",
          () {
        final guard = BeamUpdateGuard(
          pathPatterns: [
            RegExp('(/[a-z]*[0-9]/no-match)'),
          ],
          check: (_, __) => true,
          redirect: (_,__){},
        );

        expect(guard.shouldGuard(testRouteInfo), isFalse);
      });
    });

    group('when the guard is set to block other locations', () {
      test('is false if the location has a blueprint matching the guard', () {
        final guard = BeamUpdateGuard(
          pathPatterns: [
            pathBlueprint,
          ],
          check: (_, __) => true,
          redirect: (_,__){},
          guardNonMatching: true,
        );

        expect(guard.shouldGuard(testRouteInfo), isFalse);
      });

      test(
          'is false if the location has a blueprint matching the guard using regexp',
          () {
        final guard = BeamUpdateGuard(
          pathPatterns: [
            RegExp(pathBlueprint),
          ],
          check: (_, __) => true,
          redirect: (_,__){},
          guardNonMatching: true,
        );

        expect(guard.shouldGuard(testRouteInfo), isFalse);
      });

      test(
          "is true if the location doesn't have a blueprint matching the guard",
          () {
        final guard = BeamUpdateGuard(
          pathPatterns: ['/not-a-match'],
          check: (_, __) => true,
          redirect: (_,__){},
          guardNonMatching: true,
        );

        expect(guard.shouldGuard(testRouteInfo), isTrue);
      });

      test(
          "is true if the location doesn't have a blueprint matching the guard using regexp",
          () {
        final guard = BeamUpdateGuard(
          pathPatterns: [RegExp('/not-a-match')],
          check: (_, __) => true,
          redirect: (_,__){},
          guardNonMatching: true,
        );

        expect(guard.shouldGuard(testRouteInfo), isTrue);
      });

      group('with wildcards', () {
        test('is false if the location has a match up to the wildcard', () {
          final guard = BeamUpdateGuard(
            pathPatterns: [
              pathBlueprint.substring(
                    0,
                    pathBlueprint.indexOf('/'),
                  ) +
                  '/*',
            ],
            check: (_, __) => true,
            redirect: (_,__){},
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testRouteInfo), isFalse);
        });

        test(
            'is false if the location has a match up to the wildcard using regexp',
            () {
          final guard = BeamUpdateGuard(
            pathPatterns: [
              RegExp('/[a-z]+'),
            ],
            check: (_, __) => true,
            redirect: (_,__){},
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testRouteInfo), isFalse);
        });

        test(
            "is true if the location doesn't have a match against the wildcard",
            () {
          final guard = BeamUpdateGuard(
            pathPatterns: [
              '/not-a-match/*',
            ],
            check: (_, __) => true,
            redirect: (_,__){},
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testRouteInfo), isTrue);
        });

        test(
            "is true if the location doesn't have a match against the wildcard using regexp",
            () {
          final guard = BeamUpdateGuard(
            pathPatterns: [
              RegExp('/not-a-match/[a-z]+'),
            ],
            check: (_, __) => true,
            redirect: (_,__){},
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testRouteInfo), isTrue);
        });
      });
    });

    group('update guard effectively updates location like build guards', () {
      testWidgets('guards redirect changes the location', (tester) async {
        final router = BeamerDelegate(
          initialPath: '/l1',
          locationBuilder: (routeInformation, _) {
            if (routeInformation.location?.contains('l1') ?? false) {
              return Location1(routeInformation);
            }
            return Location2(routeInformation);
          },
          updateGuards: [
            BeamUpdateGuard(
              pathPatterns: ['/l2'],
              check: (context, loc) => false,
              redirect: (delegate,routeInfo) =>
                  delegate.beamTo(Location1(const RouteInformation(location: '/l1'))),
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
        updateGuards: [
          // 2 will redirect to 3
          // 3 will redirect to 1
          BeamUpdateGuard(
            pathPatterns: ['/2'],
            check: (_, __) => false,
            redirect: (delegate,routeInfo) => delegate.beamToNamed('/3'),
            
          ),
          BeamUpdateGuard(
            pathPatterns: ['/3'],
            check: (_, __) => false,
            redirect: (delegate,routeInfo) => delegate.beamToNamed('/1'),
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
        updateGuards: [
          BeamUpdateGuard(
            pathPatterns: ['/2'],
            check: (_, __) => false,
            redirect: (delegate,routeInfo) {},
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
}
