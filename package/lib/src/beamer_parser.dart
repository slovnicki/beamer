import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'beam_state.dart';

/// Converts [RouteInformation] to [BeamState] and vice-versa.
class BeamerParser extends RouteInformationParser<BeamState> {
  BeamerParser({this.onParse = _identity});

  static BeamState _identity(BeamState state) => state;

  final BeamState Function(BeamState) onParse;

  @override
  SynchronousFuture<BeamState> parseRouteInformation(
      RouteInformation routeInformation) {
    final uri = Uri.parse(routeInformation.location ?? '/');
    final beamState = BeamState.fromUri(
      uri,
      data: routeInformation.state == null
          ? {}
          : Map<String, String>.from(
              json.decode(routeInformation.state as String),
            ),
    );
    return SynchronousFuture(onParse(beamState));
  }

  @override
  RouteInformation restoreRouteInformation(BeamState beamState) {
    return RouteInformation(
      location: beamState.uri.toString(),
      state: json.encode(beamState.data),
    );
  }
}
