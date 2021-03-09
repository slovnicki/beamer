import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  final location2 = Location2(pathBlueprint: '/l2/:id');
  group('prepare', () {
    test('BeamLocation can create valid URI', () {
      location2.pathParameters = {'id': '42'};
      location2.queryParameters = {'q': 'xxx'};
      location2.prepare();
      expect(location2.uri.toString(), '/l2/42?q=xxx');
    });

    test('BeamLocation can create valid URI while using named constructor', () {
      final location2WithParameters = Location2(
        pathBlueprint: '/l2/:id',
        pathParameters: {'id': '42'},
        queryParameters: {'q': 'xxx'},
      );
      location2WithParameters.prepare();
      expect(location2WithParameters.uri.toString(), '/l2/42?q=xxx');
    });
  });
}
