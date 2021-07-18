import 'package:beamer/beamer.dart';
import 'package:beamer/src/beam_state.dart';
import 'package:beamer/src/utils.dart';
import 'package:flutter/widgets.dart';

/// Configuration for a navigatable application region.
///
/// Responsible for
///   * knowing which URIs it can handle: [pathBlueprints]
///   * knowing how to build a stack of pages: [buildPages]
///   * keeping a [state] that provides the link between the first 2
///
/// Extend this class to define your locations to which you can then beam to.
abstract class BeamLocation<T extends RouteInformationSerializable>
    extends ChangeNotifier {
  BeamLocation([RouteInformation? routeInformation]) {
    state = createState(
      routeInformation ?? const RouteInformation(location: '/'),
    );
  }

  /// A state of this location.
  ///
  /// Upon beaming, it will be populated by all necessary attributes.
  /// See [BeamState].
  late T state;

  /// How to create state from generic [BeamState], that is produced
  /// by [BeamerDelegate] and passed via [BeamerDelegate.locationBuilder].
  ///
  /// Override this if you have your custom state class extending [BeamState].
  T createState(RouteInformation routeInformation) =>
      BeamState.fromRouteInformation(routeInformation, beamLocation: this) as T;

  /// Update a state via callback receiving the current state.
  /// If no callback is given, just notifies [BeamerDelegate] to rebuild.
  ///
  /// Useful with [BeamState.copyWith].
  void update([T Function(T)? copy, bool rebuild = true]) {
    if (copy != null) {
      state = copy(state);
    }
    if (rebuild) {
      notifyListeners();
    }
  }

  /// Can this handle the [uri] based on its [pathBlueprints].
  ///
  /// Can be useful in a custom [BeamerDelegate.locationBuilder].
  bool canHandle(Uri uri) => Utils.canBeamLocationHandleUri(this, uri);

  /// Gives the ability to wrap the [navigator].
  ///
  /// Mostly useful for providing something to the entire location,
  /// i.e. to all of the pages.
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
  /// You can pass in either a String or a RegExp. Beware of using greedy regular
  /// expressions as this might lead to unexpected behaviour.
  ///
  /// For strings, optional path segments are denoted with ':xxx' and consequently
  /// `{'xxx': <real>}` will be put to [pathParameters].
  /// For regular expressions we use named groups as optional path segments, following
  /// regex is tested to be effective in most cases `RegExp('/test/(?<test>[a-z]+){0,1}')`
  /// This will put `{'test': <real>}` to [pathParameters]. Note that we use the name from the regex group.
  ///
  /// Optional path segments can be used as a mean to pass data regardless of
  /// whether there is a browser.
  ///
  /// For example: '/books/:id' or using regex `RegExp('/test/(?<test>[a-z]+){0,1}')`
  List<Pattern> get pathBlueprints;

  /// Creates and returns the list of pages to be built by the [Navigator]
  /// when this [BeamLocation] is beamed to or internally inferred.
  ///
  /// [context] can be useful while building the pages.
  /// It will also contain anything injected via [builder].
  List<BeamPage> buildPages(BuildContext context, T state);

  /// Guards that will be executing [check] when this gets beamed to.
  ///
  /// Checks will be executed in order; chain of responsibility pattern.
  /// When some guard returns `false`, a candidate will not be accepted
  /// and stack of pages will be updated as is configured in [BeamGuard].
  ///
  /// Override this in your subclasses, if needed.
  /// See [BeamGuard].
  List<BeamGuard> get guards => const <BeamGuard>[];

  /// A transition delegate to be used by [Navigator].
  ///
  /// This will be used only by this location, unlike
  /// [BeamerDelegate.transitionDelegate] that will be used for all locations.
  ///
  /// This transition delegate will override the one in [BeamerDelegate].
  ///
  /// See [Navigator.transitionDelegate].
  TransitionDelegate? get transitionDelegate => null;
}

/// Default location to choose if requested URI doesn't parse to any location.
class NotFound extends BeamLocation<BeamState> {
  NotFound({String path = '/'}) : super(RouteInformation(location: path));

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [];

  @override
  List<String> get pathBlueprints => [];
}

/// Empty location used to intialize a non-nullable BeamLocation variable.
///
/// See [BeamerDelegate.currentBeamLocation].
class EmptyBeamLocation extends BeamLocation<BeamState> {
  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [];

  @override
  List<String> get pathBlueprints => [];
}

/// A beam location for [SimpleLocationBuilder], but can be used freely.
///
/// Useful when needing a simple beam location with a single or few pages.
class SimpleBeamLocation extends BeamLocation<BeamState> {
  SimpleBeamLocation({
    required RouteInformation routeInformation,
    required this.routes,
    this.navBuilder,
  }) : super(routeInformation);

  /// Map of all routes this location handles.
  Map<Pattern, dynamic Function(BuildContext, BeamState)> routes;

  /// A wrapper used as [BeamLocation.builder].
  Widget Function(BuildContext context, Widget navigator)? navBuilder;

  @override
  Widget builder(BuildContext context, Widget navigator) {
    return navBuilder?.call(context, navigator) ?? navigator;
  }

  int _compareKeys(dynamic a, dynamic b) {
    // try-catch a CastError
    try {
      return (a as String).length - (b as String).length;
    } on TypeError {
      return 1;
    }
  }

  @override
  List<Pattern> get pathBlueprints => routes.keys.toList();

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final filteredRoutes = chooseRoutes(state.routeInformation, routes.keys);
    final activeRoutes = Map.of(routes)
      ..removeWhere((key, value) => !filteredRoutes.containsKey(key));
    final sortedRoutes = activeRoutes.keys.toList()
      ..sort((a, b) => _compareKeys(a, b));
    return sortedRoutes.map<BeamPage>((route) {
      final routeElement = routes[route]!(context, state);
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

  /// Chooses all the routes that "sub-match" [state.uri] to stack their pages.
  ///
  /// If none of the routes _matches_ [state.uri], nothing will be selected
  /// and [BeamerDelegate] will declare that the location is [NotFound].
  static Map<Pattern, String> chooseRoutes(
      RouteInformation routeInformation, Iterable<Pattern> routes) {
    final matched = <Pattern, String>{};
    bool overrideNotFound = false;
    final uri = Uri.parse(routeInformation.location ?? '/');
    for (final route in routes) {
      if (route is String) {
        final uriPathSegments = uri.pathSegments.toList();
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
                uri.queryParameters.isEmpty ? null : uri.queryParameters,
          ).toString();
        }
      } else {
        final regexp = Utils.tryCastToRegExp(route);
        if (regexp.hasMatch(uri.toString())) {
          final path = uri.toString();
          matched[regexp] = Uri(
            path: path == '' ? '/' : path,
            queryParameters:
                uri.queryParameters.isEmpty ? null : uri.queryParameters,
          ).toString();
        }
      }
    }

    bool isNotFound = true;
    matched.forEach((key, value) {
      if (Utils.urisMatch(key, uri)) {
        isNotFound = false;
      }
    });

    if (overrideNotFound) {
      return matched;
    }

    return isNotFound ? {} : matched;
  }
}
