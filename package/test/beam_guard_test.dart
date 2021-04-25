import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  final pathBlueprint = '/l1/one';
  final testLocation = Location1(BeamState.fromUri(Uri.parse(pathBlueprint)));

  group('shouldBlock', () {
    test('is true if the location has a blueprint matching the guard', () {
      final guard = BeamGuard(
        pathBlueprints: [pathBlueprint],
        check: (_, __) => true,
        beamTo: (context) => Location2(BeamState()),
      );

      expect(guard.shouldGuard(testLocation), isTrue);
    });

    test("is false if the location doesn't have a blueprint matching the guard",
        () {
      final guard = BeamGuard(
        pathBlueprints: ['/not-a-match'],
        check: (_, __) => true,
        beamTo: (context) => Location2(BeamState()),
      );

      expect(guard.shouldGuard(testLocation), isFalse);
    });

    group('with wildcards', () {
      test('is true if the location has a match up to the wildcard', () {
        final guard = BeamGuard(
          pathBlueprints: [
            pathBlueprint.substring(
                  0,
                  pathBlueprint.indexOf('/'),
                ) +
                '/*',
          ],
          check: (_, __) => true,
          beamTo: (context) => Location2(BeamState()),
        );

        expect(guard.shouldGuard(testLocation), isTrue);
      });

      test("is false if the location doesn't have a match against the wildcard",
          () {
        final guard = BeamGuard(
          pathBlueprints: [
            '/not-a-match/*',
          ],
          check: (_, __) => true,
          beamTo: (context) => Location2(BeamState()),
        );

        expect(guard.shouldGuard(testLocation), isFalse);
      });
    });

    group('when the guard is set to block other locations', () {
      test('is false if the location has a blueprint matching the guard', () {
        final guard = BeamGuard(
          pathBlueprints: [
            pathBlueprint,
          ],
          check: (_, __) => true,
          beamTo: (context) => Location2(BeamState()),
          guardNonMatching: true,
        );

        expect(guard.shouldGuard(testLocation), isFalse);
      });

      test(
          "is true if the location doesn't have a blueprint matching the guard",
          () {
        final guard = BeamGuard(
          pathBlueprints: ['/not-a-match'],
          check: (_, __) => true,
          beamTo: (context) => Location2(BeamState()),
          guardNonMatching: true,
        );

        expect(guard.shouldGuard(testLocation), isTrue);
      });

      group('with wildcards', () {
        test('is false if the location has a match up to the wildcard', () {
          final guard = BeamGuard(
            pathBlueprints: [
              pathBlueprint.substring(
                    0,
                    pathBlueprint.indexOf('/'),
                  ) +
                  '/*',
            ],
            check: (_, __) => true,
            beamTo: (context) => Location2(BeamState()),
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testLocation), isFalse);
        });

        test(
            "is true if the location doesn't have a match against the wildcard",
            () {
          final guard = BeamGuard(
            pathBlueprints: [
              '/not-a-match/*',
            ],
            check: (_, __) => true,
            beamTo: (context) => Location2(BeamState()),
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testLocation), isTrue);
        });
      });
    });

    group('guard updates location on build', () {
      testWidgets('guard beamTo changes the location on build', (tester) async {
        var router = BeamerRouterDelegate(
          locationBuilder: (state) {
            if (state.uri.pathSegments.isEmpty) {
              state = state.copyWith(
                pathBlueprintSegments: ['l1'],
              );
            }
            if (state.uri.pathSegments.contains('l1')) {
              return Location1(state);
            }
            if (state.uri.pathSegments.contains('l2')) {
              return Location2(state);
            }
            return CustomStateLocation.fromBeamState(state);
          },
          guards: [
            BeamGuard(
              pathBlueprints: ['/l2'],
              check: (context, loc) => false,
              beamTo: (context) => CustomStateLocation(),
            ),
          ],
        );

        await tester.pumpWidget(MaterialApp.router(
          routerDelegate: router,
          routeInformationParser: BeamerRouteInformationParser(),
        ));

        expect(router.currentLocation, isA<Location1>());

        router.beamTo(Location2(BeamState.fromUri(Uri.parse('/l2'))));
        await tester.pump();

        expect(router.currentLocation, isA<CustomStateLocation>());
      });

      // testWidgets('guard beamToNamed changes the location on build',
      //     (tester) async {
      //   var router = BeamerRouterDelegate(
      //     locationBuilder: (state) {
      //       if (state.uri.pathSegments.isEmpty) {
      //         state = state.copyWith(
      //           pathBlueprintSegments: ['l1'],
      //         );
      //       }
      //       if (state.uri.pathSegments.contains('l1')) {
      //         return Location1(state);
      //       }
      //       if (state.uri.pathSegments.contains('l2')) {
      //         return Location2(state);
      //       }
      //       return CustomStateLocation.fromBeamState(state);
      //     },
      //     guards: [
      //       BeamGuard(
      //         pathBlueprints: ['/l2'],
      //         check: (context, loc) => false,
      //         beamToNamed: '/custom/123',
      //       ),
      //     ],
      //   );

      //   await tester.pumpWidget(MaterialApp.router(
      //     routerDelegate: router,
      //     routeInformationParser: BeamerRouteInformationParser(),
      //   ));

      //   expect(router.currentLocation, isA<Location1>());

      //   router.beamTo(Location2(BeamState.fromUri(Uri.parse('/l2'))));
      //   await tester.pump();

      //   expect(router.currentLocation, isA<CustomStateLocation>());
      //   expect((router.currentLocation as CustomStateLocation).state.customVar,
      //       equals('123'));
      // });
    });
  });
}
