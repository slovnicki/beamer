import 'package:beamer/beamer.dart';
import 'package:beamer/src/transition_delegates.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'utils.dart';

/// A delegate that is used by the [Router] to build the [Navigator].
///
/// This is "the beamer", the one that does the actual beaming.
class BeamerDelegate extends RouterDelegate<RouteInformation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<RouteInformation> {
  /// Creates a [BeamerDelegate] with specified properties.
  ///
  /// [locationBuilder] is required to process the incoming navigation request.
  BeamerDelegate({
    required this.locationBuilder,
    this.initialPath = '/',
    this.routeListener,
    this.buildListener,
    this.preferUpdate = true,
    this.removeDuplicateHistory = true,
    this.notFoundPage = const BeamPage(
      key: ValueKey('not-found'),
      title: 'Not found',
      child: Scaffold(body: Center(child: Text('Not found'))),
    ),
    this.notFoundRedirect,
    this.notFoundRedirectNamed,
    this.guards = const <BeamGuard>[],
    this.navigatorObservers = const <NavigatorObserver>[],
    this.transitionDelegate = const DefaultTransitionDelegate(),
    this.beamBackTransitionDelegate = const ReverseTransitionDelegate(),
    this.onPopPage,
    this.setBrowserTabTitle = true,
    this.updateFromParent = true,
    this.updateParent = true,
    this.clearBeamingHistoryOn = const <String>{},
  }) {
    _currentBeamParameters = BeamParameters(
      transitionDelegate: transitionDelegate,
    );

    configuration = RouteInformation(location: initialPath);
  }

  /// A state of this delegate. This is the `routeInformation` that goes into
  /// [locationBuilder] to build an appropriate [BeamLocation].
  ///
  /// A way to modify this state is via [update].
  late RouteInformation configuration;

  BeamerDelegate? _parent;

  /// A delegate of a parent of the [Beamer] that has this delegate.
  ///
  /// This is not null only if multiple [Beamer]s are used;
  /// `*App.router` and at least one more [Beamer] in the Widget tree.
  BeamerDelegate? get parent => _parent;
  set parent(BeamerDelegate? parent) {
    _parent = parent!;
    _initializeFromParent();
    if (updateFromParent) {
      _parent!.addListener(_updateFromParent);
    }
  }

  /// The top-most [BeamerDelegate], a parent of all.
  ///
  /// It will return root even when called on root.
  BeamerDelegate get root {
    if (_parent == null) {
      return this;
    }
    var root = _parent!;
    while (root._parent != null) {
      root = root._parent!;
    }
    return root;
  }

  /// A builder for [BeamLocation]s.
  ///
  /// There are 3 ways of building an appropriate [BeamLocation] which will in
  /// turn build a stack of pages that should go into [Navigator.pages].
  ///
  ///   1. Custom closure
  /// ```dart
  /// locationBuilder: (state) {
  ///   if (state.uri.pathSegments.contains('l1')) {
  ///     return Location1(state);
  ///   }
  ///   if (state.uri.pathSegments.contains('l2')) {
  ///     return Location2(state);
  ///   }
  ///   return NotFound(path: state.uri.toString());
  /// },
  /// ```
  ///
  ///   2. [BeamerLocationBuilder]; chooses appropriate [BeamLocation] itself
  /// ```dart
  /// locationBuilder: BeamerLocationBuilder(
  ///   beamLocations: [
  ///     Location1(),
  ///     Location2(),
  ///   ],
  /// ),
  /// ```
  ///
  ///   3. [RoutesLocationBuilder]; a Map of routes
  /// ```dart
  /// locationBuilder: RoutesLocationBuilder(
  ///   routes: {
  ///     '/': (context, state) => HomeScreen(),
  ///     '/another': (context, state) => AnotherScreen(),
  ///   },
  /// ),
  /// ```
  final LocationBuilder locationBuilder;

