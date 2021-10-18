import 'dart:convert';

import 'package:flutter/widgets.dart';

import './utils.dart';
import './beam_location.dart';

/// A class to mix with when defining a custom state for [BeamLocation].
///
/// [fromRouteInformation] and [toRouteInformation] need to be implemented in
/// order to notify the platform of current [RouteInformation] that corresponds
/// to the state.
mixin RouteInformationSerializable<T> {
  T fromRouteInformation(RouteInformation routeInformation);
  RouteInformation toRouteInformation();
  RouteInformation get routeInformation => toRouteInformation();
}

/// A pre-made state for [BeamLocation].
///
/// This can be used when one does not desire to define its own state.
class BeamState with RouteInformationSerializable<BeamState> {
  BeamState({
    this.pathPatternSegments = const <String>[],
    this.pathParameters = const <String, String>{},
    this.queryParameters = const <String, String>{},
    this.routeState,
  }) : assert(() {
          json.encode(routeState);
          return true;
        }()) {
    configure();
  }

  /// Creates a [BeamState] from given [uri] and optional [data].
  ///
  /// If [beamLocation] is given, then it will take into consideration
  /// its `pathPatterns` to populate the [pathParameters] attribute.
  ///
  /// See [Utils.createBeamState].
  factory BeamState.fromUri(
    Uri uri, {
    BeamLocation? beamLocation,
    Object? routeState,
  }) {
    return Utils.createBeamState(
      uri,
      beamLocation: beamLocation,
      routeState: routeState,
    );
  }

  /// Creates a [BeamState] from given [uriString] and optional [data].
  ///
  /// If [beamLocation] is given, then it will take into consideration
  /// its path blueprints to populate the [pathParameters] attribute.
  ///
  /// See [BeamState.fromUri].
  factory BeamState.fromUriString(
    String uriString, {
    BeamLocation? beamLocation,
    Object? routeState,
  }) {
    uriString = Utils.trimmed(uriString);
    final uri = Uri.parse(uriString);
    return BeamState.fromUri(
      uri,
      beamLocation: beamLocation,
      routeState: routeState,
    );
  }

  /// Creates a [BeamState] from given [routeInformation].
  ///
  /// If [beamLocation] is given, then it will take into consideration
  /// its path blueprints to populate the [pathParameters] attribute.
  ///
  /// See [BeamState.fromUri].
  factory BeamState.fromRouteInformation(
    RouteInformation routeInformation, {
    BeamLocation? beamLocation,
  }) {
    return BeamState.fromUri(
      Uri.parse(routeInformation.location ?? '/'),
      beamLocation: beamLocation,
      routeState: routeInformation.state,
    );
  }

  /// Path segments of the current URI,
  /// in the form as it's defined in [BeamLocation.pathPatterns].
  ///
  /// If current URI is '/books/1', this will be `['books', ':bookId']`.
  final List<String> pathPatternSegments;

  /// Path parameters from the URI,
  /// in the form as it's defined in [BeamLocation.pathPatterns].
  ///
  /// If current URI is '/books/1', this will be `{'bookId': '1'}`.
  final Map<String, String> pathParameters;

  /// Query parameters of the current URI.
  ///
  /// If current URI is '/books?title=str', this will be `{'title': 'str'}`.
  final Map<String, String> queryParameters;

  /// An object that will be passed to [RouteInformation.state]
  /// that is stored as a part of browser history entry.
  ///
  /// This needs to be serializable.
  final Object? routeState;

  late Uri _uriBlueprint;

  /// Current URI object in the "blueprint form",
  /// as it's defined in [BeamLocation.pathPatterns].
  ///
  /// This is constructed from [pathPatternSegments] and [queryParameters].
  /// See more at [configure].
  Uri get uriBlueprint => _uriBlueprint;

  late Uri _uri;

  /// Current URI object in the "real form",
  /// as it should be shown in browser's URL bar.
  ///
  /// This is constructed from [pathPatternSegments] and [queryParameters],
  /// with the addition of replacing each pathPatternSegment of the form ':*'
  /// with a coresponding value from [pathParameters].
  ///
  /// See more at [configure].
  Uri get uri => _uri;

  /// Copies this with configuration for specific [BeamLocation].
  BeamState copyForLocation(BeamLocation beamLocation, Object? routeState) {
    return Utils.createBeamState(
      uri,
      beamLocation: beamLocation,
      routeState: routeState,
    );
  }

  /// Returns a configured copy of this.
  BeamState copyWith({
    List<String>? pathPatternSegments,
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
    Object? routeState,
  }) =>
      BeamState(
        pathPatternSegments: pathPatternSegments ?? this.pathPatternSegments,
        pathParameters: pathParameters ?? this.pathParameters,
        queryParameters: queryParameters ?? this.queryParameters,
        routeState: routeState ?? this.routeState,
      )..configure();

  /// Constructs [uriBlueprint] and [uri].
  void configure() {
    _uriBlueprint = Uri(
      path: '/' + pathPatternSegments.join('/'),
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    final pathSegments = pathPatternSegments.toList();
    for (int i = 0; i < pathSegments.length; i++) {
      if (pathSegments[i].isNotEmpty && pathSegments[i][0] == ':') {
        final key = pathSegments[i].substring(1);
        if (pathParameters.containsKey(key)) {
          pathSegments[i] = pathParameters[key]!;
        }
      }
    }
    _uri = Uri(
      path: '/' + pathSegments.join('/'),
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
  }

  @override
  BeamState fromRouteInformation(RouteInformation routeInformation) =>
      BeamState.fromRouteInformation(routeInformation);

  @override
  RouteInformation toRouteInformation() => RouteInformation(
        location: uri.toString(),
        state: routeState,
      );

  @override
  int get hashCode => hashValues(uri, json.encode(routeState));

  @override
  bool operator ==(Object other) {
    return other is BeamState &&
        other.uri == uri &&
        json.encode(other.routeState) == json.encode(routeState);
  }
}
