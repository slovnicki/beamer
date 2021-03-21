import 'package:beamer/beamer.dart';

abstract class Utils {
  /// Traverses `beamLocations` and returns the one whose one of
  /// `pathBlueprints` contains the `uri`, ignoring concrete path parameters.
  ///
  /// Upon finding such [BeamLocation], configures it with
  /// `pathParameters` and `queryParameters` from `uri`.
  ///
  /// If `beamLocations` don't contain a match, [NotFound] will be returned
  /// configured with `uri`.
  static BeamLocation chooseBeamLocation(
    Uri uri,
    List<BeamLocation> beamLocations, {
    Map<String, dynamic> data = const <String, dynamic>{},
  }) {
    for (var beamLocation in beamLocations) {
      for (var pathBlueprint in beamLocation.pathBlueprints) {
        if (pathBlueprint == uri.path || pathBlueprint == '/*') {
          beamLocation.state = beamLocation.createState(
            uri.pathSegments,
            {},
            uri.queryParameters,
            data,
          );
          //print('returning: ${uri.pathSegments} for $beamLocation');
          return beamLocation..prepare();
        }
        final uriPathSegments = List.from(uri.pathSegments);
        if (uriPathSegments.length > 1 && uriPathSegments.last == '') {
          uriPathSegments.removeLast();
        }
        final beamLocationPathBlueprintSegments =
            Uri.parse(pathBlueprint).pathSegments;
        var pathSegments = <String>[];
        var pathParameters = <String, String>{};
        if (uriPathSegments.length > beamLocationPathBlueprintSegments.length &&
            !beamLocationPathBlueprintSegments.contains('*')) {
          continue;
        }
        var checksPassed = true;
        for (int i = 0; i < uriPathSegments.length; i++) {
          if (beamLocationPathBlueprintSegments[i] == '*') {
            pathSegments = List<String>.from(uriPathSegments);
            checksPassed = true;
            break;
          }
          if (uriPathSegments[i] != beamLocationPathBlueprintSegments[i] &&
              beamLocationPathBlueprintSegments[i][0] != ':') {
            checksPassed = false;
            break;
          } else if (beamLocationPathBlueprintSegments[i][0] == ':') {
            pathParameters[beamLocationPathBlueprintSegments[i].substring(1)] =
                uriPathSegments[i];
            pathSegments.add(beamLocationPathBlueprintSegments[i]);
          } else {
            pathSegments.add(uriPathSegments[i]);
          }
        }
        if (checksPassed) {
          beamLocation.state = beamLocation.createState(
            pathSegments,
            pathParameters,
            uri.queryParameters,
            data,
          );
          //print('returning: ${pathSegments} for $beamLocation');
          return beamLocation..prepare();
        }
      }
    }
    return NotFound(path: uri.path);
  }
}
