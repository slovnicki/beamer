import 'dart:convert';

import 'package:flutter/foundation.dart';
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
    this.data = const <String, dynamic>{},
  }) : assert(() {
          json.encode(data);
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
    Map<String, dynamic> data = const <String, dynamic>{},
  }) {
    return Utils.createBeamState(
      uri,
      beamLocation: beamLocation,
      data: data,
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
    Map<String, dynamic> data = const <String, dynamic>{},
  }) {
    uriString = Utils.trimmed(uriString);
    final uri = Uri.parse(uriString);
    return BeamState.fromUri(
      uri,
      beamLocation: beamLocation,
      data: data,
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
      data: routeInformation.state is Map<String, dynamic>
          ? routeInformation.state as Map<String, dynamic>
          : {
              'state': routeInformation.state,
            },
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

  /// Custom key/value data for arbitrary use.
  final Map<String, dynamic> data;

  late Uri _uriBlueprint;

  /// Current URI object in the "blueprint form",
  /// as it's defined in [BeamLocation.pathPatterns].
  ///
  /// This is constructed from [pathBlueprintSegments] and [queryParameters].
  /// See more at [configure].
  Uri get uriBlueprint => _uriBlueprint;

  late Uri _uri;

  /// Current URI object in the "real form",
  /// as it should be shown in browser's URL bar.
  ///
  /// This is constructed from [pathBlueprintSegments] and [queryParameters],
  /// with the addition of replacing each pathBlueprintSegment of the form ':*'
  /// with a coresponding value from [pathParameters].
  ///
  /// See more at [configure].
  Uri get uri => _uri;

  /// Copies this with configuration for specific [BeamLocation].
  BeamState copyForLocation(BeamLocation beamLocation) {
    return Utils.createBeamState(
      uri,
      beamLocation: beamLocation,
      data: data,
    );
  }

  /// Returns a configured copy of this.
  BeamState copyWith({
    List<String>? pathBlueprintSegments,
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? data,
  }) =>
      BeamState(
        pathPatternSegments: pathBlueprintSegments ?? this.pathPatternSegments,
        pathParameters: pathParameters ?? this.pathParameters,
        queryParameters: queryParameters ?? this.queryParameters,
        data: data ?? this.data,
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
      BeamState.fromUriString(
        routeInformation.location ?? '/',
        data: routeInformation.state is Map<String, dynamic>
            ? routeInformation.state as Map<String, dynamic>
            : {
                'state': routeInformation.state,
              },
      );

  @override
  RouteInformation toRouteInformation() => RouteInformation(
        location: uri.toString(),
        state: data,
      );

  @override
  int get hashCode => hashValues(uri, data);

  @override
  bool operator ==(Object other) {
    return other is BeamState &&
        other.uri == uri &&
        mapEquals(other.data, data);
  }
}
