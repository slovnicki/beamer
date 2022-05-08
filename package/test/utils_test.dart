import 'package:beamer/beamer.dart';
import 'package:beamer/src/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  final beamLocations = <BeamLocation>[
    Location1(),
    Location2(const RouteInformation()),
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

    test('Appending', () {
      const current = RouteInformation(location: '/current');
      expect(
        Utils.maybeAppend(current, const RouteInformation()).location,
        current.location,
      );
      expect(
        Utils.maybeAppend(current, const RouteInformation(location: 'incoming'))
            .location,
        '/current/incoming',
      );
      expect(
        Utils.maybeAppend(
                current, const RouteInformation(location: '/incoming'))
            .location,
        '/incoming',
      );
    });
  });

  group('RouteInformation equality', () {
    test('identical are equal', () {
      const ri = RouteInformation();

      expect(ri.isEqualTo(ri), isTrue);
    });

    test('empty are equal', () {
      const ri1 = RouteInformation();
      const ri2 = RouteInformation();

      expect(ri1.isEqualTo(ri2), isTrue);
    });

    test('full are equal', () {
      const ri1 = RouteInformation(location: '/x', state: 1);
      const ri2 = RouteInformation(location: '/x', state: 1);

      expect(ri1.isEqualTo(ri2), isTrue);
    });

    test('not equal with type mismatch', () {
      const ri1 = RouteInformation(location: '/x', state: 1);
      const ri2 = null;

      expect(ri1.isEqualTo(ri2), isFalse);
    });

    test('not equal with location diff', () {
      const ri1 = RouteInformation(location: '/x', state: 1);
      const ri2 = RouteInformation(location: '/y', state: 1);

      expect(ri1.isEqualTo(ri2), isFalse);
    });

    test('not equal with state diff', () {
      const ri1 = RouteInformation(location: '/x', state: 1);
      const ri2 = RouteInformation(location: '/x', state: 2);

      expect(ri1.isEqualTo(ri2), isFalse);
    });
  });
}
