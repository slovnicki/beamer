import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import 'beam_page.dart';
import 'beam_location.dart';
import 'beamer_back_button_dispatcher.dart';
import 'beamer_delegate.dart';
import 'beamer_provider.dart';
import 'path_url_strategy_nonweb.dart'
    if (dart.library.html) 'path_url_strategy_web.dart' as url_strategy;

/// A wrapper for [Router].
class Beamer extends StatefulWidget {
  const Beamer({
    Key? key,
    required this.routerDelegate,
    this.createBackButtonDispatcher = true,
    this.backButtonDispatcher,
  }) : super(key: key);

  /// Responsible for beaming, updating and rebuilding the page stack.
  final BeamerDelegate routerDelegate;

  /// Whether to create a [BeamerChildBackButtonDispatcher] automatically
  /// if the [backButtonDispatcher] is not set but parent has it.
  final bool createBackButtonDispatcher;

  /// Define how Android's back button should behave.
  ///
  /// Use [BeamerChildBackButtonDispatcher]
  /// instead of [BeamerBackButtonDispatcher].
  final BackButtonDispatcher? backButtonDispatcher;

  /// Access Beamer's [routerDelegate].
  static BeamerDelegate of(BuildContext context, {bool root = false}) {
    BeamerDelegate _delegate;
    try {
      _delegate = Router.of(context).routerDelegate as BeamerDelegate;
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
  BeamerDelegate get routerDelegate => widget.routerDelegate;
  BeamLocation get currentBeamLocation =>
      widget.routerDelegate.currentBeamLocation;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routerDelegate.parent ??=
        Router.of(context).routerDelegate as BeamerDelegate;
  }

  @override
  Widget build(BuildContext context) {
    final parent = Router.of(context);
    routerDelegate.parent ??= parent.routerDelegate as BeamerDelegate;
    final backButtonDispatcher = widget.backButtonDispatcher ??
        ((parent.backButtonDispatcher is BeamerBackButtonDispatcher &&
                widget.createBackButtonDispatcher)
            ? BeamerChildBackButtonDispatcher(
                parent: parent.backButtonDispatcher!,
                delegate: routerDelegate,
              )
            : null);
    return Router(
      routerDelegate: routerDelegate,
      backButtonDispatcher: backButtonDispatcher?..takePriority(),
    );
  }
}

extension BeamerExtensions on BuildContext {
  /// {@macro beamTo}
  void beamTo(
    BeamLocation location, {
    BeamLocation? popTo,
    TransitionDelegate? transitionDelegate,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
    bool replaceCurrent = false,
  }) {
    Beamer.of(this).beamTo(
      location,
      popTo: popTo,
      transitionDelegate: transitionDelegate,
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
      replaceCurrent: replaceCurrent,
    );
  }

  /// {@macro beamToNamed}
  void beamToNamed(
    String uri, {
    Map<String, dynamic>? data,
    String? popToNamed,
    TransitionDelegate? transitionDelegate,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
    bool replaceCurrent = false,
  }) {
    Beamer.of(this).beamToNamed(
      uri,
      data: data,
      popToNamed: popToNamed,
      transitionDelegate: transitionDelegate,
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
      replaceCurrent: replaceCurrent,
    );
  }

  /// {@macro popToNamed}
  void popToNamed(
    String uri, {
    Map<String, dynamic>? data,
    String? popToNamed,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
    bool replaceCurrent = false,
  }) {
    Beamer.of(this).popToNamed(
      uri,
      data: data,
      popToNamed: popToNamed,
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
      replaceCurrent: replaceCurrent,
    );
  }

  /// {@macro beamBack}
  void beamBack({Map<String, dynamic>? data}) =>
      Beamer.of(this).beamBack(data: data);

  /// {@macro popBeamLocation}
  void popBeamLocation() => Beamer.of(this).popBeamLocation();

  /// {@macro currentBeamLocation}
  BeamLocation get currentBeamLocation => Beamer.of(this).currentBeamLocation;

  /// {@macro currentPages}
  List<BeamPage> get currentBeamPages => Beamer.of(this).currentPages;

  /// {@macro routeHistory}
  List<RouteInformation> get routeHistory => Beamer.of(this).routeHistory;

  /// {@macro canBeamBack}
  bool get canBeamBack => Beamer.of(this).canBeamBack;

  /// {@macro beamLocationHistory}
  List<BeamLocation> get beamLocationHistory =>
      Beamer.of(this).beamLocationHistory;

  /// {@macro canPopBeamLocation}
  bool get canPopBeamLocation => Beamer.of(this).canPopBeamLocation;
}

extension BeamerRouteInformationExtension on RouteInformation {
  RouteInformation copyWith({
    String? location,
    Object? state,
  }) {
    return RouteInformation(
      location: location ?? this.location,
      state: state ?? this.state,
    );
  }
}
