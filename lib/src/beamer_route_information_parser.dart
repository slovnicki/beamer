import 'package:flutter/widgets.dart';

import 'package:beamer/src/beam_location.dart';

class BeamerRouteInformationParser
    extends RouteInformationParser<BeamLocation> {
  BeamerRouteInformationParser({
    @required this.beamLocations,
  });

  List<BeamLocation> beamLocations;

  @override
  Future<BeamLocation> parseRouteInformation(
      RouteInformation routeInformation) async {
    final uri = Uri.parse(routeInformation.location);
    // print('Inside parseRouteInformation...');
    // print('path ' + uri.path);
    // print('pathSegments ' + uri.pathSegments.toString());
    // print('... done with parseRouteInformation');
    return _chooseBeamLocation(uri);
  }

  @override
  RouteInformation restoreRouteInformation(BeamLocation location) {
    return RouteInformation(location: location.uri);
  }

  BeamLocation _chooseBeamLocation(Uri uri) {
    // print('Inside _chooseBeamLocation...');
    // print('choosing from ${this.beamLocations.toString()}');
    for (var beamLocation in this.beamLocations) {
      //print(
      //    'trying to match ${beamLocation.pathBlueprint} with ${uri.path} => ${beamLocation.pathBlueprint == uri.path}');
      // try to match if path is identical to pathBlueprint
      if (beamLocation.pathBlueprint == uri.path) {
        //print('Done(1) with _chooseBeamLocation... with ${beamLocation.path}');
        beamLocation.queryParameters = uri.queryParameters;
        return beamLocation..prepare();
      }
      // try to match by ignoring the pathBlueprint's dummy values
      final List<String> beamLocationPathSegments =
          Uri.parse(beamLocation.pathBlueprint).pathSegments;
      Map<String, String> pathParameters = {};
      //print('checking for dummy with $beamLocationPathSegments');
      bool checksPassed = false;
      for (int i = 0; i < uri.pathSegments.length; i++) {
        if (beamLocationPathSegments.length < i + 1) {
          //print(beamLocation.path + ' is definitely not');
          checksPassed = false;
          break;
        }
        //print(
        //    'checking ${beamLocationPathSegments[i]} and ${uri.pathSegments[i]}');
        if (uri.pathSegments[i] != beamLocationPathSegments[i] &&
            beamLocationPathSegments[i][0] != ':') {
          //print(beamLocation.path + ' is definitely not');
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
        //print('Done(2) with _chooseBeamLocation... with ${beamLocation.path}');
        beamLocation.pathParameters = pathParameters;
        beamLocation.queryParameters = uri.queryParameters;
        return beamLocation..prepare();
      }
    }
    //print('Done(3) with _chooseBeamLocation... with null');
    return null;
  }
}
