import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A notifier for communication between
/// [RootRouterDelegate] and [BeamerRouterDelegate].
///
/// Gets created and kept in [RootRouterDelegate].
class NavigationNotifier extends ChangeNotifier {
  NavigationNotifier() : _uri = Uri.parse('/');

  Uri _uri;
  Uri get uri => _uri;
  set uri(Uri uri) {
    _uri = uri;
    notifyListeners();
  }
}

/// A delegate that is used by the [Router] widget
/// to build and configure a navigating widget.
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
    this.onPopPage,
  }) {
    createState ??= (
      Uri uri, {
      Map<String, dynamic> data = const <String, dynamic>{},
    }) =>
        BeamState.fromUri(uri, data: data) as T;
    notFoundPage ??= BeamPage(
      child: Container(child: Center(child: Text('Not found'))),
    );
    _currentLocation = locationBuilder(createState!(Uri.parse(initialPath)));
  }

  T Function(
    Uri uri, {
    Map<String, dynamic> data,
  })? createState;

  NavigationNotifier? _navigationNotifier;
  NavigationNotifier? get navigationNotifier => _navigationNotifier;
  set navigationNotifier(NavigationNotifier? navigationNotifier) {
    _navigationNotifier = navigationNotifier;
    final location = locationBuilder(createState!(_navigationNotifier!.uri));
    _beamHistory.add(location..prepare());
    _currentLocation = _beamHistory.last;
    _currentLocation.addListener(notify);
    _navigationNotifier!.addListener(setPathFromUriNotifier);
  }

  void setPathFromUriNotifier() {
    if (_navigationNotifier!.uri != _currentLocation.state.uri) {
      setNewRoutePath(_navigationNotifier!.uri);
    }
  }

  void notify() {
    _navigationNotifier?.uri = _currentLocation.state.uri;
    notifyListeners();
  }

  /// List of all [BeamLocation]s that this router handles.
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

  /// Which location to pop to, instead of default pop.
  ///
  /// This is more general than `beamBackOnPop`.
  BeamLocation? _popTo;

  /// Whether all the pages from location are stacked.
  /// If not (`false`), just the last page is taken.
  bool _stacked = true;

  /// Beams to `location`.
  ///
  /// Specifically,
  ///
  /// 1. adds the prepared `location` to [beamHistory]
  /// 2. updates [currentLocation]
  /// 3. notifies that the [Navigator] should be rebuilt
  ///
  /// If `beamBackOnPop` is set to `true`, default pop action on the newly
  /// beamed location will triger `beamBack` instead.
  /// If `stacked` is set to `false`, only the location's last page will be shown.
  /// If `replaceCurrent` is set to `true`, new location will replace the last one in the stack.
  void beamTo(
    BeamLocation location, {
    bool beamBackOnPop = false,
    BeamLocation? popTo,
    bool stacked = true,
    bool replaceCurrent = false,
  }) {
    _currentLocation.removeListener(notify);
    _beamBackOnPop = beamBackOnPop;
    _popTo = popTo;
    _stacked = stacked;
    if ((preferUpdate &&
            location.runtimeType == _currentLocation.runtimeType) ||
        replaceCurrent) {
      if (_beamHistory.isNotEmpty) {
        _beamHistory.removeLast();
      }
    }
    if (removeDuplicateHistory) {
      _beamHistory.removeWhere((l) => l.runtimeType == location.runtimeType);
    }
    _beamHistory.add(location..prepare());
    _currentLocation = _beamHistory.last;
    _currentLocation.addListener(notify);
    _update();
  }

  /// Beams to [BeamLocation] that handles `uri`. See [beamTo].
  ///
  /// For example
  ///
  /// ```dart
  /// Beamer.of(context).beamToNamed(
  ///   '/user/1/transactions?perPage=10',
  ///   data: {'beenHereBefore': true},
  /// );
  /// ```
  ///
  /// `data` can be used to pass any data through the location.
  /// See [BeamLocation.data].
  void beamToNamed(
    String uri, {
    Map<String, dynamic> data = const <String, dynamic>{},
    bool beamBackOnPop = false,
    String? popToNamed,
    bool stacked = true,
    bool replaceCurrent = false,
  }) {
    final location = locationBuilder(createState!(Uri.parse(uri), data: data));
    final popLocation = popToNamed != null
        ? locationBuilder(createState!(Uri.parse(popToNamed), data: data))
        : null;
    beamTo(
      location,
      beamBackOnPop: beamBackOnPop,
      popTo: popLocation,
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
    _beamBackOnPop = false;
    _popTo = null;
    _stacked = true;
    if (!canBeamBack) {
      return false;
    }
    _beamHistory.removeLast();
    _currentLocation = _beamHistory.last;
    _update();
    return true;
  }

  /// Remove everything except last from [beamHistory].
  void clearHistory() => _beamHistory.removeRange(0, _beamHistory.length - 1);

  @override
  Uri? get currentConfiguration =>
      _navigationNotifier == null ? _currentLocation.state.uri : null;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  Widget build(BuildContext context) {
    BeamGuard? guard = _globalGuardCheck(context, _currentLocation);
    if (guard != null && guard.showPage == null) {
      _applyGuard(guard, context);
    }
    if (guard == null) {
      guard = _localGuardCheck(context, _currentLocation);
      if (guard != null && guard.showPage == null) {
        _applyGuard(guard, context);
      }
    }
    if ((_currentLocation is NotFound) && notFoundRedirect != null) {
      _currentLocation = notFoundRedirect!..prepare();
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
          transitionDelegate:
              _currentLocation.transitionDelegate ?? transitionDelegate,
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
              _beamBackOnPop = false;
              _popTo = null;
            } else if (_popTo != null) {
              beamTo(_popTo!, replaceCurrent: true);
              _beamBackOnPop = false;
              _popTo = null;
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
    final location = locationBuilder(createState!(uri));
    beamTo(location);
    return SynchronousFuture(null);
  }

  void _update() {
    notifyListeners();
    _navigationNotifier?.uri = _currentLocation.state.uri;
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
    _currentLocation.notifyListeners();
  }

  BeamGuard? _globalGuardCheck(BuildContext context, BeamLocation location) {
    for (var guard in guards) {
      if (guard.shouldGuard(location) && !guard.check(context, location)) {
        guard.onCheckFailed?.call(context, location);
        return guard;
      }
    }
    return null;
  }

  BeamGuard? _localGuardCheck(BuildContext context, BeamLocation location) {
    for (var guard in location.guards) {
      if (guard.shouldGuard(location) && !guard.check(context, location)) {
        guard.onCheckFailed?.call(context, location);
        return guard;
      }
    }
    return null;
  }

  void _applyGuard(BeamGuard guard, BuildContext context) {
    if (guard.replaceCurrentStack) {
      _beamHistory.removeLast();
    }
    if (guard.beamTo != null) {
      _beamHistory.add(guard.beamTo!(context)..prepare());
      _currentLocation = _beamHistory.last;
    } else if (guard.beamToNamed != null) {
      final location =
          locationBuilder(createState!(Uri.parse(guard.beamToNamed!)));
      _beamHistory.add(location..prepare());
      _currentLocation = _beamHistory.last;
    }
  }

  @override
  void dispose() {
    _navigationNotifier?.removeListener(setPathFromUriNotifier);
    super.dispose();
  }
}

class _RootLocation extends BeamLocation {
  _RootLocation(state, this.homeBuilder) : super(state);

  final Function(BuildContext context, BeamState state) homeBuilder;

  @override
  List<String> get pathBlueprints => ['/*'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('root'),
          child: homeBuilder(context, state),
        )
      ];
}

