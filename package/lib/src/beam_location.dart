import 'package:beamer/beamer.dart';
import 'package:beamer/src/beam_state.dart';
import 'package:beamer/src/utils.dart';
import 'package:flutter/widgets.dart';

/// Configuration for a navigatable application region.
///
/// Extend this class to define your locations to which you can then `beamTo`.
abstract class BeamLocation<T extends BeamState> extends ChangeNotifier {
  BeamLocation([T? state]) {
    _state = createState(state ?? BeamState());
  }

  late T _state;

  /// A state of this location.
  ///
  /// Upon beaming, it will be populated by all necessary attributes.
  /// See [BeamState].
  T get state => _state;
  set state(T state) => _state = state..configure();

  /// How to create state from generic [BeamState], often produced by [Beamer]
  /// for the use in [BeamerDelegate.locationBuilder].
  ///
  /// Override this if you have your custom state class extending [BeamState].
  T createState(BeamState state) => state.copyForLocation(this) as T;

  /// Update a state via callback receiving the current state.
  /// If no callback is given, just notifies [BeamerDelegate] to rebuild.
  ///
  /// Useful with [BeamState.copyWith].
  void update([T Function(T)? copy, bool rebuild = true]) {
    if (copy != null) {
      state = copy(_state);
    }
    if (rebuild) {
      notifyListeners();
    }
  }

  /// Can this handle the `uri` based on its [pathBlueprints].
  ///
  /// Can be useful in a custom [BeamerDelegate.locationBuilder].
  ///
  /// Used in [BeamerDelegate._updateFromParent].
  bool canHandle(Uri uri) => Utils.canBeamLocationHandleUri(this, uri);

  /// Gives the ability to wrap the `navigator`.
  ///
  /// Mostly useful for providing something to the entire location,
  /// i.e. to all of the [pages].
  ///
  /// For example:
  ///
  /// ```dart
  /// @override
  /// Widget builder(BuildContext context, Widget navigator) {
  ///   return MyProvider<MyObject>(
  ///     create: (context) => MyObject(),
  ///     child: navigator,
  ///   );
  /// }
  /// ```
  Widget builder(BuildContext context, Widget navigator) => navigator;

  /// Represents the "form" of URI paths supported by this [BeamLocation].
  ///
  /// Optional path segments are denoted with ':xxx' and consequently
  /// `{'xxx': <real>}` will be put to [pathParameters] by
  /// [BeamerParser] upon receiving the real path from browser.
  ///
  /// Optional path segments can be used as a mean to pass data regardless of
  /// whether there is a browser.
  ///
  /// For example: '/books/:id'.
  List<String> get pathBlueprints;

  /// Creates and returns the list of pages to be built by the [Navigator]
  /// when this [BeamLocation] is beamed to or internally inferred.
  ///
  /// `context` can be useful while building the pages.
  /// It will also contain anything injected via [builder].
  List<BeamPage> buildPages(BuildContext context, T state);

  /// Guards that will be executing [check] when this gets beamed to.
  ///
  /// Checks will be executed in order; chain of responsibility pattern.
  /// When some guard returns `false`, location will not be accepted
  /// and stack of pages will be updated as is configured in [BeamGuard].
  ///
  /// Override this in your subclasses, if needed.
  List<BeamGuard> get guards => const <BeamGuard>[];

  /// A transition delegate to be used by [Navigator].
  ///
  /// This will be used only by this location, unlike
  /// [BeamerDelegate.transitionDelegate]
  /// that will be used for all locations.
  ///
  /// This ransition delegate will override the one in [BeamerDelegate].
  TransitionDelegate? get transitionDelegate => null;
}

/// Default location to choose if requested URI doesn't parse to any location.
class NotFound extends BeamLocation {
  NotFound({String path = '/'}) : super(BeamState.fromUri(Uri.parse(path)));

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [];

  @override
  List<String> get pathBlueprints => [''];
}

/// Empty location used to intialize a non-nullable BeamLocation variable.
///
/// See [BeamerDelegate].
class EmptyBeamLocation extends BeamLocation {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [];

  @override
  List<String> get pathBlueprints => [];
}

/// A beam location for [SimpleLocationBuilder], but can be used freely.
///
/// Useful when needing a simple beam location with a single or few pages.
class SimpleBeamLocation extends BeamLocation {
  SimpleBeamLocation({
    required BeamState state,
    required this.routes,
    this.navBuilder,
  }) : super(state);

  /// Map of all routes this location handles.
  Map<String, dynamic Function(BuildContext)> routes;

  /// A wrapper used as [BeamLocation.builder].
  Widget Function(BuildContext context, Widget navigator)? navBuilder;

  @override
  Widget builder(BuildContext context, Widget navigator) {
    return navBuilder?.call(context, navigator) ?? navigator;
  }

  List<String> get sortedRoutes =>
      routes.keys.toList()..sort((a, b) => a.length - b.length);

  @override
  List<String> get pathBlueprints => routes.keys.toList();

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    var filteredRoutes = chooseRoutes(state, routes.keys);
    final activeRoutes = Map.from(routes)
      ..removeWhere((key, value) => !filteredRoutes.containsKey(key));
    final sortedRoutes = activeRoutes.keys.toList()
      ..sort((a, b) => a.length - b.length);
    return sortedRoutes.map<BeamPage>((route) {
      final routeElement = routes[route]!(context);
      if (routeElement is BeamPage) {
        return routeElement;
      } else {
        return BeamPage(
          key: ValueKey(filteredRoutes[route]),
          child: routeElement,
        );
      }
    }).toList();
  }

  /// Will choose all the routes that "sub-match" `state.uri` to stack their pages.
  ///
  /// If none of the selected routes _matches_ `state.uri`, nothing will be selected
  /// and [BeamerDelegate] will declare that the location is [NotFound].
  static Map<String, String> chooseRoutes(
      BeamState state, Iterable<String> routes) {
    var matched = <String, String>{};
    bool overrideNotFound = false;
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

        if (routePathSegments[i] == '*') {
          overrideNotFound = true;
          continue;
        }
        if (routePathSegments[i].startsWith(':')) {
          continue;
        }
        if (routePathSegments[i] != uriPathSegments[i]) {
          checksPassed = false;
          break;
        }
      }

      if (checksPassed) {
        matched[route] = Uri(
          path: path == '' ? '/' : path,
          queryParameters:
              state.queryParameters.isEmpty ? null : state.queryParameters,
        ).toString();
      }
    }

    bool isNotFound = true;
    matched.forEach((key, value) {
      if (Utils.urisMatch(Uri.parse(key), state.uri)) {
        isNotFound = false;
      }
    });

    if (overrideNotFound) {
      return matched;
    }

    return isNotFound ? {} : matched;
  }
}
