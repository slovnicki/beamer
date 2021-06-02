import 'package:beamer/beamer.dart';
import 'package:beamer/src/beam_location.dart';
import 'package:beamer/src/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  final beamLocations = [
    Location1(BeamState()),
    Location2(BeamState()),
    CustomStateLocation(),
    RegExpLocation(),
    AsteriskLocation(),
  ];

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
      expect(location.state.pathParameters, {});

      uri = Uri.parse('/l2/123');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location.state.pathParameters, {'id': '123'});

      uri = Uri.parse('/l2/123?q=xxx');
      location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location.state.pathParameters, {'id': '123'});
      expect(location.state.queryParameters, {'q': 'xxx'});
    });

    test('Unknown URI yields NotFound location', () async {
      var uri = Uri.parse('/x');
      var location = Utils.chooseBeamLocation(uri, beamLocations);
      expect(location, isA<NotFound>());
    });

    test('Custom state is created', () {
      final uri = Uri.parse('/custom');
      final location = Utils.chooseBeamLocation(uri, beamLocations);
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
}
