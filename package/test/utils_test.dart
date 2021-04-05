import 'package:beamer/beamer.dart';
import 'package:beamer/src/beam_location.dart';
import 'package:beamer/src/utils.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_locations.dart';

void main() {
  final beamLocations = [
    Location1(BeamState()),
    Location2(BeamState()),
    CustomStateLocation(),
  ];

  group('chooseBeamLocation', () {
    test('Uri is parsed to BeamLocation', () async {
      var uri = Uri.parse('/l1');
      var location = Utils.chooseBeamLocation(uri, beamLocations);
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

    // test('Parsed BeamLocation creates correct pages', () async {
    //   var uri = Uri.parse('/l1');
    //   var location = Utils.chooseBeamLocation(uri, beamLocations);
    //   expect(location.pagesBuilder(null, location.state).length, 1);

    //   uri = Uri.parse('/l1?q=xxx');
    //   location = Utils.chooseBeamLocation(uri, beamLocations);
    //   expect(location.pagesBuilder(null, location.state).length, 1);

    //   uri = Uri.parse('/l1/one');
    //   location = Utils.chooseBeamLocation(uri, beamLocations);
    //   expect(location.pagesBuilder(null, location.state).length, 2);
    //   expect(location.pagesBuilder(null, location.state)[1].key,
    //       ValueKey('l1-one'));

    //   uri = Uri.parse('/l1/two');
    //   location = Utils.chooseBeamLocation(uri, beamLocations);
    //   expect(location.pagesBuilder(null, location.state).length, 2);
    //   expect(location.pagesBuilder(null, location.state)[1].key,
    //       ValueKey('l1-two'));
    // });

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
}
