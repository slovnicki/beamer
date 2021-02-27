import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'beam_location.dart';
import 'beamer_router_delegate.dart';
import 'beamer_route_information_parser.dart';

/// Central place for creating, accessing and modifying a Router subtree.
class Beamer extends StatefulWidget {
  Beamer({
    Key? key,
    required this.routerDelegate,
    this.routeInformationParser,
    this.app,
  }) : super(key: key);

  /// Responsible for beaming, updating and rebuilding the page stack.
  final BeamerRouterDelegate routerDelegate;

  /// Parses the URI from browser into [BeamLocation] and vice versa.
  final BeamerRouteInformationParser? routeInformationParser;

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
  final Widget? app;

  /// Access Beamer's [routerDelegate].
  static BeamerRouterDelegate of(BuildContext context) {
    try {
      return Router.of(context).routerDelegate as BeamerRouterDelegate;
    } catch (e) {
      return context.findAncestorWidgetOfExactType<Beamer>()!.routerDelegate;
    }
  }

  @override
  State<StatefulWidget> createState() => BeamerState();
}

class BeamerState extends State<Beamer> {
  BeamerRouterDelegate get routerDelegate => widget.routerDelegate;
  BeamLocation get currentLocation => widget.routerDelegate.currentLocation;

  @override
  Widget build(BuildContext context) {
    return widget.app ??
        Router(
          routerDelegate: routerDelegate,
          routeInformationParser: widget.routeInformationParser,
          routeInformationProvider: widget.routeInformationParser != null
              ? PlatformRouteInformationProvider(
                  initialRouteInformation: RouteInformation(
                    location: currentLocation.uri,
                  ),
                )
              : null,
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
