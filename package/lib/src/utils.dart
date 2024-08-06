import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

/// Some useful methods for beaming process configuration.
abstract class Utils {
  /// Traverses [beamStacks] and returns the one whose one of
  /// `pathPatterns` contains the [uri], ignoring concrete path parameters.
  ///
  /// Upon finding such [BeamStack], configures it with
  /// `pathParameters` and `queryParameters` from [uri].
  ///
  /// If [beamStacks] don't contain a match, [NotFound] will be returned
  /// configured with [uri].
  static BeamStack chooseBeamStack(
    Uri uri,
    List<BeamStack> beamStacks, {
    Object? data,
    Object? routeState,
    BeamParameters? beamParameters,
  }) {
    for (final beamStack in beamStacks) {
      if (beamStack.canHandle(uri)) {
        final routeInformation = RouteInformation(uri: uri, state: routeState);
        if (!beamStack.isCurrent) {
          beamStack.create(routeInformation, beamParameters);
        } else {
          beamStack.update(null, routeInformation, beamParameters, false);
        }
        return beamStack;
      }
    }
    return NotFound(path: uri.path);
  }

  /// Creates a state for [BeamStack] based on incoming [uri].
  ///
  /// Used in [BeamState.copyForStack].
  static BeamState createBeamState(
    Uri uri, {
    BeamStack? beamStack,
    Object? routeState,
  }) {
    final pathParameters = <String, String>{};

    for (final pathPattern in [...?beamStack?.pathPatterns]) {
      if (pathPattern is! String) {
        final pathPatternRegex = pathPattern.toRegExp;
        final url = uri.toString();

        if (pathPatternRegex.hasMatch(url)) {
          final matches = pathPatternRegex.allMatches(url);

          for (final match in matches) {
            for (final groupName in match.groupNames) {
              pathParameters[groupName] = match.namedGroup(groupName) ?? '';
            }
          }
        }
      } else {
        if (pathPattern == uri.path || pathPattern == '/*') {
          return BeamState(
            pathPatternSegments: uri.pathSegments,
            queryParameters: uri.queryParameters,
            routeState: routeState,
          );
        }

        final uriPathSegments = uri.pathSegments.toList();
        if (uriPathSegments.length > 1 && uriPathSegments.last == '') {
          uriPathSegments.removeLast();
        }

        final beamStackPathBlueprintSegments =
            Uri.parse(pathPattern).pathSegments;
        var pathSegments = <String>[];

        if (uriPathSegments.length > beamStackPathBlueprintSegments.length &&
            !beamStackPathBlueprintSegments.contains('*')) continue;

        var checksPassed = true;

        for (var i = 0; i < uriPathSegments.length; i++) {
          if (beamStackPathBlueprintSegments[i] == '*') {
            pathSegments = uriPathSegments.toList();
            checksPassed = true;
            break;
          }

          if (uriPathSegments[i] != beamStackPathBlueprintSegments[i] &&
              beamStackPathBlueprintSegments[i][0] != ':') {
            checksPassed = false;
            break;
          } else if (beamStackPathBlueprintSegments[i][0] == ':') {
            pathParameters[beamStackPathBlueprintSegments[i].substring(1)] =
                uriPathSegments[i];
            pathSegments.add(beamStackPathBlueprintSegments[i]);
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
      }
    }

    return BeamState(
      pathPatternSegments: uri.pathSegments,
      queryParameters: uri.queryParameters,
      pathParameters: pathParameters,
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
      final regExpPattern = pattern.toRegExp;
      return regExpPattern.hasMatch(exact.toString());
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

  /// Whether two `RouteInformation`s have the same uri and state.
  ///
  /// This is intentionally **not** overriding the equality operator.
  bool isEqualTo(Object? other) {
    if (other is! RouteInformation) {
      return false;
    }
    return uri == other.uri && state == other.state;
  }
}

/// Some convenient extension methods on [Pattern].
extension PatternExtension on Pattern {
  /// Wraps the casting of this pattern to RegExp inside a try-catch
  /// and throws a nice FlutterError.
  RegExp get toRegExp {
    try {
      return this as RegExp;
    } on TypeError catch (_) {
      throw FlutterError.fromParts([
        DiagnosticsNode.message('Path blueprint can either be:',
            level: DiagnosticLevel.summary),
        DiagnosticsNode.message('1. String'),
        DiagnosticsNode.message('2. RegExp instance')
      ]);
    }
  }
}