  /// The path to replace `/` as default initial route path upon load.
  ///
  /// Note that (if set to anything other than `/` (default)),
  /// you will not be able to navigate to `/` by manually typing
  /// it in the URL bar, because it will always be transformed to `initialPath`,
  /// but you will be able to get to `/` by popping pages with back button,
  /// if there are pages in [BeamLocation.buildPages] that will build
  /// when there are no path segments.
  final String initialPath;

  /// The routeListener will be called on every navigation event
  /// and will recieve the [configuration] and a reference to this delegate.
  final void Function(RouteInformation, BeamerDelegate)? routeListener;

  /// The buildListener will be called every time after the [currentPages]
  /// are updated. it receives a reference to this delegate.
  final void Function(BuildContext, BeamerDelegate)? buildListener;

  /// Whether to prefer updating [currentBeamLocation] if it's of the same type
  /// as the [BeamLocation] being beamed to,
  /// instead of adding it to [beamLocationHistory].
  ///
  /// See how this is used at [_pushHistory] implementation.
  final bool preferUpdate;

  /// Whether to remove [BeamLocation]s from [beamLocationHistory]
  /// if they are the same type as the location being beamed to.
  ///
  /// See how this is used at [_pushHistory] implementation.
  final bool removeDuplicateHistory;

  /// Page to show when no [BeamLocation] supports the incoming URI.
  late BeamPage notFoundPage;

  /// [BeamLocation] to redirect to when no [BeamLocation] supports the incoming URI.
  final BeamLocation? notFoundRedirect;

  /// URI string to redirect to when no [BeamLocation] supports the incoming URI.
  final String? notFoundRedirectNamed;

  /// Guards that will be executing [check] on [currentBeamLocation] candidate.
  ///
  /// Checks will be executed in order; chain of responsibility pattern.
  /// When some guard returns `false`, location candidate will not be accepted
  /// and stack of pages will be updated as is configured in [BeamGuard].
  final List<BeamGuard> guards;

  /// The list of observers for the [Navigator].
  final List<NavigatorObserver> navigatorObservers;

  /// A transition delegate to be used by [Navigator].
  ///
  /// This transition delegate will be overridden by the one in [BeamLocation],
  /// if any is set.
  ///
  /// See [Navigator.transitionDelegate].
  final TransitionDelegate transitionDelegate;

  /// A transition delegate to be used by [Navigator] when beaming back.
  ///
  /// When calling [beamBack], it's useful to animate routes in reverse order;
  /// adding the new ones behind and then popping the current ones,
  /// therefore, the default is [ReverseTransitionDelegate].
  final TransitionDelegate beamBackTransitionDelegate;

  /// Callback when `pop` is requested.
  ///
  /// Return `true` if pop will be handled entirely by this function.
  /// Return `false` if beamer should finish handling the pop.
  ///
  /// See [build] for details on how beamer handles [Navigator.onPopPage].
  bool Function(BuildContext context, Route<dynamic> route, dynamic result)?
      onPopPage;

  /// Whether the title attribute of [BeamPage] should
  /// be used to set and update the browser tab title.
  final bool setBrowserTabTitle;

  /// Whether to call [update] when parent notifies listeners.
  ///
  /// This means that navigation can be done either on parent or on this
  final bool updateFromParent;

  /// Whether to call [update] on [parent] when [state] is updated.
  ///
  /// This means that parent's [beamStateHistory] will be in sync.
  final bool updateParent;

  /// Whether to remove all entries from [routeHistory] when a route
  /// belonging to this set is reached, regardless of how it was reached.
  ///
  /// Note that [popToNamed] will also try to clear as much [routeHistory]
  /// as possible, even when this is empty.
  final Set<String> clearBeamingHistoryOn;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// {@template beamingHistory}
  /// The history of [BeamLocation]s, each holding its [BeamLocation.history].
  ///
  /// See [_pushHistory].
  /// {@endtemplate}
  final List<BeamLocation> beamingHistory = [];

  /// Returns the complete length of beaming history, that is the sum of all
  /// history lengths for each [BeamLocation] in [beamingHistory].
  int get beamingHistoryCompleteLength {
    int length = 0;
    for (BeamLocation location in beamingHistory) {
      length += location.history.length;
    }
    return length;
  }

