import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:beamer/src/beam_location.dart';

class BeamerRouteInformationParser
    extends RouteInformationParser<BeamLocation> {
  BeamerRouteInformationParser({
    @required this.beamLocations,
  });

  List<BeamLocation> beamLocations;

  @override
  SynchronousFuture<BeamLocation> parseRouteInformation(
      RouteInformation routeInformation) {
    final uri = Uri.parse(routeInformation.location);
    return SynchronousFuture(_chooseBeamLocation(uri));
  }

  @override
  RouteInformation restoreRouteInformation(BeamLocation location) {
    return RouteInformation(location: location.uri);
  }

  BeamLocation _chooseBeamLocation(Uri uri) {
    for (var beamLocation in this.beamLocations) {
      if (beamLocation.pathBlueprint == uri.path) {
        beamLocation.queryParameters = uri.queryParameters;
        return beamLocation..prepare();
      }
      final List<String> beamLocationPathSegments =
          Uri.parse(beamLocation.pathBlueprint).pathSegments;
      Map<String, String> pathParameters = {};
      bool checksPassed = false;
      for (int i = 0; i < uri.pathSegments.length; i++) {
        if (beamLocationPathSegments.length < i + 1) {
          checksPassed = false;
          break;
        }
        if (uri.pathSegments[i] != beamLocationPathSegments[i] &&
            beamLocationPathSegments[i][0] != ':') {
          checksPassed = false;
          break;
        } else {
          if (beamLocationPathSegments[i][0] == ':') {
            pathParameters[beamLocationPathSegments[i].substring(1)] =
                uri.pathSegments[i];
          }
          checksPassed = true;
        }
      }
      if (checksPassed) {
        beamLocation.pathParameters = pathParameters;
        beamLocation.queryParameters = uri.queryParameters;
        return beamLocation..prepare();
      }
    }
    return null;
  }
}
