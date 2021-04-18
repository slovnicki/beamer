import 'package:beamer/beamer.dart';
import 'package:beamer/src/transition_delegates.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// A delegate that is used by the [Router] to build the [Navigator].
class BeamerRouterDelegate<T extends BeamState> extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  BeamerRouterDelegate({
    required this.locationBuilder,
    this.initialPath = '/',
    this.createState,
    this.preferUpdate = true,
    this.removeDuplicateHistory = true,
    this.notFoundPage,
    this.notFoundRedirect,
    this.guards = const <BeamGuard>[],
    this.navigatorObservers = const <NavigatorObserver>[],
    this.transitionDelegate = const DefaultTransitionDelegate(),
    this.beamBackTransitionDelegate = const ReverseTransitionDelegate(),
    this.onPopPage,
  }) {
    notFoundPage ??= BeamPage(
      child: Container(child: Center(child: Text('Not found'))),
    );

    createState ??= (
      Uri uri, {
      Map<String, dynamic> data = const <String, dynamic>{},
    }) =>
        BeamState.fromUri(uri, data: data) as T;

    state = createState!(Uri.parse(initialPath));
    _currentLocation = locationBuilder(_state);
  }

  late T _state;

  /// A state of this router delegate. This is the `state` that goes into
  /// [locationBuilder] to build an appropriate [BeamLocation].
  ///
  /// Most common way to modify this state is via [update].
  T get state => _state;
  set state(T state) => _state = state..configure();

  BeamerRouterDelegate? _parent;

  /// A router delegate of a parent of the [Beamer] that has this router delegate.
  ///
  /// This is not null only if multiple [Beamer]s are used;
  /// `*App.router` and at least one more [Beamer] in the Widget tree.
  BeamerRouterDelegate? get parent => _parent;
  set parent(BeamerRouterDelegate? parent) {
    _parent = parent;
    state = createState!(_parent!.state.uri);
    final location = locationBuilder(_state);
    _beamHistory.add(location);
    _currentLocation = _beamHistory.last;
    _currentLocation.addListener(_notify);
  }

  /// A builder for [BeamLocation]s.
  final LocationBuilder locationBuilder;

  /// The path to replace `/` as default initial route path upon load.
  ///
  /// Not that (if set to anything other than `/` (default)),
  /// you will not be able to navigate to `/` by manually typing
  /// it in the URL bar, because it will always be transformed to `initialPath`,
  /// but you will be able to get to `/` by popping pages with back button,
  /// if there are pages in [BeamLocation.pagesBuilder] that will build
  /// when there are no path segments.
  final String initialPath;

  /// Whether to prefer updating [currentLocation] if it's of the same type
  /// as the location being beamed to, instead of adding it to [beamHistory].
  ///
  /// See how this is used at [beamTo] implementation.
  final bool preferUpdate;

  /// Whether to remove locations from history if they are the same type
  /// as the location beaing beamed to.
  ///
  /// See how this is used at [beamTo] implementation.
  final bool removeDuplicateHistory;

  /// Page to show when no [BeamLocation] supports the incoming URI.
  BeamPage? notFoundPage;

  /// [BeamLocation] to redirect to when no [BeamLocation] supports the incoming URI.
  final BeamLocation? notFoundRedirect;

  /// Guards that will be executing [check] on [currentLocation] candidate.
  ///
  /// Checks will be executed in order; chain of responsibility pattern.
  /// When some guard returns `false`, location candidate will not be accepted
  /// and stack of pages will be updated as is configured in [BeamGuard].
  final List<BeamGuard> guards;

  /// The list of observers for the [Navigator] created for this app.
  final List<NavigatorObserver> navigatorObservers;

  /// A transition delegate to be used by [Navigator].
  ///
  /// This transition delegate will be overridden by the one in [BeamLocation],
  /// if any is set.
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

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  final List<BeamLocation> _beamHistory = [];

  /// The history of beaming.
  List<BeamLocation> get beamHistory => _beamHistory;

  late BeamLocation _currentLocation;

  /// Access the current [BeamLocation].
  ///
  /// Can be useful in:
  ///
  /// * extracting location properties when building Widgets:
  ///
  /// ```dart
  /// final queryParameters = Beamer.of(context).currentLocation.queryParameters;
  /// ```
  ///
  /// * to check which navigation button should be highlighted:
  ///
  /// ```dart
  /// highlighted: Beamer.of(context).currentLocation is MyLocation,
  /// ```
  ///
  BeamLocation get currentLocation => _currentLocation;

  List<BeamPage> _currentPages = [];

  /// Current location's effective pages.
  List<BeamPage> get currentPages => _currentPages;

  /// Whether to implicitly [beamBack] instead of default pop.
  bool _beamBackOnPop = false;

  /// Needed for deciding the transition delegate.
  bool _isBeamingBack = false;

  /// Which location to pop to, instead of default pop.
  ///
  /// This is more general than `beamBackOnPop`.
  T? _popState;

  /// Whether all the pages from location are stacked.
  /// If not (`false`), just the last page is taken.
  bool _stacked = true;

  /// How to create a [state] for this router delegate.
  ///
  /// If not set, default `BeamState.fromUri(uri, data: data) as T` is used.
  T Function(
    Uri uri, {
    Map<String, dynamic> data,
  })? createState;

  /// Main method to update the state of this; `Beamer.of(context)`,
  ///
  /// This "top-level" [update] is generally used for navigation
  /// _between_ [BeamLocation]s and not _within_ a specific [BeamLocation].
  /// For latter purpose, see [BeamLocation.update].
  /// Nevertheless, [update] **will** work for navigation within [BeamLocation].
  ///
  /// In most cases, _imperative_ [beamTo] or [beamToNamed] will be used,
  /// but they both call [update] to really do the proper updates.
  ///
  /// If `beamBackOnPop` is set to `true`,
  /// default pop action will triger `beamBack` instead.
  ///
  /// `popState` is more general than `beamBackOnPop`,
  /// and can beam you anywhere; whatever it resolves to during build.
  ///
  /// If `stacked` is set to `false`,
  /// only the location's last page will be shown.
  ///
  /// If `replaceCurrent` is set to `true`,
  /// new location will replace the last one in the stack.
  void update({
    T? state,
    T? popState,
    bool beamBackOnPop = false,
    bool stacked = true,
    bool replaceCurrent = false,
    bool rebuild = true,
  }) {
    _isBeamingBack = false;
    _beamBackOnPop = beamBackOnPop;
    _popState = popState;
    _stacked = stacked;
    if (state != null) {
      final location = locationBuilder(state);
      if (location is NotFound && _parent != null) {
        return _parent!.update(
          state: state,
          beamBackOnPop: beamBackOnPop,
          stacked: stacked,
          replaceCurrent: replaceCurrent,
          rebuild: rebuild,
        );
      } else {
        this.state = state;
      }
      _currentLocation.removeListener(_notify);
      if ((preferUpdate &&
                  location.runtimeType == _currentLocation.runtimeType ||
              replaceCurrent) &&
          _beamHistory.isNotEmpty) {
        _beamHistory.removeLast();
      }
      if (removeDuplicateHistory) {
        _beamHistory.removeWhere((l) => l.runtimeType == location.runtimeType);
      }
      _pushBeamLocation(location);
    }
    if (rebuild) {
      _notify();
    }
  }

  /// Beams to a specific, manually configured [BeamLocation].
  ///
  /// For example
  ///
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
  void beamTo(
    BeamLocation location, {
    BeamLocation? popTo,
    bool beamBackOnPop = false,
    bool stacked = true,
    bool replaceCurrent = false,
  }) {
    update(
      state: createState!(location.state.uri, data: location.state.data),
      popState: popTo != null
          ? createState!(popTo.state.uri, data: popTo.state.data)
          : null,
      beamBackOnPop: beamBackOnPop,
      stacked: stacked,
      replaceCurrent: replaceCurrent,
    );
  }

  /// Beams to [BeamLocation] that has `uri` contained within its
  /// [BeamLocation.pathBlueprintSegments].
  ///
  /// For example
  ///
  /// ```dart
  /// Beamer.of(context).beamToNamed(
  ///   '/user/1/transactions?perPage=10',
  ///   data: {'favoriteUser': true},,
  /// );
  /// ```
  ///
  /// See [update] for more details.
  void beamToNamed(
    String uri, {
    Map<String, dynamic> data = const <String, dynamic>{},
    String? popToNamed,
    bool beamBackOnPop = false,
    bool stacked = true,
    bool replaceCurrent = false,
  }) {
    update(
      state: createState!(Uri.parse(uri), data: data),
      popState: popToNamed != null
          ? createState!(Uri.parse(popToNamed), data: data)
          : null,
      beamBackOnPop: beamBackOnPop,
      stacked: stacked,
      replaceCurrent: replaceCurrent,
    );
  }

  /// Whether it is possible to [beamBack],
  /// i.e. there is more than 1 location in [beamHistory].
  bool get canBeamBack => _beamHistory.length > 1;

  /// What is the location to which [beamBack] will lead.
  /// If there is none, returns null.
  BeamLocation? get beamBackLocation =>
      canBeamBack ? _beamHistory[_beamHistory.length - 2] : null;

  /// Beams to previous location in [beamHistory]
  /// and **removes** the last location from history.
  ///
  /// If there is no previous location, does nothing.
  ///
  /// Returns the success, whether the [currentLocation] was changed.
  bool beamBack() {
    _isBeamingBack = true;
    _beamBackOnPop = false;
    _popState = null;
    _stacked = true;
    if (!canBeamBack) {
      return false;
    }
    _currentLocation.removeListener(_notify);
    _beamHistory.removeLast();
    _currentLocation = _beamHistory.last;
    _currentLocation.addListener(_notify);
    _notify();
    return true;
  }

  /// Remove everything except last from [beamHistory].
  void clearHistory() => _beamHistory.removeRange(0, _beamHistory.length - 1);

  @override
  Uri? get currentConfiguration =>
      _parent == null ? _currentLocation.state.uri : null;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  Widget build(BuildContext context) {
    BeamGuard? guard = _checkGuard(guards, context, _currentLocation);
    if (guard != null && guard.showPage == null) {
      _applyGuard(guard, context);
    }
    if (guard == null) {
      guard = _checkGuard(currentLocation.guards, context, _currentLocation);
      if (guard != null && guard.showPage == null) {
        _applyGuard(guard, context);
      }
    }
    if ((_currentLocation is NotFound) && notFoundRedirect != null) {
      _currentLocation.removeListener(_notify);
      _pushBeamLocation(notFoundRedirect!);
    }
    final navigator = Builder(
      builder: (context) {
        _currentPages = _stacked
            ? _currentLocation.pagesBuilder(context, _currentLocation.state)
            : [
                _currentLocation
                    .pagesBuilder(context, _currentLocation.state)
                    .last
              ];
        return Navigator(
          key: navigatorKey,
          observers: navigatorObservers,
          transitionDelegate: _isBeamingBack
              ? beamBackTransitionDelegate
              : (_currentLocation.transitionDelegate ?? transitionDelegate),
          pages: _currentLocation is NotFound
              ? [notFoundPage!]
              : guard == null ||
                      guard.beamTo != null ||
                      guard.beamToNamed != null
                  ? _currentPages
                  : guard.replaceCurrentStack
                      ? [guard.showPage!]
                      : _currentPages + [guard.showPage!],
          onPopPage: (route, result) {
            if (!route.didPop(result)) {
              return false;
            }
            final customPopResult =
                onPopPage?.call(context, route, result) ?? false;
            if (customPopResult) {
              return customPopResult;
            }
            if (_beamBackOnPop) {
              beamBack();
            } else if (_popState != null) {
              update(state: _popState, replaceCurrent: true);
              _beamBackOnPop = false;
              _popState = null;
            } else {
              final lastPage = _currentPages.removeLast();
              if (lastPage is BeamPage) {
                _handlePop(lastPage);
              }
            }
            return true;
          },
        );
      },
    );
    return _currentLocation.builder(context, navigator);
  }

  @override
  SynchronousFuture<void> setInitialRoutePath(Uri configuration) {
    if (configuration.path == '/') {
      configuration = Uri.parse(initialPath);
    }
    return setNewRoutePath(configuration);
  }

  @override
  SynchronousFuture<void> setNewRoutePath(Uri uri) {
    update(state: createState!(uri));
    return SynchronousFuture(null);
  }

  void _notify() {
    updateRouteInformation();
    notifyListeners();
  }

  void _handlePop(BeamPage page) {
    final pathBlueprintSegments =
        List<String>.from(_currentLocation.state.pathBlueprintSegments);
    final pathParameters =
        Map<String, String>.from(_currentLocation.state.pathParameters);
    final pathSegment = pathBlueprintSegments.removeLast();
    if (pathSegment[0] == ':') {
      pathParameters.remove(pathSegment.substring(1));
    }
    _currentLocation.state = _currentLocation.createState(
      BeamState(
        pathBlueprintSegments: pathBlueprintSegments,
        pathParameters: pathParameters,
        queryParameters:
            !page.keepQueryOnPop ? {} : _currentLocation.state.queryParameters,
        data: _currentLocation.state.data,
      ),
    );
    updateRouteInformation();
    _currentLocation.notifyListeners();
  }

  BeamGuard? _checkGuard(
    List<BeamGuard> guards,
    BuildContext context,
    BeamLocation location,
  ) {
    for (var guard in guards) {
      if (guard.shouldGuard(location) && !guard.check(context, location)) {
        guard.onCheckFailed?.call(context, location);
        return guard;
      }
    }
    return null;
  }

  void _applyGuard(BeamGuard guard, BuildContext context) {
    _currentLocation.removeListener(_notify);
    if (guard.replaceCurrentStack) {
      _beamHistory.removeLast();
    }
    if (guard.beamTo != null) {
      _pushBeamLocation(guard.beamTo!(context));
    } else if (guard.beamToNamed != null) {
      state = createState!(Uri.parse(guard.beamToNamed!));
      final location = locationBuilder(_state);
      _pushBeamLocation(location);
    }
  }

  void updateRouteInformation() {
    if (_parent != null) {
      _parent!._updateParentRouteInformation(_currentLocation.state.uri);
    } else {
      SystemNavigator.routeInformationUpdated(
        location: _currentLocation.state.uri.toString(),
      );
    }
  }

  void _pushBeamLocation(BeamLocation location) {
    _beamHistory.add(location);
    _currentLocation = _beamHistory.last;
    _currentLocation.addListener(_notify);
  }

  // This should be called only on parent
  void _updateParentRouteInformation(Uri uri, {bool rebuild = false}) {
    _currentLocation.state = BeamState.fromUri(
      uri,
      beamLocation: _currentLocation,
      data: state.data,
    );
    if (_parent == null) {
      SystemNavigator.routeInformationUpdated(location: uri.toString());
    } else {
      Uri fullUri;
      if (!uri.path.startsWith('/')) {
        // TODO! relative paths
        if (_parent!._currentLocation.state.uri.path.contains(uri.path)) {
          fullUri = _parent!._currentLocation.state.uri;
        } else {
          fullUri = Uri(
              path: _parent!._currentLocation.state.uri.path + '/' + uri.path,
              queryParameters: {
                ..._parent!.currentLocation.state.uri.queryParameters,
                ...uri.queryParameters
              });
        }
      } else {
        fullUri = Uri.parse(uri.toString());
      }
      _parent!._updateParentRouteInformation(fullUri, rebuild: rebuild);
    }
    if (rebuild) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _currentLocation.removeListener(_notify);
    super.dispose();
  }
}