  /// {@template currentBeamLocation}
  /// A [BeamLocation] that is currently responsible for providing a page stack
  /// via [BeamLocation.buildPages] and holds the current [BeamState].
  ///
  /// Usually obtained via
  /// ```dart
  /// Beamer.of(context).currentBeamLocation
  /// ```
  /// {@endtemplate}
  BeamLocation get currentBeamLocation =>
      beamingHistory.isEmpty ? EmptyBeamLocation() : beamingHistory.last;

  List<BeamPage> _currentPages = [];

  /// {@template currentPages}
  /// [currentBeamLocation]'s "effective" pages, the ones that were built.
  /// {@endtemplate}
  List<BeamPage> get currentPages => _currentPages;

  /// Describes the current parameters for beaming, such as
  /// pop configuration, beam back on pop, etc.
  late BeamParameters _currentBeamParameters;

  /// If `false`, does not report the route until next [update].
  ///
  /// Useful when having sibling beamers that are both build at the same time.
  /// Becomes active on next [update].
  bool active = true;

  /// The [Navigator] that belongs to this [BeamerDelegate].
  ///
  /// Useful for popping dialogs without accessing [BuildContext]:
  ///
  /// ```dart
  /// beamerDelegate.navigator.pop();
  /// ```
  NavigatorState get navigator => _navigatorKey.currentState!;

  /// Main method to update the [state] of this; `Beamer.of(context)`,
  ///
  /// This "top-level" [update] is generally used for navigation
  /// _between_ [BeamLocation]s and not _within_ a specific [BeamLocation].
  /// For latter purpose, see [BeamLocation.update].
  /// Nevertheless, [update] **will** work for navigation within [BeamLocation].
  /// Calling [update] will run the [locationBuilder].
  ///
  /// ```dart
  /// Beamer.of(context).update(
  ///   state: BeamState.fromUriString('/xx'),
  /// );
  /// ```
  ///
  /// **[beamTo] and [beamToNamed] call [update] to really do the update.**
  ///
  /// [transitionDelegate] determines how a new stack of pages replaces current.
  /// See [Navigator.transitionDelegate].
  ///
  /// If [beamBackOnPop] is set to `true`,
  /// default pop action will triger [beamBack] instead.
  ///
  /// [popState] is more general than [beamBackOnPop],
  /// and can beam you anywhere; whatever it resolves to during build.
  ///
  /// If [stacked] is set to `false`,
  /// only the location's last page will be shown.
  ///
  /// If [replaceCurrent] is set to `true`,
  /// new location will replace the last one in the stack.
  ///
  /// If [rebuild] is set to `false`,
  /// [build] will not occur, but [state] and browser URL will be updated.
  void update({
    RouteInformation? configuration,
    BeamParameters? beamParameters,
    Object? data,
    bool buildBeamLocation = true,
    bool rebuild = true,
    bool updateParent = true,
    bool updateRouteInformation = true,
  }) {
    configuration = configuration?.copyWith(
      location: Utils.trimmed(configuration.location),
    );
    _currentBeamParameters = beamParameters ?? _currentBeamParameters;

    if (clearBeamingHistoryOn.contains(configuration?.location)) {
      for (var beamLocation in beamingHistory) {
        beamLocation.history.clear();
      }
      beamingHistory.clear();
    }

    this.configuration = configuration ??
        currentBeamLocation.history.last.routeInformation.copyWith();
    if (buildBeamLocation) {
      final location =
          locationBuilder(this.configuration, _currentBeamParameters);
      if (beamingHistory.isEmpty ||
          location.runtimeType != beamingHistory.last.runtimeType) {
        _addToBeamingHistory(location);
      } else {
        beamingHistory.last.update(
          null,
          this.configuration,
          _currentBeamParameters,
          false,
        );
      }
    }
    if (data != null) {
      currentBeamLocation.data = data;
    }
    routeListener?.call(this.configuration, this);

    if (this.updateParent && updateParent) {
      _parent?.update(
        configuration: this.configuration.copyWith(),
        rebuild: false,
        updateRouteInformation: false,
      );
    }

    // We should call [updateRouteInformation] manually only if
    // notifyListeners() is not going to be called.
    // This is when !rebuild or
    // when this will notifyListeners (when rebuild), but is not a top-most
    // router in which case it cannot report the route implicitly.
    if (updateRouteInformation && active && (!rebuild || parent != null)) {
      this.updateRouteInformation(this.configuration);
    }

    if (rebuild) {
      // This will implicitly update the route information,
      // but only if this is the top-most router
      // See [currentConfiguration].
      notifyListeners();
    }
  }

