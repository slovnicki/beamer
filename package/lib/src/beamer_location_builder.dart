import 'package:flutter/material.dart';

import '../beamer.dart';
import 'utils.dart';

typedef LocationBuilder = BeamLocation Function(BeamState);

class BeamerLocationBuilder implements Function {
  BeamerLocationBuilder({required this.beamLocations});

  /// List of all [BeamLocation]s that this builder handles.
  final List<BeamLocation> beamLocations;

  BeamLocation call(BeamState state) {
    return Utils.chooseBeamLocation(state.uri, beamLocations, data: state.data);
  }
}

class SimpleLocationBuilder implements Function {
  SimpleLocationBuilder({required this.routes, this.builder});

  /// List of all routes this builder handles.
  final Map<String, WidgetBuilder> routes;

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
