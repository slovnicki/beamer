import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import './utils.dart';
import './beam_location.dart';

/// A state for [BeamerDelegate] and [BeamLocation].
///
/// Helps in building the pages and creates an URI.
class BeamState {
  BeamState({
    this.pathBlueprintSegments = const <String>[],
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
  /// its path blueprints to populate the [pathParameters] attribute.
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

  /// Path segments of the current URI,
  /// in the form as it's defined in [BeamLocation.pathBlueprints].
  ///
  /// If current URI is '/books/1', this will be `['books', ':bookId']`.
  final List<String> pathBlueprintSegments;

  /// Path parameters from the URI,
  /// in the form as it's defined in [BeamLocation.pathBlueprints].
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
  /// as it's defined in [BeamLocation.pathBlueprints].
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
        pathBlueprintSegments:
            pathBlueprintSegments ?? this.pathBlueprintSegments,
        pathParameters: pathParameters ?? this.pathParameters,
        queryParameters: queryParameters ?? this.queryParameters,
        data: data ?? this.data,
      )..configure();

  /// Constructs [uriBlueprint] and [uri].
  void configure() {
    _uriBlueprint = Uri(
      path: '/' + pathBlueprintSegments.join('/'),
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    final pathSegments = pathBlueprintSegments.toList();
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
  int get hashCode => hashValues(uri, data);

  @override
  bool operator ==(Object other) {
    return other is BeamState &&
        other.uri == uri &&
        mapEquals(other.data, data);
  }
}
