import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'beam_location.dart';
import 'beamer_router_delegate.dart';
import 'beamer_route_information_parser.dart';

class Beamer extends StatelessWidget {
  Beamer({
    this.initialLocation,
    this.beamLocations,
    this.notFoundPage,
    this.app,
    this.routerDelegate,
  }) : assert(app != null || initialLocation != null && beamLocations != null);

  final BeamLocation initialLocation;
  final List<BeamLocation> beamLocations;
  final Widget notFoundPage;
  final Widget app;
  final BeamerRouterDelegate routerDelegate;

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
                beamLocations: beamLocations,
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
