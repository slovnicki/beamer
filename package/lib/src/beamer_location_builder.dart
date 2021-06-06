import 'package:flutter/material.dart';

import '../beamer.dart';
import 'utils.dart';

typedef LocationBuilder = BeamLocation Function(BeamState);

/// A pre-made builder to be used for [locationBuilder].
///
/// Determines the appropriate [BeamLocation] from the list
/// and populates it with configured state.
class BeamerLocationBuilder implements Function {
  BeamerLocationBuilder({required this.beamLocations});

  /// List of all [BeamLocation]s that this builder handles.
  final List<BeamLocation> beamLocations;

  BeamLocation call(BeamState state) {
    return Utils.chooseBeamLocation(state.uri, beamLocations, data: state.data);
  }
}

/// A pre-made builder to be used for [locationBuilder].
///
/// Creates a single [BeamLocation]; [SimpleBeamLocation]
/// and configures its [BeamLocation.buildPages] with appropriate [routes].
class SimpleLocationBuilder implements Function {
  SimpleLocationBuilder({required this.routes, this.builder});

  /// List of all routes this builder handles.
  final Map<dynamic, dynamic Function(BuildContext, BeamState)> routes;

  /// Used as a [BeamLocation.builder].
  Widget Function(BuildContext context, Widget navigator)? builder;

  BeamLocation call(BeamState state) {
    var matched = SimpleBeamLocation.chooseRoutes(state, routes.keys);
    if (matched.isNotEmpty) {
      return SimpleBeamLocation(
        state: state,
        routes: Map.fromEntries(
            routes.entries.where((e) => matched.containsKey(e.key))),
        navBuilder: builder,
      );
    } else {
      return NotFound(path: state.uri.path);
    }
  }
}
