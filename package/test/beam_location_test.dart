import 'package:beamer/beamer.dart';

import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  final location2 = Location2(BeamState(pathBlueprintSegments: ['l2', ':id']));
  group('prepare', () {
    test('BeamLocation can create valid URI', () {
      location2.state = location2.state.copyWith(
        pathParameters: {'id': '42'},
        queryParameters: {'q': 'xxx'},
      );
      expect(location2.state.uri.toString(), '/l2/42?q=xxx');
    });
  });
}
