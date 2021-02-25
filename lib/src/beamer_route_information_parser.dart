import 'package:beamer/src/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:beamer/src/beam_location.dart';

/// Converts [RouteInformation] to [BeamLocation] and vice-versa.
class BeamerRouteInformationParser
    extends RouteInformationParser<BeamLocation> {
  BeamerRouteInformationParser({
    @required this.beamLocations,
  });

  /// A list of all available [BeamLocation]s in the [Router]'s scope.
  final List<BeamLocation> beamLocations;

  @override
  SynchronousFuture<BeamLocation> parseRouteInformation(
      RouteInformation routeInformation) {
    final uri = Uri.parse(routeInformation.location);
    return SynchronousFuture(Utils.chooseBeamLocation(uri, beamLocations));
  }

  @override
  RouteInformation restoreRouteInformation(BeamLocation location) {
    return RouteInformation(location: location.uri);
  }
}
