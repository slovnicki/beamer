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
  }) {
    for (final beamLocation in beamLocations) {
      if (canBeamLocationHandleUri(beamLocation, uri)) {
        final routeInformation = RouteInformation(
          location: uri.toString(),
          state: routeState,
        );
        return beamLocation..create(routeInformation);
      }
    }
    return NotFound(path: uri.path);
  }

  /// Can a [beamLocation], depending on its `pathPatterns`, handle the [uri].
  ///
  /// Used in [BeamLocation.canHandle] and [chooseBeamLocation].
  static bool canBeamLocationHandleUri(BeamLocation beamLocation, Uri uri) {
    for (final pathBlueprint in beamLocation.pathPatterns) {
      if (pathBlueprint is String) {
        if (pathBlueprint == uri.path || pathBlueprint == '/*') {
          return true;
        }
        final uriPathSegments = uri.pathSegments.toList();
        if (uriPathSegments.length > 1 && uriPathSegments.last == '') {
          uriPathSegments.removeLast();
        }
        final beamLocationPathBlueprintSegments =
            Uri.parse(pathBlueprint).pathSegments;
        if (uriPathSegments.length > beamLocationPathBlueprintSegments.length &&
            !beamLocationPathBlueprintSegments.contains('*')) {
          continue;
        }
        var checksPassed = true;
        for (int i = 0; i < uriPathSegments.length; i++) {
          if (beamLocationPathBlueprintSegments[i] == '*') {
            checksPassed = true;
            break;
          }
          if (uriPathSegments[i] != beamLocationPathBlueprintSegments[i] &&
              beamLocationPathBlueprintSegments[i][0] != ':') {
            checksPassed = false;
            break;
          }
        }
        if (checksPassed) {
          return true;
        }
      } else {
        final regexp = tryCastToRegExp(pathBlueprint);
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
          for (int i = 0; i < uriPathSegments.length; i++) {
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
      for (int i = 0; i < patternSegments.length; i++) {
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

  /// Removes the trailing / in an URI String and returns the result.
  ///
  /// If there is no trailing /, returns the input.
  static String trimmed(String? uri) {
    if (uri == null) {
      return '/';
    }
    if (uri.length > 1 && uri.endsWith('/')) {
      return uri.substring(0, uri.length - 1);
    }
    return uri;
  }
}
