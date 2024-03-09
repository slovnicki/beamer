import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

/// Some useful methods for beaming process configuration.
abstract class Utils {
  /// Traverses [beamLocations] and returns the one whose one of
  /// `pathPatterns` contains the [uri], ignoring concrete path parameters.
  ///
  /// Upon finding such [BeamLocation], configures it with
  /// `pathParameters` and `queryParameters` from [uri].
  ///
  /// If [beamLocations] don't contain a match, [NotFound] will be returned
  /// configured with [uri].
  static BeamLocation chooseBeamLocation(
    Uri uri,
    List<BeamLocation> beamLocations, {
    Object? data,
    Object? routeState,
    BeamParameters? beamParameters,
  }) {
    for (final beamLocation in beamLocations) {
      if (canBeamLocationHandleUri(beamLocation, uri)) {
        final routeInformation = RouteInformation(uri: uri, state: routeState);
        if (!beamLocation.isCurrent) {
          beamLocation.create(routeInformation, beamParameters);
        } else {
          beamLocation.update(null, routeInformation, beamParameters, false);
        }
        return beamLocation;
      }
    }
    return NotFound(path: uri.path);
  }

  /// Can a [beamLocation], depending on its `pathPatterns`, handle the [uri].
  ///
  /// Used in [BeamLocation.canHandle] and [chooseBeamLocation].
  static bool canBeamLocationHandleUri(BeamLocation beamLocation, Uri uri) {
    for (final pathPattern in beamLocation.pathPatterns) {
      if (pathPattern is String) {
        // If it is an exact match or asterisk pattern
        if (pathPattern == uri.path ||
            pathPattern == '/*' ||
            pathPattern == '*') {
          return true;
        }

        // Clean URI path segments
        final uriPathSegments = uri.pathSegments.toList();
        if (uriPathSegments.length > 1 && uriPathSegments.last == '') {
          uriPathSegments.removeLast();
        }

        final pathPatternSegments = Uri.parse(pathPattern).pathSegments;

        // If we're in strict mode and URI has fewer segments than pattern,
        // we don't have a match so can continue.
        if (beamLocation.strictPathPatterns &&
            uriPathSegments.length < pathPatternSegments.length) {
          continue;
        }

        // If URI has more segments and pattern doesn't end with asterisk,
        // we don't have a match so can continue.
        if (uriPathSegments.length > pathPatternSegments.length &&
            (pathPatternSegments.isEmpty ||
                !pathPatternSegments.last.endsWith('*'))) {
          continue;
        }

        var checksPassed = true;
        // Iterating through URI segments
        for (var i = 0; i < uriPathSegments.length; i++) {
          // If all checks have passed up to i,
          // if pattern has no more segments to traverse and it ended with asterisk,
          // it is a match and we can break,
          if (pathPatternSegments.length < i + 1 &&
              pathPatternSegments.last.endsWith('*')) {
            checksPassed = true;
            break;
          }

          // If pattern has asterisk at i-th position,
          // anything matches and we can continue.
          if (pathPatternSegments[i] == '*') {
            continue;
          }
          // If they are not the same and pattern doesn't expects path parameter,
          // there's no match and we can break.
          if (uriPathSegments[i] != pathPatternSegments[i] &&
              !pathPatternSegments[i].startsWith(':')) {
            checksPassed = false;
            break;
          }
        }
        // If no check failed, beamLocation can handle this URI.
        if (checksPassed) {
          return true;
        }
      } else {
        final regexp = tryCastToRegExp(pathPattern);
        return regexp.hasMatch(uri.toString());
      }
    }
    return false;
  }

  /// Creates a state for [BeamLocation] based on incoming [uri].
  ///
  /// Used in [BeamState.copyForLocation].
  static BeamState createBeamState(
    Uri uri, {
    BeamLocation? beamLocation,
    Object? routeState,
  }) {
    if (beamLocation != null) {
      // TODO: abstract this and reuse in canBeamLocationHandleUri
      for (final pathBlueprint in beamLocation.pathPatterns) {
        if (pathBlueprint is String) {
          if (pathBlueprint == uri.path || pathBlueprint == '/*') {
            BeamState(
              pathPatternSegments: uri.pathSegments,
              queryParameters: uri.queryParameters,
              routeState: routeState,
            );
          }
          final uriPathSegments = uri.pathSegments.toList();
          if (uriPathSegments.length > 1 && uriPathSegments.last == '') {
            uriPathSegments.removeLast();
          }
          final beamLocationPathBlueprintSegments =
              Uri.parse(pathBlueprint).pathSegments;
          var pathSegments = <String>[];
          final pathParameters = <String, String>{};
          if (uriPathSegments.length >
                  beamLocationPathBlueprintSegments.length &&
              !beamLocationPathBlueprintSegments.contains('*')) {
            continue;
          }
          var checksPassed = true;
          for (var i = 0; i < uriPathSegments.length; i++) {
            if (beamLocationPathBlueprintSegments[i] == '*') {
              pathSegments = uriPathSegments.toList();
              checksPassed = true;
              break;
            }
            if (uriPathSegments[i] != beamLocationPathBlueprintSegments[i] &&
                beamLocationPathBlueprintSegments[i][0] != ':') {
              checksPassed = false;
              break;
            } else if (beamLocationPathBlueprintSegments[i][0] == ':') {
              pathParameters[beamLocationPathBlueprintSegments[i]
                  .substring(1)] = uriPathSegments[i];
              pathSegments.add(beamLocationPathBlueprintSegments[i]);
            } else {
              pathSegments.add(uriPathSegments[i]);
            }
          }
          if (checksPassed) {
            return BeamState(
              pathPatternSegments: pathSegments,
              pathParameters: pathParameters,
              queryParameters: uri.queryParameters,
              routeState: routeState,
            );
          }
        } else {
          final regexp = tryCastToRegExp(pathBlueprint);
          final pathParameters = <String, String>{};
          final url = uri.toString();

          if (regexp.hasMatch(url)) {
            regexp.allMatches(url).forEach((match) {
              for (final groupName in match.groupNames) {
                pathParameters[groupName] = match.namedGroup(groupName) ?? '';
              }
            });
            return BeamState(
              pathPatternSegments: uri.pathSegments,
              pathParameters: pathParameters,
              queryParameters: uri.queryParameters,
              routeState: routeState,
            );
          }
        }
      }
    }
    return BeamState(
      pathPatternSegments: uri.pathSegments,
      queryParameters: uri.queryParameters,
      routeState: routeState,
    );
  }

