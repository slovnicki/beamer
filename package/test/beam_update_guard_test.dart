import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

class CustomBeamUpdateGuard extends BeamUpdateGuard {
  BeamLocation? shouldLocation;
  RouteInformation? shouldRouteInfo;
  Object? shouldData;

  CustomBeamUpdateGuard({
    required pathPatterns,
    required check,
    required redirect,
  }) : super(pathPatterns: pathPatterns, check: check, redirect: redirect);

  @override
  bool shouldGuard(BeamLocation currentLocation,
      RouteInformation routeInformation, Object? data) {
    shouldLocation = currentLocation;
    shouldRouteInfo = routeInformation;
    shouldData = data;
    return super.shouldGuard(currentLocation, routeInformation, data);
  }
}

void main() {
  const pathBlueprint = '/l1/one';
  const testRouteInfo = const RouteInformation(location: pathBlueprint);
  final testLocation = Location1(testRouteInfo);
  const testRouteInfoWithQuery =
      const RouteInformation(location: pathBlueprint + '?query=true');
  final testLocationWithQuery = Location1(testRouteInfoWithQuery);

  BeamLocation? lastOriginBeamLocationFromCheckedRouteListener;
  RouteInformation? lastTargetRouteInfoFromCheckedRouteListener;
  Object? lastTargetDataFromCheckedRouteListener;
  RouteCheckState? lastCheckStateFromCheckedRouteListener;

  group('shouldGuard', () {
    test('is true if the location has a blueprint matching the guard', () {
      final guard = BeamUpdateGuard(
        pathPatterns: [pathBlueprint],
        check: (_, __, ___) => true,
        redirect: (_, __, ___) {},
      );

      expect(guard.shouldGuard(testLocation, testRouteInfo, null), isTrue);
    });

    test(
        'is true if the location (which has a query part) has a blueprint matching the guard',
        () {
      final guard = BeamUpdateGuard(
        pathPatterns: [pathBlueprint],
        check: (_, __, ___) => true,
        redirect: (_, __, ___) {},
      );

      expect(guard.shouldGuard(testLocation, testRouteInfoWithQuery, null),
          isTrue);
    });

    test(
        'is true if the location has a blueprint matching the guard using regexp',
        () {
      final guard = BeamUpdateGuard(
        pathPatterns: [RegExp(pathBlueprint)],
        check: (_, __, ___) => true,
        redirect: (_, __, ___) {},
      );

      expect(guard.shouldGuard(testLocation, testRouteInfo, null), isTrue);
    });

    test(
        'is true if the location (which has a query part) has a blueprint matching the guard using regexp',
        () {
      final guard = BeamUpdateGuard(
        pathPatterns: [RegExp(pathBlueprint)],
        check: (_, __, ___) => true,
        redirect: (_, __, ___) {},
      );

      expect(guard.shouldGuard(testLocation, testRouteInfoWithQuery, null),
          isTrue);
    });

    test("is false if the location doesn't have a blueprint matching the guard",
        () {
      final guard = BeamUpdateGuard(
        pathPatterns: ['/not-a-match'],
        check: (_, __, ___) => true,
        redirect: (_, __, ___) {},
      );

      expect(guard.shouldGuard(testLocation, testRouteInfo, null), isFalse);
    });

    test(
        "is false if the location (which has a query part) doesn't have a blueprint matching the guard",
        () {
      final guard = BeamUpdateGuard(
        pathPatterns: ['/not-a-match'],
        check: (_, __, ___) => true,
        redirect: (_, __, ___) {},
      );

      expect(guard.shouldGuard(testLocation, testRouteInfoWithQuery, null),
          isFalse);
    });

    test(
        "is false if the location doesn't have a blueprint matching the guard using regexp",
        () {
      final guard = BeamUpdateGuard(
        pathPatterns: [RegExp('/not-a-match')],
        check: (_, __, ___) => true,
        redirect: (_, __, ___) {},
      );

      expect(guard.shouldGuard(testLocation, testRouteInfo, null), isFalse);
    });

    test(
        "is false if the location (which has a query part) doesn't have a blueprint matching the guard using regexp",
        () {
      final guard = BeamUpdateGuard(
        pathPatterns: ['/not-a-match'],
        check: (_, __, ____) => true,
        redirect: (_, __, ___) {},
      );

      expect(guard.shouldGuard(testLocation, testRouteInfoWithQuery, null),
          isFalse);
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
          check: (_, __, ___) => true,
          redirect: (_, __, ___) {},
        );

        expect(guard.shouldGuard(testLocation, testRouteInfo, null), isTrue);
      });

      test(
          'is true if the location has a match up to the wildcard using regexp',
          () {
        final guard = BeamUpdateGuard(
          pathPatterns: [RegExp('(/[a-z]*|[0-9]*/one)')],
          check: (_, __, ___) => true,
          redirect: (_, __, ___) {},
        );

        expect(guard.shouldGuard(testLocation, testRouteInfo, null), isTrue);
      });

      test("is false if the location doesn't have a match against the wildcard",
          () {
        final guard = BeamUpdateGuard(
          pathPatterns: [
            '/not-a-match/*',
          ],
          check: (_, __, ___) => true,
          redirect: (_, __, ___) {},
        );

        expect(guard.shouldGuard(testLocation, testRouteInfo, null), isFalse);
      });

      test(
          "is false if the location doesn't have a match against the wildcard using regexp",
          () {
        final guard = BeamUpdateGuard(
          pathPatterns: [
            RegExp('(/[a-z]*[0-9]/no-match)'),
          ],
          check: (_, __, ___) => true,
          redirect: (_, __, ___) {},
        );

        expect(guard.shouldGuard(testLocation, testRouteInfo, null), isFalse);
      });
    });

    group('when the guard is set to block other locations', () {
      test('is false if the location has a blueprint matching the guard', () {
        final guard = BeamUpdateGuard(
          pathPatterns: [
            pathBlueprint,
          ],
          check: (_, __, ___) => true,
          redirect: (_, __, ___) {},
          guardNonMatching: true,
        );

        expect(guard.shouldGuard(testLocation, testRouteInfo, null), isFalse);
      });

      test(
          'is false if the location has a blueprint matching the guard using regexp',
          () {
        final guard = BeamUpdateGuard(
          pathPatterns: [
            RegExp(pathBlueprint),
          ],
          check: (_, __, ___) => true,
          redirect: (_, __, ___) {},
          guardNonMatching: true,
        );

        expect(guard.shouldGuard(testLocation, testRouteInfo, null), isFalse);
      });

      test(
          "is true if the location doesn't have a blueprint matching the guard",
          () {
        final guard = BeamUpdateGuard(
          pathPatterns: ['/not-a-match'],
          check: (_, __, ___) => true,
          redirect: (_, __, ___) {},
          guardNonMatching: true,
        );

        expect(guard.shouldGuard(testLocation, testRouteInfo, null), isTrue);
      });

      test(
          "is true if the location doesn't have a blueprint matching the guard using regexp",
          () {
        final guard = BeamUpdateGuard(
          pathPatterns: [RegExp('/not-a-match')],
          check: (_, __, ___) => true,
          redirect: (_, __, ___) {},
          guardNonMatching: true,
        );

        expect(guard.shouldGuard(testLocation, testRouteInfo, null), isTrue);
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
            check: (_, __, ___) => true,
            redirect: (_, __, ___) {},
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testLocation, testRouteInfo, null), isFalse);
        });

        test(
            'is false if the location has a match up to the wildcard using regexp',
            () {
          final guard = BeamUpdateGuard(
            pathPatterns: [
              RegExp('/[a-z]+'),
            ],
            check: (_, __, ___) => true,
            redirect: (_, __, ___) {},
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testLocation, testRouteInfo, null), isFalse);
        });

        test(
            "is true if the location doesn't have a match against the wildcard",
            () {
          final guard = BeamUpdateGuard(
            pathPatterns: [
              '/not-a-match/*',
            ],
            check: (_, __, ___) => true,
            redirect: (_, __, ___) {},
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testLocation, testRouteInfo, null), isTrue);
        });

        test(
            "is true if the location doesn't have a match against the wildcard using regexp",
            () {
          final guard = BeamUpdateGuard(
            pathPatterns: [
              RegExp('/not-a-match/[a-z]+'),
            ],
            check: (_, __, ___) => true,
            redirect: (_, __, ___) {},
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testLocation, testRouteInfo, null), isTrue);
        });
      });
    });

    group('update guard effectively updates location like build guards', () {
      testWidgets('guards redirect changes the location and data',
          (tester) async {
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
              check: (location, loc, data) => false,
              redirect: (delegate, routeInfo, data) => delegate.beamTo(
                  Location1(const RouteInformation(location: '/l1')),
                  data: data),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(
          routerDelegate: router,
          routeInformationParser: BeamerParser(),
        ));

        expect(router.currentBeamLocation, isA<Location1>());
        router.beamToNamed('/l2', data: 3);
        await tester.pump();
        expect(router.currentBeamLocation, isA<Location1>());
        expect(router.currentBeamLocation.data, equals(3));
      });
    });
    testWidgets('check receives the current location and the passed data',
        (tester) async {
      BeamLocation? checkLocation;
      RouteInformation? checkRouteInfo;
      Object? checkData;
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
              check: (location, routeInfo, data) {
                checkLocation = location;
                checkRouteInfo = routeInfo;
                checkData = data;
                return false;
              },
              redirect: (delegate, routeInfo, data) {}),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(
        routerDelegate: router,
        routeInformationParser: BeamerParser(),
      ));

      router.beamToNamed('/l2', data: 3);
      await tester.pump();

      expect(checkLocation, equals(isA<Location1>()));
      expect(checkRouteInfo?.location, equals("/l2"));
      expect(checkData, equals(3));
    });

    testWidgets('shouldGuard receives the current location and the passed data',
        (tester) async {
      final mockGuard = CustomBeamUpdateGuard(
          pathPatterns: ['/l2'],
          check: (location, routeInfo, data) => false,
          redirect: (delegate, routeInfo, data) {});
      final router = BeamerDelegate(
        initialPath: '/l1',
        locationBuilder: (routeInformation, _) {
          if (routeInformation.location?.contains('l1') ?? false) {
            return Location1(routeInformation);
          }
          return Location2(routeInformation);
        },
        updateGuards: [mockGuard],
      );

      await tester.pumpWidget(MaterialApp.router(
        routerDelegate: router,
        routeInformationParser: BeamerParser(),
      ));

      router.beamToNamed('/l2', data: 3);
      await tester.pump();

      expect(mockGuard.shouldLocation, equals(isA<Location1>()));
      expect(mockGuard.shouldRouteInfo?.location, equals("/l2"));
      expect(mockGuard.shouldData, equals(3));
    });

    testWidgets(
        'when guards blocks, checkedRouteListener receives the current location, the route info and the check results',
        (tester) async {
      final router = BeamerDelegate(
        initialPath: '/l1',
        checkedRouteListener: (BeamLocation originLocation,
            RouteInformation targetRouteInfo,
            Object? targetData,
            RouteCheckState checkState) {
          lastOriginBeamLocationFromCheckedRouteListener = originLocation;
          lastTargetRouteInfoFromCheckedRouteListener = targetRouteInfo;
          lastTargetDataFromCheckedRouteListener = targetData;
          lastCheckStateFromCheckedRouteListener = checkState;
        },
        locationBuilder: (routeInformation, _) {
          if (routeInformation.location?.contains('l1') ?? false) {
            return Location1(routeInformation);
          }
          return Location2(routeInformation);
        },
        updateGuards: [
          BeamUpdateGuard(
              pathPatterns: ['/l2'],
              check: (location, routeInfo, data) => false,
              redirect: (delegate, routeInfo, data) {}),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(
        routerDelegate: router,
        routeInformationParser: BeamerParser(),
      ));

      router.beamToNamed('/l2', data: 3);
      await tester.pump();

      expect(lastOriginBeamLocationFromCheckedRouteListener,
          equals(isA<Location1>()));
      expect(
          lastTargetRouteInfoFromCheckedRouteListener?.location, equals("/l2"));
      expect(lastTargetDataFromCheckedRouteListener, equals(3));
      expect(lastCheckStateFromCheckedRouteListener,
          equals(RouteCheckState.rejected));
    });

    testWidgets(
        'when guard accepts, checkedRouteListener receives the current location, the route info and the check results',
        (tester) async {
      final router = BeamerDelegate(
        initialPath: '/l1',
        checkedRouteListener: (BeamLocation originLocation,
            RouteInformation targetRouteInfo,
            Object? targetData,
            RouteCheckState checkState) {
          lastOriginBeamLocationFromCheckedRouteListener = originLocation;
          lastTargetRouteInfoFromCheckedRouteListener = targetRouteInfo;
          lastTargetDataFromCheckedRouteListener = targetData;
          lastCheckStateFromCheckedRouteListener = checkState;
        },
        locationBuilder: (routeInformation, _) {
          if (routeInformation.location?.contains('l1') ?? false) {
            return Location1(routeInformation);
          }
          return Location2(routeInformation);
        },
        updateGuards: [
          BeamUpdateGuard(
              pathPatterns: ['/l2'],
              check: (location, routeInfo, data) => true,
              redirect: (delegate, routeInfo, data) {}),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(
        routerDelegate: router,
        routeInformationParser: BeamerParser(),
      ));

      router.beamToNamed('/l2', data: 3);
      await tester.pump();

      expect(lastOriginBeamLocationFromCheckedRouteListener,
          equals(isA<Location1>()));

      expect(
          lastTargetRouteInfoFromCheckedRouteListener?.location, equals("/l2"));
      expect(lastTargetDataFromCheckedRouteListener, equals(3));
      expect(lastCheckStateFromCheckedRouteListener,
          equals(RouteCheckState.accepted));
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
            check: (_, __, ___) => false,
            redirect: (delegate, routeInfo, data) => delegate.beamToNamed('/3'),
          ),
          BeamUpdateGuard(
            pathPatterns: ['/3'],
            check: (_, __, ___) => false,
            redirect: (delegate, routeInfo, data) => delegate.beamToNamed('/1'),
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
            check: (_, __, ___) => false,
            redirect: (delegate, routeInfo, data) {},
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
