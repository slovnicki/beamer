import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import 'beam_page.dart';
import 'beam_location.dart';
import 'beamer_back_button_dispatcher.dart';
import 'beamer_router_delegate.dart';
import 'beamer_provider.dart';
import 'path_url_strategy_nonweb.dart'
    if (dart.library.html) 'path_url_strategy_web.dart' as url_strategy;

/// A wrapper for [Router].
class Beamer extends StatefulWidget {
  Beamer({
    Key? key,
    required this.routerDelegate,
  }) : super(key: key);

  /// Responsible for beaming, updating and rebuilding the page stack.
  final BeamerRouterDelegate routerDelegate;

  /// Access Beamer's [routerDelegate].
  static BeamerRouterDelegate of(BuildContext context, {bool root = false}) {
    BeamerRouterDelegate _delegate;
    try {
      _delegate = Router.of(context).routerDelegate as BeamerRouterDelegate;
    } catch (e) {
      assert(BeamerProvider.of(context) != null,
          'There was no Router nor BeamerProvider in current context. If using MaterialApp.builder, wrap the MaterialApp.router in BeamerProvider to which you pass the same routerDelegate as to MaterialApp.router.');
      return BeamerProvider.of(context)!.routerDelegate;
    }
    if (root) {
      return _delegate.root;
    }
    return _delegate;
  }

  /// Change the strategy to use for handling browser URL to [PathUrlStrategy].
  ///
  /// [PathUrlStrategy] uses the browser URL's pathname to represent Beamer's route name.
  static void setPathUrlStrategy() => url_strategy.setPathUrlStrategy();

  @override
  State<StatefulWidget> createState() => BeamerState();
}

class BeamerState extends State<Beamer> {
  BeamerRouterDelegate get routerDelegate => widget.routerDelegate;
  BeamLocation get currentLocation => widget.routerDelegate.currentLocation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routerDelegate.parent ??=
        Router.of(context).routerDelegate as BeamerRouterDelegate;
  }

  @override
  Widget build(BuildContext context) {
    routerDelegate.parent ??=
        Router.of(context).routerDelegate as BeamerRouterDelegate;
    return Router(
      routerDelegate: widget.routerDelegate,
      backButtonDispatcher:
          BeamerBackButtonDispatcher(delegate: widget.routerDelegate),
    );
  }
}

extension BeamerExtensions on BuildContext {
  /// See [BeamerRouterDelegate.beamTo]
  void beamTo(
    BeamLocation location, {
    BeamLocation? popTo,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
    bool replaceCurrent = false,
  }) {
    Beamer.of(this).beamTo(
      location,
      popTo: popTo,
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
      replaceCurrent: replaceCurrent,
    );
  }

  /// See [BeamerRouterDelegate.beamToNamed]
  void beamToNamed(
    String uri, {
    Map<String, dynamic> data = const <String, dynamic>{},
    String? popToNamed,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
    bool replaceCurrent = false,
  }) {
    Beamer.of(this).beamToNamed(
      uri,
      data: data,
      popToNamed: popToNamed,
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
      replaceCurrent: replaceCurrent,
    );
  }

  /// See [BeamerRouterDelegate.beamBack]
  void beamBack() => Beamer.of(this).beamBack();

  /// See [BeamerRouterDelegate.popBeamLocation]
  void popBeamLocation() => Beamer.of(this).popBeamLocation();

  /// See [BeamerRouterDelegate.currentLocation]
  BeamLocation get currentBeamLocation => Beamer.of(this).currentLocation;

  /// See [BeamerRouterDelegate.currentPages]
  List<BeamPage> get currentBeamPages => Beamer.of(this).currentPages;

  /// See [BeamerRouterDelegate.canBeamBack]
  bool get canBeamBack => Beamer.of(this).canBeamBack;

  /// See [BeamerRouterDelegate.canPopBeamLocation]
  bool get canPopBeamLocation => Beamer.of(this).canPopBeamLocation;
}