  /// Whether the [pattern] can match the [exact] URI.
  static bool urisMatch(Pattern pattern, Uri exact) {
    if (pattern is String) {
      final uriPattern = Uri.parse(pattern);
      final patternSegments = uriPattern.pathSegments;
      final exactSegment = exact.pathSegments;
      if (patternSegments.length != exactSegment.length) {
        return false;
      }
      for (var i = 0; i < patternSegments.length; i++) {
        if (patternSegments[i].startsWith(':')) {
          continue;
        }
        if (patternSegments[i] != exactSegment[i]) {
          return false;
        }
      }
      return true;
    } else {
      final regExpPattern = tryCastToRegExp(pattern);
      return regExpPattern.hasMatch(exact.toString());
    }
  }

  /// Wraps the casting of pathBlueprint to RegExp inside a try-catch
  /// and throws a nice FlutterError.
  static RegExp tryCastToRegExp(Pattern pathBlueprint) {
    try {
      return pathBlueprint as RegExp;
    } on TypeError catch (_) {
      throw FlutterError.fromParts([
        DiagnosticsNode.message('Path blueprint can either be:',
            level: DiagnosticLevel.summary),
        DiagnosticsNode.message('1. String'),
        DiagnosticsNode.message('2. RegExp instance')
      ]);
    }
  }

  /// Removes the trailing / in an URI path and returns the new URI.
  ///
  /// If there is no trailing /, returns the input URI.
  static Uri removeTrailingSlash(Uri uri) {
    String path = uri.path;
    if (path.length > 1 && path.endsWith('/')) {
      return uri.replace(path: path.substring(0, path.length - 1));
    }
    return uri;
  }

  /// If [incoming] is a relative URI append it to [current].
  /// Else, return incoming URI.
  static Uri maybeAppend(Uri current, Uri incoming) {
    if (!incoming.hasAbsolutePath && !incoming.hasEmptyPath) {
      String currentPath =
          current.path.endsWith('/') ? current.path : '${current.path}/';
      return current.replace(
        path: currentPath + incoming.path,
        query: incoming.hasQuery ? incoming.query : null,
        fragment: incoming.hasFragment ? incoming.fragment : null,
      );
    }
    return incoming;
  }

  /// Merges the URIs of the RouteInformation's.
  ///
  /// See [maybeAppend] and [removeTrailingSlash].
  static RouteInformation mergeConfiguration(
    RouteInformation current,
    RouteInformation incoming,
  ) {
    return incoming.copyWith(
      uri: maybeAppend(current.uri, removeTrailingSlash(incoming.uri)),
    );
  }

  /// Creates a new configuration for [BeamerDelegate.update].
  ///
  /// Takes into consideration trimming and potentially appending
  /// the incoming to current (used in relative beaming).
  ///
  /// See [removeTrailingSlash] and [maybeAppend].
  static RouteInformation createNewConfiguration(
    RouteInformation current,
    RouteInformation incoming,
  ) {
    return mergeConfiguration(current, incoming);
  }
}

/// Some convenient extension methods on [RouteInformation].
extension BeamerRouteInformationExtension on RouteInformation {
  /// Returns a new [RouteInformation] created from this.
  RouteInformation copyWith({
    Uri? uri,
    Object? state,
  }) {
    return RouteInformation(
      uri: uri ?? this.uri,
      state: state ?? this.state,
    );
  }

  /// Whether two `RouteInformation`s have the same location and state.
  ///
  /// This is intentionally **not** overriding the equality operator.
  bool isEqualTo(Object? other) {
    if (other is! RouteInformation) {
      return false;
    }
    return uri == other.uri && state == other.state;
  }
}
