import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final parser = BeamerParser();

  test('parsing from RouteInformation to RouteInformation', () async {
    final routeInformation = await parser.parseRouteInformation(
      RouteInformation(
        uri: Uri.parse('/test'),
        state: {'x': 'y'},
      ),
    );

    expect(routeInformation.uri.path, equals('/test'));
    expect(routeInformation.state, equals({'x': 'y'}));
  });

  test('parsing from RouteInformation to RouteInformation', () {
    final routeInformation = parser.restoreRouteInformation(
      RouteInformation(
        uri: Uri.parse('/test'),
        state: {'x': 'y'},
      ),
    );

    expect(routeInformation.uri.path, equals('/test'));
    expect(routeInformation.state, equals({'x': 'y'}));
  });
}
