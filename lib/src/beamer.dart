import 'package:flutter/widgets.dart';

import 'beam_page.dart';
import 'beam_location.dart';
import 'beamer_back_button_dispatcher.dart';
import 'beamer_router_delegate.dart';
import 'beamer_route_information_parser.dart';
import 'beamer_provider.dart';

/// Central place for creating, accessing and modifying a Router subtree.
class Beamer extends StatefulWidget {
  Beamer({
    Key key,
    @required this.beamLocations,
    this.routerDelegate,
  })  : assert(beamLocations != null),
        super(key: key);

  // TODO give this to delegate also, to enable beamToNamed later on
  /// [BeamLocation]s that this Beamer handles.
  final List<BeamLocation> beamLocations;

  /// Responsible for beaming, updating and rebuilding the page stack.
  ///
  /// Normally, this never needs to be set
  /// unless extending [BeamerRouterDelegate] with custom implementation.
  final BeamerRouterDelegate routerDelegate;

  /// Access Beamer's [routerDelegate].
  static BeamerRouterDelegate of(BuildContext context) {
    try {
      return Router.of(context).routerDelegate;
    } catch (e) {
      assert(BeamerProvider.of(context) != null,
          'There was no Router nor BeamerProvider in current context. If using MaterialApp.builder, wrap the MaterialApp.router in BeamerProvider to which you pass the same routerDelegate as to MaterialApp.router.');
      return BeamerProvider.of(context).routerDelegate;
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
    _routerDelegate ??= widget.routerDelegate ??
        BeamerRouterDelegate(beamLocations: widget.beamLocations);
  }

  @override
  Widget build(BuildContext context) {
    return Router(
      routerDelegate: _routerDelegate,
      routeInformationParser: BeamerRouteInformationParser(),
      routeInformationProvider: PlatformRouteInformationProvider(
        initialRouteInformation: RouteInformation(
          location: currentLocation.uri.toString(),
        ),
      ),
      backButtonDispatcher:
          BeamerBackButtonDispatcher(delegate: _routerDelegate),
    );
  }
}

extension BeamerExtensions on BuildContext {
  /// See [BeamerRouterDelegate.beamTo]
  void beamTo(
    BeamLocation location, {
    bool beamBackOnPop = false,
    bool stacked = true,
    bool replaceCurrent = false,
  }) {
    Beamer.of(this).beamTo(
      location,
      beamBackOnPop: beamBackOnPop,
      stacked: stacked,
      replaceCurrent: replaceCurrent,
    );
  }

  /// See [BeamerRouterDelegate.beamToNamed]
  void beamToNamed(
    String uri, {
    Map<String, dynamic> data = const <String, dynamic>{},
    bool beamBackOnPop = false,
    bool stacked = true,
    bool replaceCurrent = false,
  }) {
    Beamer.of(this).beamToNamed(
      uri,
      data: data,
      beamBackOnPop: beamBackOnPop,
      stacked: stacked,
      replaceCurrent: replaceCurrent,
    );
  }

  /// See [BeamerRouterDelegate.beamBack]
  void beamBack() => Beamer.of(this).beamBack();

  /// See [BeamerRouterDelegate.updateCurrentLocation]
  void updateCurrentLocation({
    String pathBlueprint,
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Map<String, dynamic> data = const <String, dynamic>{},
    bool rewriteParameters = false,
    bool beamBackOnPop,
    bool stacked,
  }) {
    Beamer.of(this).updateCurrentLocation(
      pathBlueprint: pathBlueprint,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      data: data,
      rewriteParameters: rewriteParameters,
      beamBackOnPop: beamBackOnPop,
      stacked: stacked,
    );
  }

  /// See [BeamerRouterDelegate.currentLocation]
  BeamLocation get currentBeamLocation => Beamer.of(this).currentLocation;

  /// See [BeamerRouterDelegate.currentPages]
  List<BeamPage> get currentBeamPages => Beamer.of(this).currentPages;

  /// See [BeamerRouterDelegate.canBeamBack]
  bool get canBeamBack => Beamer.of(this).canBeamBack;

  /// See [BeamerRouterDelegate.beamBackLocation]
  BeamLocation get beamBackLocation => Beamer.of(this).beamBackLocation;
}
