import 'dart:convert';

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
  BeamerDelegate({
    required this.locationBuilder,
    this.initialPath = '/',
    this.routeListener,
    this.buildListener,
    this.preferUpdate = true,
    this.removeDuplicateHistory = true,
    this.notFoundPage,
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
    this.clearBeamingHistoryOnSlashReached = false,
  }) {
    notFoundPage ??= const BeamPage(
      title: 'Not found',
      child: Scaffold(body: Center(child: Text('Not found'))),
    );

    _currentTransitionDelegate = transitionDelegate;

    configuration = RouteInformation(location: initialPath);
    _currentBeamLocation = EmptyBeamLocation();
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
  ///   3. [SimpleLocationBuilder]; a Map of routes
  /// ```dart
  /// locationBuilder: SimpleLocationBuilder(
  ///   routes: {
  ///     '/': (context) => HomeScreen(),
  ///     '/another': (context) => AnotherScreen(),
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
  /// and will recieve the [configuration] and [currentBeamLocation].
  final void Function(RouteInformation, BeamLocation)? routeListener;

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
  BeamPage? notFoundPage;

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

  /// Whether to remove all entries from [routeHistory] when `/` route is reached,
  /// regardless of how it was reached.
  ///
  /// Note that [popToNamed] will also try to clear as much [routeHistory]
  /// as possible, even when this is set to `false`.
  final bool clearBeamingHistoryOnSlashReached;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// {@template routeHistory}
  /// The history of beaming states.
  ///
  /// [BeamState] is inserted on every beaming event, if it differs from last.
  ///
  /// See [_pushHistory].
  /// {@endtemplate}
  final List<RouteInformation> routeHistory = [];

  /// {@template beamLocationHistory}
  /// The history of [BeamLocation]s.
  ///
  /// [BeamLocation] is inserted differently depending on configuration of
  /// [preferUpdate], [replaceCurrent], [removeDuplicateHistory].
  ///
  /// See [_pushHistory].
  /// {@endtemplate}
  final List<BeamLocation> beamLocationHistory = [];

  late BeamLocation _currentBeamLocation;

  /// {@template currentBeamLocation}
  /// A [BeamLocation] that is currently responsible for providing a page stack
  /// via [BeamLocation.buildPages] and holds the current [BeamState].
  ///
  /// Usually obtained via
  /// ```dart
  /// Beamer.of(context).currentBeamLocation
  /// ```
  /// {@endtemplate}
  BeamLocation get currentBeamLocation => _currentBeamLocation;

  List<BeamPage> _currentPages = [];

  /// {@template currentPages}
  /// [currentBeamLocation]'s "effective" pages, the ones that were built.
  /// {@endtemplate}
  List<BeamPage> get currentPages => _currentPages;

  /// Whether to implicitly [beamBack] instead of default pop.
  bool _beamBackOnPop = false;

  /// Whether to implicitly [popBeamLocation] instead of default pop.
  bool _popBeamLocationOnPop = false;

  /// Which transition delegate to use in the next build.
  late TransitionDelegate _currentTransitionDelegate;

  /// Which location to pop to, instead of default pop.
  ///
  /// This is more general than [_beamBackOnPop].
  RouteInformation? _popConfiguration;

  /// Whether all the pages from [currentBeamLocation] are stacked.
  /// If not (`false`), just the last page is taken.
  bool _stacked = true;

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
    RouteInformation? popConfiguration,
    TransitionDelegate? transitionDelegate,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
    bool replaceCurrent = false,
    bool buildBeamLocation = true,
    bool rebuild = true,
    bool updateParent = true,
  }) {
    configuration = configuration?.copyWith(
      location: Utils.trimmed(configuration.location),
    );
    popConfiguration = popConfiguration?.copyWith(
      location: Utils.trimmed(popConfiguration.location),
    );

    if (configuration?.location == '/' && clearBeamingHistoryOnSlashReached) {
      beamLocationHistory.clear();
      routeHistory.clear();
    }

    active = true;
    _popConfiguration = popConfiguration ?? _popConfiguration;
    _currentTransitionDelegate = transitionDelegate ?? this.transitionDelegate;
    _beamBackOnPop = beamBackOnPop;
    _popBeamLocationOnPop = popBeamLocationOnPop;
    _stacked = stacked;

    if (configuration != null) {
      this.configuration = configuration;
      if (buildBeamLocation) {
        final location = locationBuilder(this.configuration);
        _pushHistory(location, replaceCurrent: replaceCurrent);
      }
      routeListener?.call(this.configuration, _currentBeamLocation);
    }

    bool parentDidUpdate = false;
    if (parent != null &&
        this.updateParent &&
        updateParent &&
        (configuration?.location != _parent?.configuration.location ||
            configuration?.state != _parent?.configuration.state)) {
      _parent!.update(
        configuration: this.configuration.copyWith(),
        rebuild: false,
      );
      parentDidUpdate = true;
    }

    if (!rebuild && !parentDidUpdate) {
      updateRouteInformation(this.configuration);
    }

    if (rebuild) {
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
    BeamLocation? popTo,
    TransitionDelegate? transitionDelegate,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
    bool replaceCurrent = false,
  }) {
    _pushHistory(location, replaceCurrent: replaceCurrent);
    update(
      configuration: location.state.routeInformation,
      popConfiguration: popTo?.state.routeInformation,
      transitionDelegate: transitionDelegate,
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
      buildBeamLocation: false,
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
    Map<String, dynamic>? data,
    String? popToNamed,
    TransitionDelegate? transitionDelegate,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
    bool replaceCurrent = false,
  }) {
    final beamData = data ?? _currentBeamLocation.state.routeInformation.state;
    update(
      configuration: RouteInformation(location: uri, state: beamData),
      popConfiguration: popToNamed != null
          ? RouteInformation(location: popToNamed, state: beamData)
          : null,
      transitionDelegate: transitionDelegate,
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
      replaceCurrent: replaceCurrent,
    );
  }

  /// {@template popToNamed}
  /// Calls [beamToNamed] with a [ReverseTransitionDelegate].
  ///
  /// See [beamToNamed] for more details.
  /// {@endtemplate}
  void popToNamed(
    String uri, {
    Map<String, dynamic>? data,
    String? popToNamed,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
    bool replaceCurrent = false,
  }) {
    final index = routeHistory.lastIndexWhere(
      (element) => element.location == uri,
    );
    if (index != -1) {
      routeHistory.removeRange(index, routeHistory.length);
    }
    beamToNamed(
      uri,
      data: data,
      popToNamed: popToNamed,
      transitionDelegate: const ReverseTransitionDelegate(),
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
      replaceCurrent: replaceCurrent,
    );
  }

  /// {@template canBeamBack}
  /// Whether it is possible to [beamBack],
  /// i.e. there is more than 1 state in [routeHistory].
  /// {@endtemplate}
  bool get canBeamBack => routeHistory.length > 1;

  /// {@template beamBack}
  /// Beams to previous state in [routeHistory].
  /// and **removes** the last state from history.
  ///
  /// If there is no previous state, does nothing.
  ///
  /// Returns the success, whether the [state] updated.
  /// {@endtemplate}
  bool beamBack({Map<String, dynamic>? data}) {
    if (!canBeamBack) {
      return false;
    }
    removeLastRouteInformation();
    // has to exist because canbeamBack
    final lastConfiguration = removeLastRouteInformation()!;
    update(
      configuration: lastConfiguration.copyWith(state: data),
      transitionDelegate: beamBackTransitionDelegate,
    );
    return true;
  }

  /// Remove everything except last from [routeHistory].
  void clearRouteHistory() =>
      routeHistory.removeRange(0, routeHistory.length - 1);

  /// {@template canPopBeamLocation}
  /// Whether it is possible to [popBeamLocation],
  /// i.e. there is more than 1 location in [beamLocationHistory].
  /// {@endtemplate}
  bool get canPopBeamLocation => beamLocationHistory.length > 1;

  /// {@template popBeamLocation}
  /// Beams to previous location in [beamLocationHistory]
  /// and **removes** the last location from history.
  ///
  /// If there is no previous location, does nothing.
  ///
  /// Returns the success, whether the [currentBeamLocation] was changed.
  /// {@endtemplate}
  bool popBeamLocation() {
    if (!canPopBeamLocation) {
      return false;
    }
    _currentBeamLocation.removeListener(_updateFromLocation);
    beamLocationHistory.removeLast();
    _currentBeamLocation = beamLocationHistory.last;
    routeHistory.add(_currentBeamLocation.state.routeInformation.copyWith());
    _currentBeamLocation.addListener(_updateFromLocation);
    update(
      transitionDelegate: beamBackTransitionDelegate,
    );
    return true;
  }

  /// Remove everything except last from [beamLocationHistory].
  void clearBeamLocationHistory() =>
      beamLocationHistory.removeRange(0, beamLocationHistory.length - 1);

  @override
  RouteInformation? get currentConfiguration =>
      _parent == null ? configuration.copyWith() : null;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  Widget build(BuildContext context) {
    BeamGuard? guard = _checkGuards(guards, context, _currentBeamLocation);
    if (guard != null) {
      _applyGuard(guard, context);
    }
    if (_currentBeamLocation is NotFound) {
      if (notFoundRedirect == null && notFoundRedirectNamed == null) {
        // do nothing, pass on NotFound
      } else {
        late BeamLocation redirectBeamLocation;
        if (notFoundRedirect != null) {
          redirectBeamLocation = notFoundRedirect!;
        } else if (notFoundRedirectNamed != null) {
          redirectBeamLocation = locationBuilder(
            RouteInformation(location: notFoundRedirectNamed),
          );
        }
        _currentBeamLocation.removeListener(_updateFromLocation);
        _pushHistory(redirectBeamLocation);
        _updateFromLocation(rebuild: false);
      }
    }

    final navigator = Builder(
      builder: (context) {
        if (_currentBeamLocation is NotFound ||
            _currentBeamLocation is EmptyBeamLocation) {
          _currentPages = [notFoundPage!];
        } else {
          _currentPages = _stacked
              ? _currentBeamLocation.buildPages(
                  context, _currentBeamLocation.state)
              : [
                  _currentBeamLocation
                      .buildPages(context, _currentBeamLocation.state)
                      .last
                ];
        }
        if (active && kIsWeb && setBrowserTabTitle) {
          SystemChrome.setApplicationSwitcherDescription(
              ApplicationSwitcherDescription(
            label: _currentPages.last.title ??
                _currentBeamLocation.state.routeInformation.location,
            primaryColor: Theme.of(context).primaryColor.value,
          ));
        }
        buildListener?.call(context, this);
        return Navigator(
          key: navigatorKey,
          observers: navigatorObservers,
          transitionDelegate: _currentBeamLocation.transitionDelegate ??
              _currentTransitionDelegate,
          pages: guard != null && guard.showPage != null
              ? guard.replaceCurrentStack
                  ? [guard.showPage!]
                  : _currentPages + [guard.showPage!]
              : _currentPages,
          onPopPage: (route, result) {
            if (route.willHandlePopInternally) {
              if (!route.didPop(result)) {
                return false;
              }
            }

            if (_popConfiguration != null) {
              update(
                configuration: _popConfiguration,
                transitionDelegate: beamBackTransitionDelegate,
                replaceCurrent: true,
              );
            } else if (_popBeamLocationOnPop) {
              final didPopBeamLocation = popBeamLocation();
              if (!didPopBeamLocation) {
                return false;
              }
            } else if (_beamBackOnPop) {
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
                  final shouldPop = lastPage.onPopPage(context, this, lastPage);
                  if (!shouldPop) {
                    return false;
                  }
                }
              }
            }

            return route.didPop(result);
          },
        );
      },
    );
    return _currentBeamLocation.builder(context, navigator);
  }

  @override
  SynchronousFuture<void> setInitialRoutePath(RouteInformation configuration) {
    final uri = Uri.parse(configuration.location ?? '/');
    if (_currentBeamLocation is! EmptyBeamLocation) {
      configuration = _currentBeamLocation.state.routeInformation;
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
    List<BeamGuard> guards,
    BuildContext context,
    BeamLocation location,
  ) {
    for (final guard in guards + location.guards) {
      if (guard.shouldGuard(location) && !guard.check(context, location)) {
        guard.onCheckFailed?.call(context, location);
        return guard;
      }
    }
    return null;
  }

  void _applyGuard(BeamGuard guard, BuildContext context) {
    if (guard.showPage != null) {
      return;
    }

    late BeamLocation redirectLocation;

    if (guard.beamTo == null && guard.beamToNamed == null) {
      final lastState = removeLastRouteInformation();
      configuration = lastState!.copyWith();
      redirectLocation = locationBuilder(configuration);
    } else if (guard.beamTo != null) {
      redirectLocation = guard.beamTo!(context);
    } else if (guard.beamToNamed != null) {
      configuration = RouteInformation(location: guard.beamToNamed!);
      redirectLocation = locationBuilder(configuration);
    }

    final anotherGuard = _checkGuards(guards, context, redirectLocation);
    if (anotherGuard != null) {
      return _applyGuard(anotherGuard, context);
    }

    _currentBeamLocation.removeListener(_updateFromLocation);
    if (guard.replaceCurrentStack && beamLocationHistory.isNotEmpty) {
      removeLastRouteInformation();
      beamLocationHistory.removeLast();
    }
    _pushHistory(redirectLocation);
    _updateFromLocation(rebuild: false);
  }

  void _pushHistory(BeamLocation location, {bool replaceCurrent = false}) {
    if (routeHistory.isEmpty ||
        routeHistory.last.location !=
            location.state.routeInformation.location) {
      routeHistory.add(location.state.routeInformation.copyWith());
    }

    _currentBeamLocation.removeListener(_updateFromLocation);
    if ((preferUpdate &&
                location.runtimeType == _currentBeamLocation.runtimeType ||
            replaceCurrent) &&
        beamLocationHistory.isNotEmpty) {
      beamLocationHistory.removeLast();
    }
    if (removeDuplicateHistory) {
      beamLocationHistory
          .removeWhere((l) => l.runtimeType == location.runtimeType);
    }

    beamLocationHistory.add(location);
    _currentBeamLocation = beamLocationHistory.last;
    _currentBeamLocation.addListener(_updateFromLocation);
  }

  RouteInformation? removeLastRouteInformation() {
    if (routeHistory.isEmpty) {
      return null;
    }
    if (updateParent) {
      _parent?.removeLastRouteInformation();
    }
    return routeHistory.removeLast();
  }

  void _initializeFromParent() {
    configuration = _parent!.configuration.copyWith();
    var location = locationBuilder(configuration);
    if (location is NotFound) {
      configuration = RouteInformation(location: initialPath);
      location = locationBuilder(configuration);
    }
    _pushHistory(location);
  }

  void _updateFromParent({bool rebuild = true}) {
    update(
      configuration: _parent!.configuration.copyWith(),
      rebuild: rebuild,
      updateParent: false,
    );
  }

  void _updateFromLocation({bool rebuild = true}) {
    update(
      configuration: _currentBeamLocation.state.routeInformation,
      buildBeamLocation: false,
      rebuild: rebuild,
    );
  }

  @override
  void dispose() {
    _parent?.removeListener(_updateFromParent);
    _currentBeamLocation.removeListener(_updateFromLocation);
    super.dispose();
  }
}
