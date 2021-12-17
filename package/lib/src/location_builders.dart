import 'package:flutter/material.dart';

import 'package:beamer/beamer.dart';
import 'package:beamer/src/utils.dart';

/// A convenience typedef for [BeamerDelegate.locationBuilder].
typedef LocationBuilder = BeamLocation Function(
  RouteInformation,
  BeamParameters?,
);

/// A pre-made builder to be used for [BeamerDelegate.locationBuilder].
///
/// Determines the appropriate [BeamLocation] from the list
/// and populates it with configured state.
class BeamerLocationBuilder {
  /// Creates a [BeamerLocationBuilder] with specified property.
  ///
  /// [beamLocations] is a required list of [BeamLocation]s.
  BeamerLocationBuilder({required this.beamLocations});

  /// List of all [BeamLocation]s that this builder handles.
  final List<BeamLocation> beamLocations;

  /// Makes this callable as [LocationBuilder].
  ///
  /// Returns [Utils.chooseBeamLocation].
  BeamLocation call(
    RouteInformation routeInformation,
    BeamParameters? beamParameters,
  ) {
    return Utils.chooseBeamLocation(
      Uri.parse(routeInformation.location ?? '/'),
      beamLocations,
      routeState: routeInformation.state,
    );
  }
}

/// A pre-made builder to be used for [BeamerDelegate.locationBuilder].
///
/// Creates a single [BeamLocation]; [RoutesBeamLocation]
/// and configures its [BeamLocation.buildPages] from specified [routes].
class RoutesLocationBuilder {
  /// Creates a [RoutesLocationBuilder] with specified properties.
  ///
  /// [routes] are required to build pages from.
  RoutesLocationBuilder({required this.routes, this.builder});

  /// List of all routes this builder handles.
  final Map<Pattern, dynamic Function(BuildContext, BeamState, Object?)> routes;

  /// Used as a [BeamLocation.builder].
  Widget Function(BuildContext context, Widget navigator)? builder;

  /// Makes this callable as [LocationBuilder].
  ///
  /// Returns [RoutesBeamLocation] configured with chosen routes from [routes] or [NotFound].
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
