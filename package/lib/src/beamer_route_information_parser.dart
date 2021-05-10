import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'beam_state.dart';

/// Converts [RouteInformation] to [BeamState] and vice-versa.
class BeamerRouteInformationParser extends RouteInformationParser<BeamState> {
  @override
  SynchronousFuture<BeamState> parseRouteInformation(
      RouteInformation routeInformation) {
    final uri = Uri.parse(routeInformation.location ?? '/');
    return SynchronousFuture(
      BeamState.fromUri(
        uri,
        data: routeInformation.state == null
            ? {}
            : Map<String, String>.from(
                json.decode(routeInformation.state as String),
              ),
      ),
    );
  }

  @override
  RouteInformation restoreRouteInformation(BeamState beamState) {
    return RouteInformation(
      location: beamState.uri.toString(),
      state: json.encode(beamState.data),
    );
  }
}