  /// {@template beamTo}
  /// Beams to a specific, manually configured [BeamLocation].
  ///
  /// For example
  /// ```dart
  /// Beamer.of(context).beamTo(
  ///   Location2(
  ///     BeamState(
  ///       pathBlueprintSegments = ['user',':userId','transactions'],
  ///       pathParameters = {'userId': '1'},
  ///       queryParameters = {'perPage': '10'},
  ///       data = {'favoriteUser': true},
  ///     ),
  ///   ),
  /// );
  /// ```
  ///
  /// See [update] for more details.
  /// {@endtemplate}
  void beamTo(
    BeamLocation location, {
    Object? data,
    BeamLocation? popTo,
    TransitionDelegate? transitionDelegate,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
  }) {
    _addToBeamingHistory(location);
    update(
      configuration: location.state.routeInformation,
      beamParameters: _currentBeamParameters.copyWith(
        popConfiguration: popTo?.state.routeInformation,
        transitionDelegate: transitionDelegate ?? this.transitionDelegate,
        beamBackOnPop: beamBackOnPop,
        popBeamLocationOnPop: popBeamLocationOnPop,
        stacked: stacked,
      ),
      data: data,
      buildBeamLocation: false,
    );
  }

  /// The same as [beamTo], but replaces the [currentBeamLocation],
  /// i.e. removes it from the [beamingHistory] and then does [beamTo].
  void beamToReplacement(
    BeamLocation location, {
    Object? data,
    BeamLocation? popTo,
    TransitionDelegate? transitionDelegate,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
  }) {
    currentBeamLocation.removeListener(_updateFromLocation);
    beamingHistory.removeLast();
    beamTo(
      location,
      data: data,
      popTo: popTo,
      transitionDelegate: transitionDelegate,
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
    );
  }

