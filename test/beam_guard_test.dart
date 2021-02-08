import 'package:beamer/beamer.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  final testLocation = Location1(pathBlueprint: '/li/one');

  group('shouldBlock', () {
    test('is true if the location has a blueprint matching the guard', () {
      final guard = BeamGuard(
        pathBlueprints: [
          testLocation.pathBlueprint,
        ],
        check: (_, __) => true,
        beamTo: (context) => Location2(),
      );

      expect(guard.shouldGuard(testLocation), isTrue);
    });

    test("is false if the location doesn't have a blueprint matching the guard",
        () {
      final guard = BeamGuard(
        pathBlueprints: ['/not-a-match'],
        check: (_, __) => true,
        beamTo: (context) => Location2(),
      );

      expect(guard.shouldGuard(testLocation), isFalse);
    });

    group('with wildcards', () {
      test('is true if the location has a match up to the wildcard', () {
        final guard = BeamGuard(
          pathBlueprints: [
            testLocation.pathBlueprint.substring(
                  0,
                  testLocation.pathBlueprint.indexOf('/'),
                ) +
                '/*',
          ],
          check: (_, __) => true,
          beamTo: (context) => Location2(),
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
          beamTo: (context) => Location2(),
        );

        expect(guard.shouldGuard(testLocation), isFalse);
      });
    });

    group('when the guard is set to block other locations', () {
      test('is false if the location has a blueprint matching the guard', () {
        final guard = BeamGuard(
          pathBlueprints: [
            testLocation.pathBlueprint,
          ],
          check: (_, __) => true,
          beamTo: (context) => Location2(),
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
          beamTo: (context) => Location2(),
          guardNonMatching: true,
        );

        expect(guard.shouldGuard(testLocation), isTrue);
      });

      group('with wildcards', () {
        test('is false if the location has a match up to the wildcard', () {
          final guard = BeamGuard(
            pathBlueprints: [
              testLocation.pathBlueprint.substring(
                    0,
                    testLocation.pathBlueprint.indexOf('/'),
                  ) +
                  '/*',
            ],
            check: (_, __) => true,
            beamTo: (context) => Location2(),
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
            beamTo: (context) => Location2(),
            guardNonMatching: true,
          );

          expect(guard.shouldGuard(testLocation), isTrue);
        });
      });
    });
  });
}
