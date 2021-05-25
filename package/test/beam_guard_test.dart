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

    test(
        'is true if the location has a blueprint matching the guard using regexp',
        () {
      final guard = BeamGuard(
        pathBlueprints: [RegExp(pathBlueprint)],
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

    test(
        "is false if the location doesn't have a blueprint matching the guard using regexp",
        () {
      final guard = BeamGuard(
        pathBlueprints: [RegExp('/not-a-match')],
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

      test(
          'is true if the location has a match up to the wildcard using regexp',
          () {
        final guard = BeamGuard(
          pathBlueprints: [RegExp('(\/[a-z]*|[0-9]*\/one)')],
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

      test(
          "is false if the location doesn't have a match against the wildcard using regexp",
          () {
        final guard = BeamGuard(
          pathBlueprints: [
            RegExp('(/[a-z]*[0-9]/no-match)'),
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

      test('is false if the location has a blueprint matching the guard using regexp', () {
        final guard = BeamGuard(
          pathBlueprints: [
            RegExp(pathBlueprint),
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

      test(
          "is true if the location doesn't have a blueprint matching the guard using regexp",
          () {
        final guard = BeamGuard(
          pathBlueprints: [RegExp('/not-a-match')],
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

        test('is false if the location has a match up to the wildcard using regexp', () {
          final guard = BeamGuard(
            pathBlueprints: [
              RegExp('/[a-z]+'),
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

        test(
            "is true if the location doesn't have a match against the wildcard using regexp",
            () {
          final guard = BeamGuard(
            pathBlueprints: [
              RegExp('/not-a-match/[a-z]+'),
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
        final router = BeamerDelegate(
          initialPath: '/l1',
          locationBuilder: (state) {
            if (state.uri.pathSegments.contains('l1')) {
              return Location1(state);
            }
            return Location2(state);
          },
          guards: [
            BeamGuard(
              pathBlueprints: ['/l2'],
              check: (context, loc) => false,
              beamTo: (context) =>
                  Location1(BeamState.fromUri(Uri.parse('/l1'))),
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
          locationBuilder: (state) {
            if (state.uri.pathSegments.contains('l1')) {
              return Location1(state);
            }
            return Location2(state);
          },
          guards: [
            BeamGuard(
              pathBlueprints: ['/l2'],
              check: (context, loc) => false,
              beamToNamed: '/l1',
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
        locationBuilder: SimpleLocationBuilder(
          routes: {
            '/1': (context) => Text('1'),
            '/2': (context) => Text('2'),
            '/3': (context) => Text('3'),
          },
        ),
        guards: [
          // 2 will redirect to 3
          // 3 will redirect to 1
          BeamGuard(
            pathBlueprints: ['/2'],
            check: (_, __) => false,
            beamToNamed: '/3',
          ),
          BeamGuard(
            pathBlueprints: ['/3'],
            check: (_, __) => false,
            beamToNamed: '/1',
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: BeamerParser(),
      ));

      expect(delegate.state.uri.toString(), '/1');
      delegate.beamToNamed('/2');
      await tester.pump();
      expect(delegate.state.uri.toString(), '/1');
    });
  });

  group('guards that block', () {
    testWidgets('nothing happens when guard should just block', (tester) async {
      final delegate = BeamerDelegate(
        initialPath: '/1',
        locationBuilder: SimpleLocationBuilder(
          routes: {
            '/1': (context) => Text('1'),
            '/2': (context) => Text('2'),
          },
        ),
        guards: [
          BeamGuard(
            pathBlueprints: ['/2'],
            check: (_, __) => false,
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: BeamerParser(),
      ));

      expect(delegate.state.uri.toString(), '/1');
      expect(delegate.currentBeamLocation.state.uri.toString(), '/1');
      expect(delegate.beamLocationHistory.length, 1);
      expect(delegate.beamStateHistory.length, 1);

      delegate.beamToNamed('/2');
      await tester.pump();

      expect(delegate.state.uri.toString(), '/1');
      expect(delegate.currentBeamLocation.state.uri.toString(), '/1');
      expect(delegate.beamLocationHistory.length, 1);
      expect(delegate.beamStateHistory.length, 1);
    });
  });
}
