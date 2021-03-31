import 'package:flutter/material.dart';

import '../beamer.dart';
import 'utils.dart';

typedef LocationBuilder = BeamLocation Function(BeamState);

class BeamerLocationBuilder implements Function {
  BeamerLocationBuilder({@required this.beamLocations});

  /// List of all [BeamLocation]s that this builder handles.
  final List<BeamLocation> beamLocations;

  BeamLocation call(BeamState state) {
    return Utils.chooseBeamLocation(state.uri, beamLocations, data: state.data);
  }
}

class SimpleLocationBuilder implements Function {
  SimpleLocationBuilder({@required this.routes, this.builder});

  /// List of all routes this builder handles.
  final Map<String, WidgetBuilder> routes;

  Widget Function(BuildContext context, Widget navigator) builder;

  BeamLocation call(BeamState state) {
    var matched = SimpleBeamLocation.chooseRoutes(state, routes.keys);
    if (matched.isNotEmpty) {
      return SimpleBeamLocation(
        state,
        Map.fromEntries(
            routes.entries.where((e) => matched.containsKey(e.key))),
        builder,
      );
    } else {
      return NotFound(path: state.uri.path);
    }
  }
}

class SimpleBeamLocation extends BeamLocation {
  SimpleBeamLocation(BeamState state, this.routes, this.navBuilder)
      : super(state);

  /// Map of all routes this location handles.
  Map<String, WidgetBuilder> routes;

  Widget Function(BuildContext context, Widget navigator) navBuilder;

  @override
  Widget builder(BuildContext context, Widget navigator) {
    if (navBuilder != null) {
      return navBuilder(context, navigator);
    } else {
      return navigator;
    }
  }

  List<String> get sortedRoutes =>
      routes.keys.toList()..sort((a, b) => a.length - b.length);

  @override
  List<String> get pathBlueprints => [sortedRoutes.last];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) {
    var filteredRoutes = chooseRoutes(state, routes.keys);
    routes.removeWhere((key, value) => !filteredRoutes.containsKey(key));
    return sortedRoutes.map((route) {
      return BeamPage(
        key: ValueKey(filteredRoutes[route]),
        child: routes[route](context),
      );
    }).toList();
  }

  static Map<String, String> chooseRoutes(
      BeamState state, Iterable<String> routes) {
    var matched = <String, String>{};
    for (var route in routes) {
      final uriPathSegments = List.from(state.uri.pathSegments);
      if (uriPathSegments.length > 1 && uriPathSegments.last == '') {
        uriPathSegments.removeLast();
      }

      final routePathSegments = Uri.parse(route).pathSegments;

      if (uriPathSegments.length < routePathSegments.length) {
        continue;
      }

      var checksPassed = true;
      var path = '';

      for (int i = 0; i < routePathSegments.length; i++) {
        path += '/${uriPathSegments[i]}';
        if (routePathSegments[i] == '*' ||
            routePathSegments[i].startsWith(':')) {
          continue;
        }
        if (routePathSegments[i] != uriPathSegments[i]) {
          checksPassed = false;
          break;
        }
      }

      if (checksPassed) {
        matched[route] = path;
      }
    }
    return matched;
  }
}