  /// {@template beamToNamed}
  /// Beams to [BeamLocation] that has [uri] contained within its
  /// [BeamLocation.pathBlueprintSegments].
  ///
  /// For example
  /// ```dart
  /// Beamer.of(context).beamToNamed(
  ///   '/user/1/transactions?perPage=10',
  ///   data: {'favoriteUser': true},,
  /// );
  /// ```
  ///
  /// See [update] for more details.
  /// {@endtemplate}
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
    update(
      configuration: RouteInformation(location: uri, state: routeState),
      beamParameters: _currentBeamParameters.copyWith(
        popConfiguration:
            popToNamed != null ? RouteInformation(location: popToNamed) : null,
        transitionDelegate: transitionDelegate ?? this.transitionDelegate,
        beamBackOnPop: beamBackOnPop,
        popBeamLocationOnPop: popBeamLocationOnPop,
        stacked: stacked,
      ),
      data: data,
    );
  }

  /// The same as [beamToNamed], but replaces the last state in history,
  /// i.e. removes it from the `beamingHistory.last.history` and then does [beamToNamed].
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
    removeLastHistoryElement();
    beamToNamed(
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

  /// {@template popToNamed}
  /// Calls [beamToNamed] with a [ReverseTransitionDelegate] and tries to
  /// remove everything from history after entry corresponding to `uri`, as
  /// if doing a pop way back to that state, if it exists in history.
  ///
  /// See [beamToNamed] for more details.
  /// {@endtemplate}
  void popToNamed(
    String uri, {
    Object? routeState,
    Object? data,
    String? popToNamed,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
  }) {
    while (beamingHistory.isNotEmpty) {
      final index = beamingHistory.last.history.lastIndexWhere(
        (element) => element.routeInformation.location == uri,
      );
      if (index == -1) {
        beamingHistory.last.removeListener(_updateFromLocation);
        beamingHistory.removeLast();
        continue;
      } else {
        beamingHistory.last.history
            .removeRange(index, beamingHistory.last.history.length);
      }
    }
    beamToNamed(
      uri,
      routeState: routeState,
      data: data,
      popToNamed: popToNamed,
      transitionDelegate: const ReverseTransitionDelegate(),
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
    );
  }

  /// {@template canBeamBack}
  /// Whether it is possible to [beamBack],
  /// i.e. there is more than 1 state in [beamingHistory].
  /// {@endtemplate}
  bool get canBeamBack =>
      beamingHistory.last.history.length > 1 || beamingHistory.length > 1;

  /// {@template beamBack}
  /// Beams to previous entry in [beamingHistory].
  /// and **removes** the last entry from history.
  ///
  /// If there is no previous entry, does nothing.
  ///
  /// Returns the success, whether [update] was executed.
  /// {@endtemplate}
  bool beamBack({Object? data}) {
    if (!canBeamBack) {
      return false;
    }
    late final HistoryElement targetHistoryElement;
    final lastHistorylength = beamingHistory.last.history.length;
    // first we try to beam back within last BeamLocation
    if (lastHistorylength > 1) {
      targetHistoryElement = beamingHistory.last.history[lastHistorylength - 2];
      beamingHistory.last.history
          .removeRange(lastHistorylength - 2, lastHistorylength);
    } else {
      // here we know that beamingHistory.length > 1 (because of canBeamBack)
      // and that beamingHistory.last.history.length == 1
      // so this last (only) entry is removed along with BeamLocation
      beamingHistory.removeLast();
      targetHistoryElement = beamingHistory.last.history.last;
      beamingHistory.last.history.removeLast();
    }

    update(
      configuration: targetHistoryElement.routeInformation.copyWith(),
      beamParameters: targetHistoryElement.parameters.copyWith(
        transitionDelegate: beamBackTransitionDelegate,
      ),
      data: data,
    );
    return true;
  }

  /// {@template canPopBeamLocation}
  /// Whether it is possible to [popBeamLocation],
  /// i.e. there is more than 1 location in [beamingHistory].
  /// {@endtemplate}
  bool get canPopBeamLocation => beamingHistory.length > 1;

  /// {@template popBeamLocation}
  /// Beams to previous location in [beamingHistory]
  /// and **removes** the last location from history.
  ///
  /// If there is no previous location, does nothing.
  ///
  /// Returns the success, whether the [currentBeamLocation] was changed.
  /// {@endtemplate}
  bool popBeamLocation({Object? data}) {
    if (!canPopBeamLocation) {
      return false;
    }
    currentBeamLocation.removeListener(_updateFromLocation);
    beamingHistory.removeLast();
    update(
      beamParameters: currentBeamLocation.history.last.parameters.copyWith(
        transitionDelegate: beamBackTransitionDelegate,
      ),
      data: data,
      buildBeamLocation: false,
    );
    return true;
  }

  @override
  RouteInformation? get currentConfiguration =>
      _parent == null ? configuration.copyWith() : null;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  Widget build(BuildContext context) {
    final guard = _checkGuards(context, currentBeamLocation);
    if (guard != null) {
      final origin = beamingHistory.length > 1
          ? beamingHistory[beamingHistory.length - 2]
          : null;
      _applyGuard(guard, context, origin, currentBeamLocation);
    }

    if (currentBeamLocation is NotFound) {
      _handleNotFoundRedirect();
    }

    if (!currentBeamLocation.mounted) {
      currentBeamLocation.buildInit(context);
    }

    _setCurrentPages(context, guard);

    _setBrowserTitle(context);

    buildListener?.call(context, this);

    final navigator = Navigator(
      key: navigatorKey,
      observers: navigatorObservers,
      transitionDelegate: currentBeamLocation.transitionDelegate ??
          _currentBeamParameters.transitionDelegate,
      pages: _currentPages,
      onPopPage: (route, result) => _onPopPage(context, route, result),
    );

    return currentBeamLocation.builder(context, navigator);
  }

  @override
  SynchronousFuture<void> setInitialRoutePath(RouteInformation configuration) {
    final uri = Uri.parse(configuration.location ?? '/');
    if (currentBeamLocation is! EmptyBeamLocation) {
      configuration = currentBeamLocation.state.routeInformation;
    } else if (uri.path == '/') {
      configuration = RouteInformation(
        location: initialPath + (uri.query.isNotEmpty ? '?${uri.query}' : ''),
      );
    }
    return setNewRoutePath(configuration);
  }

  @override
  SynchronousFuture<void> setNewRoutePath(RouteInformation configuration) {
    update(configuration: configuration);
    return SynchronousFuture(null);
  }

  /// Pass this call to [root] which notifies the platform for a [state] change.
  ///
  /// On Web, creates a new browser history entry and update URL
  ///
  /// See [SystemNavigator.routeInformationUpdated].
  void updateRouteInformation(RouteInformation routeInformation) {
    if (_parent == null) {
      SystemNavigator.routeInformationUpdated(
        location: configuration.location ?? '/',
        state: configuration.state,
      );
    } else {
      _parent!.updateRouteInformation(routeInformation);
    }
  }

  BeamGuard? _checkGuards(
    BuildContext context,
    BeamLocation location,
  ) {
    for (final guard in (parent?.guards ?? []) + guards + location.guards) {
      if (guard.shouldGuard(location) && !guard.check(context, location)) {
        guard.onCheckFailed?.call(context, location);
        return guard;
      }
    }
    return null;
  }

  void _applyGuard(
    BeamGuard guard,
    BuildContext context,
    BeamLocation? origin,
    BeamLocation target,
  ) {
    if (guard.showPage != null) {
      return;
    }

    late BeamLocation redirectLocation;

    if (guard.beamTo == null && guard.beamToNamed == null) {
      removeLastHistoryElement();
      return update(
        buildBeamLocation: false,
        rebuild: false,
      );
    } else if (guard.beamTo != null) {
      redirectLocation = guard.beamTo!(context, origin, target);
    } else if (guard.beamToNamed != null) {
      redirectLocation = locationBuilder(
        RouteInformation(location: guard.beamToNamed!(origin, target)),
        _currentBeamParameters.copyWith(),
      );
    }

    final anotherGuard = _checkGuards(context, redirectLocation);
    if (anotherGuard != null) {
      return _applyGuard(anotherGuard, context, origin, redirectLocation);
    }

    currentBeamLocation.removeListener(_updateFromLocation);
    if (guard.replaceCurrentStack) {
      beamingHistory.removeLast();
    }
    _addToBeamingHistory(redirectLocation);
    _updateFromLocation(rebuild: false);
  }

  void _addToBeamingHistory(BeamLocation location) {
    currentBeamLocation.removeListener(_updateFromLocation);
    currentBeamLocation.isCurrent = false;
    currentBeamLocation.disposeState();
    if (removeDuplicateHistory) {
      final index = beamingHistory.indexWhere((historyLocation) =>
          historyLocation.runtimeType == location.runtimeType);
      if (index != -1) {
        beamingHistory[index].removeListener(_updateFromLocation);
        beamingHistory.removeAt(index);
      }
    }
    beamingHistory.add(location);
    currentBeamLocation.initState();
    currentBeamLocation.isCurrent = true;
    currentBeamLocation.addListener(_updateFromLocation);
  }

  /// Removes the last element from [beamingHistory] and returns it.
  ///
  /// If there is none, returns `null`.
  HistoryElement? removeLastHistoryElement() {
    if (beamingHistoryCompleteLength == 0) {
      return null;
    }
    if (updateParent) {
      _parent?.removeLastHistoryElement();
    }
    final lastHistoryElement = beamingHistory.last.removeLastFromHistory();
    if (beamingHistory.last.history.isEmpty) {
      beamingHistory.removeLast();
    } else {
      beamingHistory.last.update(null, null, null, false);
    }

    return lastHistoryElement;
  }

  void _handleNotFoundRedirect() {
    if (notFoundRedirect == null && notFoundRedirectNamed == null) {
      // do nothing, pass on NotFound
    } else {
      late BeamLocation redirectBeamLocation;
      if (notFoundRedirect != null) {
        redirectBeamLocation = notFoundRedirect!;
      } else if (notFoundRedirectNamed != null) {
        redirectBeamLocation = locationBuilder(
          RouteInformation(location: notFoundRedirectNamed),
          _currentBeamParameters.copyWith(),
        );
      }
      _addToBeamingHistory(redirectBeamLocation);
      _updateFromLocation(rebuild: false);
    }
  }

  void _setCurrentPages(BuildContext context, BeamGuard? guard) {
    if (currentBeamLocation is NotFound) {
      _currentPages = [notFoundPage];
    } else {
      _currentPages = _currentBeamParameters.stacked
          ? currentBeamLocation.buildPages(context, currentBeamLocation.state)
          : [
              currentBeamLocation
                  .buildPages(context, currentBeamLocation.state)
                  .last
            ];
    }
    if (guard != null && guard.showPage != null) {
      if (guard.replaceCurrentStack) {
        _currentPages = [guard.showPage!];
      } else {
        _currentPages += [guard.showPage!];
      }
    }
  }

  void _setBrowserTitle(BuildContext context) {
    if (active && kIsWeb && setBrowserTabTitle) {
      SystemChrome.setApplicationSwitcherDescription(
          ApplicationSwitcherDescription(
        label: _currentPages.last.title ??
            currentBeamLocation.state.routeInformation.location,
        primaryColor: Theme.of(context).primaryColor.value,
      ));
    }
  }

  bool _onPopPage(BuildContext context, Route<dynamic> route, dynamic result) {
    if (route.willHandlePopInternally) {
      if (!route.didPop(result)) {
        return false;
      }
    }

    if (_currentBeamParameters.popConfiguration != null) {
      update(
        configuration: _currentBeamParameters.popConfiguration,
        beamParameters: _currentBeamParameters.copyWith(
          transitionDelegate: beamBackTransitionDelegate,
        ),
        // replaceCurrent: true,
      );
    } else if (_currentBeamParameters.popBeamLocationOnPop) {
      final didPopBeamLocation = popBeamLocation();
      if (!didPopBeamLocation) {
        return false;
      }
    } else if (_currentBeamParameters.beamBackOnPop) {
      final didBeamBack = beamBack();
      if (!didBeamBack) {
        return false;
      }
    } else {
      final lastPage = _currentPages.last;
      if (lastPage is BeamPage) {
        if (lastPage.popToNamed != null) {
          popToNamed(lastPage.popToNamed!);
        } else {
          final shouldPop = lastPage.onPopPage(
            context,
            this,
            currentBeamLocation.state,
            lastPage,
          );
          if (!shouldPop) {
            return false;
          }
        }
      }
    }

    return route.didPop(result);
  }

  void _initializeFromParent() {
    final parent = _parent;
    if (parent == null) {
      return;
    }
    configuration = parent.configuration.copyWith();
    var location = locationBuilder(
      configuration,
      _currentBeamParameters.copyWith(),
    );
    if (location is NotFound) {
      configuration = RouteInformation(location: initialPath);
      location = locationBuilder(
        configuration,
        _currentBeamParameters.copyWith(),
      );
    }
    _addToBeamingHistory(location);
  }

  void _updateFromParent({bool rebuild = true}) {
    update(
      configuration: _parent!.configuration.copyWith(),
      rebuild: rebuild,
      updateParent: false,
      updateRouteInformation: false,
    );
  }

  void _updateFromLocation({bool rebuild = true}) {
    update(
      configuration: currentBeamLocation.state.routeInformation,
      buildBeamLocation: false,
      rebuild: rebuild,
    );
  }

  @override
  void dispose() {
    _parent?.removeListener(_updateFromParent);
    currentBeamLocation.removeListener(_updateFromLocation);
    currentBeamLocation.dispose();
    super.dispose();
  }
}
