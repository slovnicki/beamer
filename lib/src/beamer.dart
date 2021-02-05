import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'beam_location.dart';
import 'beamer_router_delegate.dart';
import 'beamer_route_information_parser.dart';

/// Central place for creating, accessing and modifying a Router subtree.
class Beamer extends StatelessWidget {
  Beamer({
    this.initialLocation,
    this.beamLocations,
    this.notFoundPage,
    this.app,
    this.routerDelegate,
  }) : assert(app != null || initialLocation != null && beamLocations != null);

  /// Location to be built if nothing else is signaled.
  final BeamLocation initialLocation;

  /// All the location that this application supports.
  final List<BeamLocation> beamLocations;

  /// Screen to be drawn when no location can handle the URI.
  final Widget notFoundPage;

  /// `*App` widget, e.g. [MaterialApp].
  ///
  /// This is useful when using `builder` in the `*App` widget. Then, if using
  /// Beamer the regular way, `Beamer.of(context)` will not find anything.
  /// The way to solve it is by using Beamer above `*App` like this:
  ///
  /// ```dart
  /// final BeamerRouterDelegate _beamerRouterDelegate = ...;
  /// final List<BeamLocation> _beamLocations = ...;
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Beamer(
  ///     routerDelegate: _beamerRouterDelegate,
  ///     app: MaterialApp.router(
  ///       routerDelegate: _beamerRouterDelegate,
  ///       routeInformationParser: BeamerRouteInformationParser(
  ///         beamLocations: _beamLocations,
  ///       ),
  ///       ...
  ///     )
  ///   );
  /// }
  ///
  /// ```
  final Widget app;

  /// Responsible for beaming, updating and rebuilding the page stack.
  final BeamerRouterDelegate routerDelegate;

  /// Access Beamer's [routerDelegate].
  static BeamerRouterDelegate of(BuildContext context) {
    return Router.maybeOf(context)?.routerDelegate ??
        context.findAncestorWidgetOfExactType<Beamer>().routerDelegate;
  }

  @override
  Widget build(BuildContext context) {
    return app ??
        Router(
          routerDelegate: routerDelegate ??
              BeamerRouterDelegate(
                initialLocation: initialLocation,
                notFoundPage: notFoundPage,
              ),
          routeInformationParser: BeamerRouteInformationParser(
            beamLocations: beamLocations,
          ),
        );
  }
}

extension BeamTo on BuildContext {
  void beamTo(BeamLocation location) {
    Beamer.of(this).beamTo(location);
  }
}

extension BeamBack on BuildContext {
  void beamBack() {
    Beamer.of(this).beamBack();
  }
}