/// A delegate that communicates with browser when there are nested routers.
///
/// Creates the instance of [NavigationNotifier] that deeper routers will listen.
class RootRouterDelegate extends BeamerRouterDelegate {
  RootRouterDelegate({
    this.homeBuilder,
    LocationBuilder? locationBuilder,
    String initialPath = '/',
    bool preferUpdate = true,
    bool removeDuplicateHistory = true,
    BeamPage? notFoundPage,
    BeamLocation? notFoundRedirect,
    List<BeamGuard> guards = const <BeamGuard>[],
    List<NavigatorObserver> navigatorObservers = const <NavigatorObserver>[],
    TransitionDelegate transitionDelegate = const DefaultTransitionDelegate(),
  })  : assert(homeBuilder != null || locationBuilder != null),
        super(
          locationBuilder: locationBuilder ??
              (_) => _RootLocation(BeamState(), homeBuilder!),
          initialPath: initialPath,
          preferUpdate: preferUpdate,
          removeDuplicateHistory: removeDuplicateHistory,
          notFoundPage: notFoundPage,
          notFoundRedirect: notFoundRedirect,
          guards: guards,
          navigatorObservers: navigatorObservers,
          transitionDelegate: transitionDelegate,
        ) {
    _navigationNotifier = NavigationNotifier()..addListener(notifyListeners);
  }

  final Function(BuildContext context, BeamState state)? homeBuilder;

  @override
  Uri get currentConfiguration => _navigationNotifier!.uri;

  @override
  SynchronousFuture<void> setNewRoutePath(Uri uri) {
    final location = locationBuilder(createState!(uri));
    beamTo(location);
    _navigationNotifier!.uri = uri;
    return SynchronousFuture(null);
  }

  @override
  void dispose() {
    _navigationNotifier!.removeListener(notifyListeners);
    super.dispose();
  }
}
