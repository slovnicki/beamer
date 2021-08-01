import 'package:flutter/material.dart';

import '../beamer.dart';
import 'utils.dart';

typedef LocationBuilder = BeamLocation Function(
    RouteInformation, BeamParameters?);

/// A pre-made builder to be used for [locationBuilder].
///
/// Determines the appropriate [BeamLocation] from the list
/// and populates it with configured state.
class BeamerLocationBuilder {
  BeamerLocationBuilder({required this.beamLocations});

  /// List of all [BeamLocation]s that this builder handles.
  final List<BeamLocation> beamLocations;

  BeamLocation call(
    RouteInformation routeInformation,
    BeamParameters? beamParameters,
  ) {
    return Utils.chooseBeamLocation(
      Uri.parse(routeInformation.location ?? '/'),
      beamLocations,
      data: {'state': routeInformation.state},
    );
  }
}

/// A pre-made builder to be used for `locationBuilder`.
///
/// Creates a single [BeamLocation]; [RoutesBeamLocation]
/// and configures its [BeamLocation.buildPages] with appropriate [routes].
class RoutesLocationBuilder {
  RoutesLocationBuilder({required this.routes, this.builder});

  /// List of all routes this builder handles.
  final Map<Pattern, dynamic Function(BuildContext, BeamState)> routes;

  /// Used as a [BeamLocation.builder].
  Widget Function(BuildContext context, Widget navigator)? builder;

  BeamLocation call(
    RouteInformation routeInformation,
    BeamParameters? beamParameters,
  ) {
    final matched =
        RoutesBeamLocation.chooseRoutes(routeInformation, routes.keys);
    if (matched.isNotEmpty) {
      return RoutesBeamLocation(
        routeInformation: routeInformation,
        routes: routes,
        navBuilder: builder,
      );
    } else {
      return NotFound(path: routeInformation.location ?? '/');
    }
  }
}
