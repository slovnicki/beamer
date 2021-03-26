import 'package:flutter/material.dart';

import '../beamer.dart';
import 'utils.dart';

typedef LocationBuilder = BeamLocation Function(BeamState);

class BeamerLocationBuilder implements Function {
  BeamerLocationBuilder({@required this.beamLocations});

  /// List of all [BeamLocation]s that this builder handles.
  final List<BeamLocation> Function(BeamState) beamLocations;

  List<BeamLocation> _beamLocations;

  BeamLocation call(BeamState state) {
    _beamLocations ??= beamLocations(state);
    return Utils.chooseBeamLocation(state.uri, _beamLocations,
        data: state.data);
  }
}

class SimpleLocationBuilder implements Function {
  SimpleLocationBuilder({@required this.routes});

  /// List of all routes this builder handles.
  final Map<String, WidgetBuilder> routes;

  BeamLocation call(BeamState state) {
    var matched = chooseRoutes(state, routes.keys);
    if (matched.isNotEmpty) {
      return SimpleBeamLocation(
        state,
        Map.fromEntries(routes.entries.where((e) => matched.contains(e.key))),
      );
    } else {
      return NotFound(path: state.uri.path);
    }
  }
}

class SimpleBeamLocation extends BeamLocation {
  SimpleBeamLocation(BeamState state, this.routes) : super(state);

  /// Map of all routes this location handles.
  Map<String, WidgetBuilder> routes;

  List<String> get sortedRoutes =>
      routes.keys.toList()..sort((a, b) => a.length - b.length);

  @override
  List<String> get pathBlueprints => [sortedRoutes.last];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) {
    var filteredRoutes = chooseRoutes(state, routes.keys);
    routes.removeWhere((key, value) => !filteredRoutes.contains(key));
    return sortedRoutes.map((route) {
      return BeamPage(
        // TODO this does not update when using path parameters or *
        key: ValueKey(route),
        child: routes[route](context),
      );
    }).toList();
  }
}

List<String> chooseRoutes(BeamState state, Iterable<String> routes) {
  var matched = <String>[];
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

    for (int i = 0; i < routePathSegments.length; i++) {
      if (routePathSegments[i] == '*' || routePathSegments[i].startsWith(':')) {
        continue;
      }
      if (routePathSegments[i] != uriPathSegments[i]) {
        checksPassed = false;
        break;
      }
    }

    if (checksPassed) {
      matched.add(route);
    }
  }
  return matched;
}
