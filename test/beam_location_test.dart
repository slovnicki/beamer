import 'package:beamer/src/beam_state.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  final location2 = Location2(pathBlueprint: '/l2/:id');
  group('prepare', () {
    test('BeamLocation can create valid URI', () {
      location2.state = location2.state.copyWith(
        pathParameters: {'id': '42'},
        queryParameters: {'q': 'xxx'},
      );
      location2.prepare();
      expect(location2.state.uri.toString(), '/l2/42?q=xxx');
    });
  });
}
