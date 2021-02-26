import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'beam_location.dart';
import 'beamer_router_delegate.dart';
import 'beamer_route_information_parser.dart';

/// Central place for creating, accessing and modifying a Router subtree.
class Beamer extends StatefulWidget {
  Beamer({
    Key key,
    this.beamLocations,
    this.routerDelegate,
    this.app,
  })  : assert(routerDelegate != null && app != null ||
            app == null && routerDelegate == null),
        assert(beamLocations != null && app == null ||
            beamLocations == null && app != null),
        super(key: key);

  // TODO give this to delegate also, to enable beamToNamed later on
  /// [BeamLocation]s that this Beamer handles.
  final List<BeamLocation> beamLocations;

  /// Responsible for beaming, updating and rebuilding the page stack.
  final BeamerRouterDelegate routerDelegate;

  /// `*App` widget, e.g. [MaterialApp].
  ///
  /// This is useful when using `builder` in the `*App` widget. Then, if using
  /// Beamer the regular way, `Beamer.of(context)` will not find anything.
  /// The way to solve it is by using Beamer above `*App` like this:
  ///
  /// ```dart
  /// final _routerDelegate = BeamerRouterDelegate(...);
  ///
  /// @override
  /// Widget build(BuildContext context) {
  ///   return Beamer(
  ///     routerDelegate: _routerDelegate
  ///     app: MaterialApp.router(
  ///       routerDelegate: _routerDelegate,
  ///       routeInformationParser: BeamerRouteInformationParser(...),
  ///       ...
  ///     )
  ///   );
  /// }
  ///
  /// ```
  final Widget app;

  /// Access Beamer's [routerDelegate].
  static BeamerRouterDelegate of(BuildContext context) {
    try {
      return Router.of(context).routerDelegate;
    } catch (e) {
      return context.findAncestorWidgetOfExactType<Beamer>().routerDelegate;
    }
  }

  @override
  State<StatefulWidget> createState() => BeamerState();
}

class BeamerState extends State<Beamer> {
  BeamerRouterDelegate _routerDelegate;

  BeamerRouterDelegate get routerDelegate => _routerDelegate;
  BeamLocation get currentLocation => _routerDelegate.currentLocation;

  @override
  void initState() {
    super.initState();
    _routerDelegate ??= BeamerRouterDelegate(
      initialLocation: widget.beamLocations[0],
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.app ??
        Router(
          routerDelegate: _routerDelegate,
          routeInformationParser: BeamerRouteInformationParser(
            beamLocations: widget.beamLocations,
          ),
          routeInformationProvider: PlatformRouteInformationProvider(
            initialRouteInformation: RouteInformation(
              location: currentLocation.uri,
            ),
          ),
          backButtonDispatcher: RootBackButtonDispatcher(),
        );
  }
}

extension BeamTo on BuildContext {
  void beamTo(BeamLocation location, {bool beamBackOnPop = false}) {
    Beamer.of(this).beamTo(location, beamBackOnPop: beamBackOnPop);
  }
}

extension BeamBack on BuildContext {
  void beamBack() {
    Beamer.of(this).beamBack();
  }
}
