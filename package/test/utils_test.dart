import 'package:beamer/beamer.dart';
import 'package:beamer/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  final beamLocations = <BeamLocation>[
    Location1(),
    Location2(RouteInformation(uri: Uri())),
    CustomStateLocation(),
    RegExpLocation(),
    AsteriskLocation(),
  ];

  group('createBeamState', () {
    test('uri and uriBlueprint are correct without BeamLocation', () {
      final uri = Uri.parse('/l2/123');
      final state = Utils.createBeamState(uri);
      expect(state.uri.path, '/l2/123');
      expect(state.uriBlueprint.path, '/l2/123');
    });

    test('uri and uriBlueprint are correct with BeamLocation', () {
      final uri = Uri.parse('/l2/123');
      final state = Utils.createBeamState(uri, beamLocation: beamLocations[1]);
      expect(state.uri.path, '/l2/123');
      expect(state.uriBlueprint.path, '/l2/:id');
    });
  });

  group('chooseBeamLocation', () {
    test('Uri is parsed to BeamLocation', () async {
      var uri = Uri.parse('/l1');
      var location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<Location1>());

      uri = Uri.parse('/l1/');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<Location1>());

      uri = Uri.parse('/l1?q=xxx');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<Location1>());

      uri = Uri.parse('/l1/one');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<Location1>());

      uri = Uri.parse('/l1/two');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<Location1>());

      uri = Uri.parse('/l2');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<Location2>());

      uri = Uri.parse('/l2/123?q=xxx');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<Location2>());
      expect((location.state as BeamState).uri.path, '/l2/123');
      expect((location.state as BeamState).uriBlueprint.path, '/l2/:id');

      uri = Uri.parse('/reg');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<RegExpLocation>());

      uri = Uri.parse('/reg/');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<RegExpLocation>());

      uri = Uri.parse('/anything');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<AsteriskLocation>());

      uri = Uri.parse('/anything/');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<AsteriskLocation>());

      uri = Uri.parse('/anything/can/be/here');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<AsteriskLocation>());
    });

    test('Parsed BeamLocation carries URL parameters', () async {
      var uri = Uri.parse('/l2');
      var location = Utils.chooseBeamLocation(uri, beamLocations);
      expect((location.state as BeamState).pathParameters, {});

      uri = Uri.parse('/l2/123');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect((location.state as BeamState).pathParameters, {'id': '123'});

      uri = Uri.parse('/l2/123?q=xxx');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect((location.state as BeamState).pathParameters, {'id': '123'});
      expect((location.state as BeamState).queryParameters, {'q': 'xxx'});
    });

    test('Unknown URI yields NotFound location', () async {
      final uri = Uri.parse('/x');
      final location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<NotFound>());
    });

    test('Custom state is created', () {
      var uri = Uri.parse('/custom');
      var location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<CustomStateLocation>());
      expect((location as CustomStateLocation).state.customVar, '');

      uri = Uri.parse('/custom/test');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<CustomStateLocation>());
      expect((location as CustomStateLocation).state.customVar, 'test');
    });
  });

  test('tryCastToRegExp throws', () {
    expect(
      () => Utils.tryCastToRegExp('not-regexp'),
      throwsA(isA<FlutterError>()),
    );
  });

  group('Creating new configuration for BeamerDelegate', () {
    test('Trimming', () {
      expect(Utils.trimmed(null), '');
      expect(Utils.trimmed('/'), '/');
      expect(Utils.trimmed('/xxx/'), '/xxx');
    });

    test('Appending without new routeState', () {
      final current = RouteInformation(uri: Uri.parse('/current'));
      expect(
        Utils.maybeAppend(current, RouteInformation(uri: Uri.parse('incoming')))
            .uri
            .toString(),
        '/current/incoming',
      );
      expect(
        Utils.maybeAppend(
                current, RouteInformation(uri: Uri.parse('/incoming')))
            .uri
            .toString(),
        '/incoming',
      );
      expect(
        Utils.maybeAppend(current, RouteInformation(uri: Uri.parse('')))
            .uri
            .toString(),
        '',
      );
      expect(
        Utils.maybeAppend(current, RouteInformation(uri: Uri.parse('/')))
            .uri
            .toString(),
        '/',
      );
      expect(
        Utils.maybeAppend(current,
                RouteInformation(uri: Uri.parse('example://app/incoming')))
            .uri
            .toString(),
        'example://app/incoming',
      );
      expect(
        Utils.maybeAppend(current,
                RouteInformation(uri: Uri.parse('example://app/incoming')))
            .uri
            .toString(),
        'example://app/incoming',
      );
      expect(
        Utils.maybeAppend(
                current, RouteInformation(uri: Uri.parse('//app/incoming')))
            .uri
            .toString(),
        '//app/incoming',
      );
    });

    test('Appending with new routeState', () {
      final current = RouteInformation(uri: Uri.parse('/current'));
      expect(
        Utils.maybeAppend(current, RouteInformation(uri: Uri(), state: 42))
            .state,
        42,
      );
      expect(
        Utils.maybeAppend(current,
                RouteInformation(uri: Uri.parse('incoming'), state: 42))
            .state,
        42,
      );
      expect(
        Utils.maybeAppend(current,
                RouteInformation(uri: Uri.parse('/incoming'), state: 42))
            .state,
        42,
      );
      expect(
        Utils.maybeAppend(
            current,
            RouteInformation(
              uri: Uri.parse('example://app/incoming'),
              state: 42,
            )).state,
        42,
      );
      expect(
        Utils.maybeAppend(
            current,
            RouteInformation(
              uri: Uri.parse('//app/incoming'),
              state: 42,
            )).state,
        42,
      );
    });
  });

  group('RouteInformation equality', () {
    test('identical are equal', () {
      final ri = RouteInformation(uri: Uri());

      expect(ri.isEqualTo(ri), isTrue);
    });

    test('empty are equal', () {
      final ri1 = RouteInformation(uri: Uri());
      final ri2 = RouteInformation(uri: Uri());

      expect(ri1.isEqualTo(ri2), isTrue);
    });

    test('full are equal', () {
      final ri1 = RouteInformation(uri: Uri.parse('/x'), state: 1);
      final ri2 = RouteInformation(uri: Uri.parse('/x'), state: 1);

      expect(ri1.isEqualTo(ri2), isTrue);
    });

    test('not equal with type mismatch', () {
      final ri1 = RouteInformation(uri: Uri.parse('/x'), state: 1);
      final ri2 = null;

      expect(ri1.isEqualTo(ri2), isFalse);
    });

    test('not equal with location diff', () {
      final ri1 = RouteInformation(uri: Uri.parse('/x'), state: 1);
      final ri2 = RouteInformation(uri: Uri.parse('/y'), state: 1);

      expect(ri1.isEqualTo(ri2), isFalse);
    });

    test('not equal with state diff', () {
      final ri1 = RouteInformation(uri: Uri.parse('/x'), state: 1);
      final ri2 = RouteInformation(uri: Uri.parse('/x'), state: 2);

      expect(ri1.isEqualTo(ri2), isFalse);
    });
  });
}
