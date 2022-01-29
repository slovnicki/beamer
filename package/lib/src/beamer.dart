import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import 'package:beamer/src/path_url_strategy_nonweb.dart'
    if (dart.library.html) 'path_url_strategy_web.dart' as url_strategy;

/// Represents a navigation area and is a wrapper for [Router].
///
/// This is most commonly used for "nested navigation", e.g. in a tabbed view.
/// Each [Beamer] has its own navigation rules, but can communicate with its parent [Router].
class Beamer extends StatefulWidget {
  /// Creates a [Beamer] with specified properties.
  ///
  /// [routerDelegate] is required because it handles the navigation within the
  /// "sub-navigation module" represented by this.
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

  /// Change the strategy to use for handling browser URL to `PathUrlStrategy`.
  ///
  /// `PathUrlStrategy` uses the browser URL's pathname to represent Beamer's route name.
  static void setPathUrlStrategy() => url_strategy.setPathUrlStrategy();

  @override
  State<StatefulWidget> createState() => BeamerState();
}

/// A [State] for [Beamer].
class BeamerState extends State<Beamer> {
  /// A getter for [BeamerDelegate] of the [Beamer] whose state is this.
  BeamerDelegate get routerDelegate => widget.routerDelegate;

  /// A convenience getter for current [BeamLocation] of [routerDelegate].
  BeamLocation get currentBeamLocation => routerDelegate.currentBeamLocation;

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
                parent:
                    parent.backButtonDispatcher! as BeamerBackButtonDispatcher,
                delegate: routerDelegate,
              )
            : null);
    return Router(
      routerDelegate: routerDelegate,
      backButtonDispatcher: backButtonDispatcher?..takePriority(),
    );
  }
}

/// Some beamer-specific extension methods on [BuildContext].
extension BeamerExtensions on BuildContext {
  /// {@macro beamTo}
  void beamTo(
    BeamLocation location, {
    Object? data,
    BeamLocation? popTo,
    TransitionDelegate? transitionDelegate,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
  }) {
    Beamer.of(this).beamTo(
      location,
      data: data,
      popTo: popTo,
      transitionDelegate: transitionDelegate,
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
    );
  }

  /// {@macro beamToReplacement}
  void beamToReplacement(
    BeamLocation location, {
    Object? data,
    BeamLocation? popTo,
    TransitionDelegate? transitionDelegate,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
  }) {
    Beamer.of(this).beamToReplacement(
      location,
      data: data,
      popTo: popTo,
      transitionDelegate: transitionDelegate,
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
    );
  }

  /// {@macro beamToNamed}
  void beamToNamed(
    String uri, {
    Object? routeState,
    Object? data,
    String? popToNamed,
    TransitionDelegate? transitionDelegate,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
  }) {
    Beamer.of(this).beamToNamed(
      uri,
      routeState: routeState,
      data: data,
      popToNamed: popToNamed,
      transitionDelegate: transitionDelegate,
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
    );
  }

  /// {@macro beamToReplacementNamed}
  void beamToReplacementNamed(
    String uri, {
    Object? routeState,
    Object? data,
    String? popToNamed,
    TransitionDelegate? transitionDelegate,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
  }) {
    Beamer.of(this).beamToReplacementNamed(
      uri,
      routeState: routeState,
      data: data,
      popToNamed: popToNamed,
      transitionDelegate: transitionDelegate,
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
    );
  }

  /// {@macro popToNamed}
  void popToNamed(
    String uri, {
    Object? routeState,
    Object? data,
    String? popToNamed,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
  }) {
    Beamer.of(this).popToNamed(
      uri,
      routeState: routeState,
      data: data,
      popToNamed: popToNamed,
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
    );
  }

  /// {@macro beamBack}
  bool beamBack({Object? data}) => Beamer.of(this).beamBack(data: data);

  /// {@macro popBeamLocation}
  bool popBeamLocation() => Beamer.of(this).popBeamLocation();

  /// {@macro currentBeamLocation}
  BeamLocation get currentBeamLocation => Beamer.of(this).currentBeamLocation;

  /// {@macro currentPages}
  List<BeamPage> get currentBeamPages => Beamer.of(this).currentPages;

  /// {@macro beamingHistory}
  List<BeamLocation> get beamingHistory => Beamer.of(this).beamingHistory;

  /// {@macro canBeamBack}
  bool get canBeamBack => Beamer.of(this).canBeamBack;

  /// {@macro canPopBeamLocation}
  bool get canPopBeamLocation => Beamer.of(this).canPopBeamLocation;
}

/// Some convenient extension methods on [RouteInformation].
extension BeamerRouteInformationExtension on RouteInformation {
  /// Returns a new [RouteInformation] created from this.
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
