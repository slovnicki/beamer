import 'package:beamer/beamer.dart';
import 'package:beamer/src/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.updateListenable,
    @Deprecated(
      'No longer used by this package, please remove any references to it. '
      'This feature was deprecated after v1.0.0.',
    )
        this.preferUpdate = true,
    this.removeDuplicateHistory = true,
    this.notFoundPage = BeamPage.notFound,
    this.notFoundRedirect,
    this.notFoundRedirectNamed,
    this.guards = const <BeamGuard>[],
    this.navigatorObservers = const <NavigatorObserver>[],
    this.transitionDelegate = const DefaultTransitionDelegate(),
    this.beamBackTransitionDelegate = const ReverseTransitionDelegate(),
    this.onPopPage,
    this.setBrowserTabTitle = true,
    this.initializeFromParent = true,
    this.updateFromParent = true,
    this.updateParent = true,
    this.clearBeamingHistoryOn = const <String>{},
  }) {
    _currentBeamParameters = BeamParameters(
      transitionDelegate: transitionDelegate,
    );

    configuration = RouteInformation(location: initialPath);

    updateListenable?.addListener(_update);
  }

  /// A state of this delegate. This is the `routeInformation` that goes into
  /// [locationBuilder] to build an appropriate [BeamLocation].
  ///
  /// A way to modify this state is via [update].
  late RouteInformation configuration;

  BeamerDelegate? _parent;

  final Set<BeamerDelegate> _children = {};

  /// Takes priority over all other siblings,
  /// i.e. sets itself as active and all other siblings as inactive.
  void takePriority() {
    if (_parent?._children.isNotEmpty ?? false) {
      for (var child in _parent!._children) {
        child.active = false;
      }
    }
    active = true;
  }

  /// A delegate of a parent of the [Beamer] that has this delegate.
  ///
  /// This is not null only if multiple [Beamer]s are used;
  /// `*App.router` and at least one more [Beamer] in the Widget tree.
  BeamerDelegate? get parent => _parent;
  set parent(BeamerDelegate? parent) {
    if (parent == null && _parent != null) {
      _parent!.removeListener(_updateFromParent);
      _parent!._children.remove(this);
      _parent = null;
      return;
    }
    if (_parent == parent) {
      return;
    }
    _parent = parent;
    _parent!._children.add(this);
    _initializeChild();
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

  /// An initial deep-link that should be stored until used.
  ///
  /// This can be used in [BeamGuard.beamToNamed] to redirect properly after
  /// some auth flows that need to be executed, during which the [initialPath]
  /// information is lost.
  String? _deepLink;

  /// Sets the deep-link route path that
  /// - will be used as [initialPath]
  /// - can be used in [BeamGuard.beamToNamed] to redirect properly
  /// after some auth flows that need to be executed,
  /// during which the [initialPath] information is lost.
  ///
  /// Once a [BeamGuard] uses the deep-link, it will be reset to null.
  void setDeepLink(String? deepLink) => _deepLink = deepLink;

  /// The routeListener will be called on every navigation event
  /// and will receive the [configuration] and a reference to this delegate.
  final void Function(RouteInformation, BeamerDelegate)? routeListener;

  /// The buildListener will be called every time after the [currentPages]
  /// are updated. it receives a reference to this delegate.
  final void Function(BuildContext, BeamerDelegate)? buildListener;

  /// A Listenable to which an update listener will be added, i.e.
  /// [update] will be called when listeners are notified.
  final Listenable? updateListenable;

  @Deprecated(
    'No longer used by this package, please remove any references to it. '
    'This feature was deprecated after v1.0.0.',
  )
  // ignore: public_member_api_docs
  final bool preferUpdate;

  /// Whether to remove [BeamLocation]s from [beamingHistory]
  /// if they are the same type as the location being beamed to.
  ///
  /// See how this is used at [_addToBeamingHistory] implementation.
  final bool removeDuplicateHistory;

  /// Page to show when no [BeamLocation] supports the incoming URI.
  late BeamPage notFoundPage;

  /// [BeamLocation] to redirect to when no [BeamLocation] supports the incoming URI.
  final BeamLocation? notFoundRedirect;

  /// URI string to redirect to when no [BeamLocation] supports the incoming URI.
  final String? notFoundRedirectNamed;

  /// Guards that will be executing [BeamGuard.check] on [currentBeamLocation]
  /// candidate.
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

  /// Whether to take [configuration] from parent when this is created.
  ///
  /// If false, the [initialPath] will be used.
  final bool initializeFromParent;

  /// Whether to call [update] when parent notifies listeners.
  ///
  /// This means that navigation can be done either on parent or on this
  final bool updateFromParent;

  /// Whether to call [update] on [parent] when this instance's [configuration]
  /// is updated.
  ///
  /// This means that parent's [beamingHistory] will be in sync.
  final bool updateParent;

  /// Whether to remove all entries from [beamingHistory] (and their nested
  /// [BeamLocation.history]) when a route belonging to this set is reached,
  /// regardless of how it was reached.
  ///
  /// Note that [popToNamed] will also try to clear as much [beamingHistory]
  /// as possible, even when this is empty.
  final Set<String> clearBeamingHistoryOn;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// {@template beamingHistory}
  /// The history of [BeamLocation]s, each holding its [BeamLocation.history].
  ///
  /// See [_addToBeamingHistory].
  /// {@endtemplate}
  final List<BeamLocation> beamingHistory = [];

  /// Returns the complete length of beaming history, that is the sum of all
  /// history lengths for each [BeamLocation] in [beamingHistory].
  int get beamingHistoryCompleteLength {
    var length = 0;
    for (var location in beamingHistory) {
      length += location.history.length;
    }
    return length;
  }

  /// A candidate to become the next [currentBeamLocation].
  BeamLocation _beamLocationCandidate = EmptyBeamLocation();

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

  /// A context for guards
  BuildContext? _context;

  /// Whether guards already ran.
  ///
  /// This is used to decide whether guards need to be run in the [build].
  /// They will run just in [update] everytime, except on first build,
  /// when the `Navigator` does not exist so we don't have `context`.
  bool _didRunGuards = false;

  /// Is [build] in progress.
  /// Used to determine not to [notifyListeners].
  bool _buildInProgress = false;

  /// Whether the [configuration] is ready to be consumed by platform,
  /// most importantly - the browser URL bar.
  ///
  /// This is important for first build, i.e. [setInitialRoutePath],
  /// to avoid setting URL when the guards have not been run yet.
  bool _initialConfigurationReady = false;

  /// Main method to update the [configuration] of this delegate and its
  /// [currentBeamLocation].
  ///
  /// This "top-level" [update] is generally used for navigation
  /// _between_ [BeamLocation]s and not _within_ a specific [BeamLocation].
  /// For latter purpose, see [BeamLocation.update].
  /// Nevertheless, [update] **will** work for navigation within [BeamLocation].
  ///
  /// Calling [update] will run the [locationBuilder].
  ///
  /// ```dart
  /// Beamer.of(context).update(
  ///   state: BeamState.fromUriString('/xx'),
  /// );
  /// ```
  ///
  /// **all of the beaming functions call [update] to really do the update.**
  ///
  /// [beamParameters] hold various parameters such as `transitionDelegate` and
  /// other that will be used for this update **and** stored in history.
  ///
  /// [data] can be used to hold arbitrary [Object] throughout navigation.
  /// See [BeamLocation.data] for more information.
  ///
  /// [buildBeamLocation] determines whether a [BeamLocation] should be created
  /// from [configuration], using the [locationBuilder]. For example, when using
  /// [beamTo] and passing an already created [BeamLocation], this can be false.
  ///
  /// [rebuild] determines whether to call [notifyListeners]. This can be false
  /// if we already have built the UI and just want to notify the platform,
  /// e.g. browser, of the new [RouteInformation].
  ///
  /// [updateParent] is used in nested navigation to call [update] on [parent].
  ///
  /// [updateRouteInformation] determines whether to update the browser's URL.
  /// This is usually done through `notifyListeners`, but in specific cases,
  /// e.g. when [rebuild] is false, browser would not be updated.
  /// This is mainly used to not update the route information from parent,
  /// when it has already been done by this delegate.
  void update({
    RouteInformation? configuration,
    BeamParameters? beamParameters,
    Object? data,
    bool buildBeamLocation = true,
    bool rebuild = true,
    bool updateParent = true,
    bool updateRouteInformation = true,
    bool replaceRouteInformation = false,
    bool takePriority = true,
  }) {
    if (takePriority) {
      this.takePriority();
    }

    if (_buildInProgress) {
      rebuild = false;
    }

    replaceRouteInformation
        ? SystemNavigator.selectSingleEntryHistory()
        : SystemNavigator.selectMultiEntryHistory();

    this.configuration = configuration != null
        ? Utils.createNewConfiguration(this.configuration, configuration)
        : currentBeamLocation.state.routeInformation.copyWith();

    // update beam parameters
    _currentBeamParameters = beamParameters ?? _currentBeamParameters;

    if (buildBeamLocation) {
      // build a BeamLocation from configuration
      _beamLocationCandidate = locationBuilder(
        this.configuration.copyWith(),
        _currentBeamParameters,
      );
    }

    // run guards on _beamLocationCandidate
    final context = _context;
    if (context != null) {
      final didApply = _runGuards(context, _beamLocationCandidate);
      _didRunGuards = true;
      if (didApply) {
        return;
      } else {
        // TODO revert configuration if guard just blocked navigation
      }
    }

    // adds the candidate to history
    // it will become currentBeamLocation after this step
    _updateBeamingHistory(_beamLocationCandidate);
    if (data != null) {
      currentBeamLocation.data = data;
    }

    routeListener?.call(this.configuration, this);

    // update parent if necessary
    if (this.updateParent && updateParent) {
      _parent?.update(
        configuration: this.configuration.copyWith(),
        rebuild: false,
        updateRouteInformation: false,
      );
    }

    // update browser history
    // if this is from nested Beamer
    // or
    // if rebuild was false (browser will not be notified implicitly)
    if (updateRouteInformation && active && (_parent != null || !rebuild)) {
      this.updateRouteInformation(this.configuration);
    }

    // initiate build
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
    Object? data,
    BeamLocation? popTo,
    TransitionDelegate? transitionDelegate,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
    bool replaceRouteInformation = false,
  }) {
    _beamLocationCandidate = location;
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
      replaceRouteInformation: replaceRouteInformation,
    );
  }

  /// The same as [beamTo], but replaces the last state in history,
  /// i.e. removes it from the `beamingHistory.last.history` and then does [beamTo].
  void beamToReplacement(
    BeamLocation location, {
    Object? data,
    BeamLocation? popTo,
    TransitionDelegate? transitionDelegate,
    bool beamBackOnPop = false,
    bool popBeamLocationOnPop = false,
    bool stacked = true,
  }) {
    removeLastHistoryElement();
    beamTo(
      location,
      data: data,
      popTo: popTo,
      transitionDelegate: transitionDelegate,
      beamBackOnPop: beamBackOnPop,
      popBeamLocationOnPop: popBeamLocationOnPop,
      stacked: stacked,
      replaceRouteInformation: true,
    );
  }

  /// {@template beamToNamed}
  /// Configures and beams to a [BeamLocation] that supports uri within its
  /// [BeamLocation.pathPatterns].
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
    bool replaceRouteInformation = false,
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
      replaceRouteInformation: replaceRouteInformation,
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
      replaceRouteInformation: true,
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
    bool replaceRouteInformation = false,
  }) {
    while (beamingHistory.isNotEmpty) {
      final index = beamingHistory.last.history.lastIndexWhere(
        (element) => element.routeInformation.location == uri,
      );
      if (index == -1) {
        _disposeBeamLocation(beamingHistory.last);
        beamingHistory.removeLast();
        continue;
      } else {
        beamingHistory.last.history
            .removeRange(index, beamingHistory.last.history.length);
        break;
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
      replaceRouteInformation: replaceRouteInformation,
    );
  }

  /// {@template canBeamBack}
  /// Whether it is possible to [beamBack],
  /// i.e. there is more than 1 entry in [beamingHistoryCompleteLength].
  /// {@endtemplate}
  bool get canBeamBack => beamingHistoryCompleteLength > 1;

  /// {@template beamBack}
  /// Beams to previous entry in [beamingHistory].
  /// and **removes** the last entry from history.
  ///
  /// If there is no previous entry, does nothing.
  ///
  /// Returns the success, whether [update] was executed.
  /// {@endtemplate}
  bool beamBack({
    Object? data,
    bool replaceRouteInformation = false,
  }) {
    if (!canBeamBack) {
      return false;
    }
    // first we try to beam back within last BeamLocation
    // i.e. we just pop its last history element id possible
    if (beamingHistory.last.history.length > 1) {
      beamingHistory.last.history.removeLast();
    } else {
      // here we know that beamingHistory.length > 1 (because of canBeamBack)
      // and that beamingHistory.last.history.length == 1
      // so this last (only) entry is removed along with BeamLocation
      _disposeBeamLocation(beamingHistory.last);
      beamingHistory.removeLast();
      _initBeamLocation(beamingHistory.last);
    }

    _beamLocationCandidate = beamingHistory.last;
    _beamLocationCandidate.update();
    final targetHistoryElement = _beamLocationCandidate.history.last;

    update(
      configuration: targetHistoryElement.routeInformation.copyWith(),
      beamParameters: targetHistoryElement.parameters.copyWith(
        transitionDelegate: beamBackTransitionDelegate,
      ),
      data: data,
      buildBeamLocation: false,
      replaceRouteInformation: replaceRouteInformation,
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
  bool popBeamLocation({
    Object? data,
    bool replaceRouteInformation = false,
  }) {
    if (!canPopBeamLocation) {
      return false;
    }
    _disposeBeamLocation(currentBeamLocation);
    beamingHistory.removeLast();
    _beamLocationCandidate = beamingHistory.last;
    update(
      beamParameters: currentBeamLocation.history.last.parameters.copyWith(
        transitionDelegate: beamBackTransitionDelegate,
      ),
      data: data,
      buildBeamLocation: false,
      replaceRouteInformation: replaceRouteInformation,
    );
    return true;
  }

  @override
  RouteInformation? get currentConfiguration {
    final response =
        _parent == null && _initialConfigurationReady ? configuration : null;
    if (response != null) {
      _lastReportedRouteInformation = response.copyWith();
    }
    return response;
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  Widget build(BuildContext context) {
    _buildInProgress = true;
    _context = context;

    if (!_didRunGuards) {
      _runGuards(_context!, _beamLocationCandidate);
      _addToBeamingHistory(_beamLocationCandidate);
    }
    if (!_initialConfigurationReady && active && parent != null) {
      updateRouteInformation(configuration);
    }
    _initialConfigurationReady = true;

    if (currentBeamLocation is NotFound) {
      _handleNotFoundRedirect();
    }

    if (!currentBeamLocation.mounted) {
      currentBeamLocation.buildInit(context);
    }

    final navigator = Builder(
      builder: (context) {
        _setCurrentPages(context);
        _setBrowserTitle(context);

        buildListener?.call(context, this);
        return Navigator(
          key: navigatorKey,
          observers: navigatorObservers,
          transitionDelegate: currentBeamLocation.transitionDelegate ??
              _currentBeamParameters.transitionDelegate,
          pages: _currentPages,
          onPopPage: (route, result) => _onPopPage(context, route, result),
        );
      },
    );

    _buildInProgress = false;
    return currentBeamLocation.builder(context, navigator);
  }

  @override
  SynchronousFuture<void> setInitialRoutePath(RouteInformation configuration) {
    _initialConfigurationReady = false;
    final uri = Uri.parse(configuration.location ?? '/');
    if (currentBeamLocation is! EmptyBeamLocation) {
      configuration = currentBeamLocation.state.routeInformation;
    } else if (uri.path == '/') {
      configuration = RouteInformation(
        location: initialPath + (uri.query.isNotEmpty ? '?${uri.query}' : ''),
      );
    }
    _deepLink ??= configuration.location;
    return setNewRoutePath(configuration);
  }

  @override
  SynchronousFuture<void> setNewRoutePath(RouteInformation configuration) {
    if (!_initialConfigurationReady &&
        configuration.location == '/' &&
        (_deepLink != null || initialPath != '/')) {
      configuration = configuration.copyWith(
        location: _deepLink ?? initialPath,
      );
    }
    update(configuration: configuration);
    return SynchronousFuture(null);
  }

  RouteInformation? _lastReportedRouteInformation;

  /// Pass this call to [root] which notifies the platform for a [configuration]
  /// change.
  ///
  /// On Web, creates a new browser history entry and updates URL.
  ///
  /// See [SystemNavigator.routeInformationUpdated].
  void updateRouteInformation(RouteInformation routeInformation) {
    if (_parent == null) {
      if (!routeInformation.isEqualTo(_lastReportedRouteInformation)) {
        SystemNavigator.routeInformationUpdated(
          location: routeInformation.location ?? '/',
          state: routeInformation.state,
        );
        _lastReportedRouteInformation = routeInformation.copyWith();
      }
    } else {
      if (updateParent) {
        _parent!.configuration = routeInformation.copyWith();
      }
      _parent!.updateRouteInformation(routeInformation);
    }
  }

  bool _runGuards(BuildContext context, BeamLocation targetBeamLocation) {
    final allGuards =
        (parent?.guards ?? []) + guards + targetBeamLocation.guards;
    for (final guard in allGuards) {
      if (guard.shouldGuard(targetBeamLocation)) {
        final wasApplied = guard.apply(
          context,
          this,
          currentBeamLocation,
          _currentPages,
          targetBeamLocation,
          _deepLink,
        );

        // Return true on the first guard that was fully applied
        if (wasApplied) {
          return true;
        }
      }
    }
    return false;
  }

  void _initBeamLocation(BeamLocation beamLocation) {
    beamLocation.initState();
    beamLocation.onUpdate();
    beamLocation.addListener(_updateFromCurrentBeamLocation);
  }

  void _disposeBeamLocation(BeamLocation beamLocation) {
    beamLocation.removeListener(_updateFromCurrentBeamLocation);
    beamLocation.disposeState();
  }

  void _addToBeamingHistory(BeamLocation beamLocation) {
    _disposeBeamLocation(currentBeamLocation);
    if (removeDuplicateHistory) {
      final index = beamingHistory.indexWhere((historyLocation) =>
          historyLocation.runtimeType == beamLocation.runtimeType);
      if (index != -1) {
        _disposeBeamLocation(beamingHistory[index]);
        beamingHistory.removeAt(index);
      }
    }
    _initBeamLocation(beamLocation);
    beamingHistory.add(beamLocation);
  }

  void _updateBeamingHistory(BeamLocation beamLocation) {
    if (beamingHistory.isEmpty ||
        beamLocation.runtimeType != beamingHistory.last.runtimeType) {
      _addToBeamingHistory(beamLocation);
    } else {
      beamingHistory.last.update(
        null,
        configuration.copyWith(),
        _currentBeamParameters,
        false,
        false,
      );
    }

    if (clearBeamingHistoryOn.contains(configuration.location)) {
      _clearBeamingHistory();
    }
  }

  void _clearBeamingHistory() {
    while (beamingHistoryCompleteLength > 1) {
      removeFirstHistoryElement();
    }
  }

  /// Removes the first element from [beamingHistory] and returns it.
  ///
  /// If there is none, returns `null`.
  HistoryElement? removeFirstHistoryElement() {
    if (beamingHistoryCompleteLength == 0) {
      return null;
    }
    if (updateParent) {
      _parent?.removeFirstHistoryElement();
    }
    final firstBeamLocation = beamingHistory.first;
    final firstHistoryElement = firstBeamLocation.removeFirstFromHistory();
    if (firstBeamLocation.history.isEmpty) {
      _disposeBeamLocation(firstBeamLocation);
      beamingHistory.removeAt(0);
    }

    return firstHistoryElement;
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
      _disposeBeamLocation(beamingHistory.last);
      beamingHistory.removeLast();
    } else {
      beamingHistory.last.update(null, null, null, false);
    }

    return lastHistoryElement;
  }

  void _handleNotFoundRedirect() {
    if (notFoundRedirect == null && notFoundRedirectNamed == null) {
      // do nothing, pass on NotFound
      return;
    }
    if (notFoundRedirect != null) {
      _beamLocationCandidate = notFoundRedirect!;
    } else if (notFoundRedirectNamed != null) {
      _beamLocationCandidate = locationBuilder(
        RouteInformation(location: notFoundRedirectNamed),
        _currentBeamParameters.copyWith(),
      );
    }
    _updateFromBeamLocationCandidate();
  }

  void _setCurrentPages(BuildContext context) {
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
          resetPopConfiguration: true,
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

    return route.didPop(result);
  }

  // When a nested Beamer gets into a Widget tree, it must initialize.
  // It will try to take the configuration from parent,
  // but act differently depending on whether it can handle that configuration.
  void _initializeChild() {
    final parentConfiguration = _parent!.configuration.copyWith();
    if (initializeFromParent) {
      _beamLocationCandidate =
          locationBuilder(parentConfiguration, _currentBeamParameters);
    }

    // If this couldn't handle parents configuration,
    // it will update itself to initialPath and declare itself inactive.
    if (_beamLocationCandidate is EmptyBeamLocation ||
        _beamLocationCandidate is NotFound) {
      update(
        configuration: RouteInformation(location: initialPath),
        rebuild: false,
        updateParent: false,
        updateRouteInformation: false,
        takePriority: false,
      );
      active = false;
    } else {
      update(
        configuration: parentConfiguration,
        rebuild: false,
        updateParent: false,
        updateRouteInformation: false,
      );
    }
  }

  void _update() => update();

  // Updates only if it can handle the configuration
  void _updateFromParent({bool rebuild = true}) {
    final parentConfiguration = _parent!.configuration.copyWith();
    final beamLocation =
        locationBuilder(parentConfiguration, _currentBeamParameters);

    if (beamLocation is! NotFound) {
      update(
        configuration: parentConfiguration,
        rebuild: rebuild,
        updateParent: false,
        updateRouteInformation: false,
      );
    }
  }

  void _updateFromCurrentBeamLocation({bool rebuild = true}) {
    update(
      configuration: currentBeamLocation.state.routeInformation,
      buildBeamLocation: false,
      rebuild: rebuild,
    );
  }

  void _updateFromBeamLocationCandidate({bool rebuild = false}) {
    update(
      configuration: _beamLocationCandidate.state.routeInformation,
      buildBeamLocation: false,
      rebuild: rebuild,
    );
  }

  // This is a temporary implementation
  // as there is a ?bug? when navigating with browser buttons
  // that keeps creating new delegates **but** persisting the children List.
  // The children list then grows unnecessary.
  //
  // Also tried with navigatorKey, but this is also newly created
  // Using initialPath is not perfect,
  // but should be good until I investigate further.
  //
  // These overrides are for the inserting into a Set of children
  @override
  bool operator ==(other) {
    if (other is! BeamerDelegate) {
      return false;
    }
    return initialPath == other.initialPath;
  }

  @override
  int get hashCode => initialPath.hashCode;

  @override
  void dispose() {
    _children.clear();
    _parent?.removeListener(_updateFromParent);
    _disposeBeamLocation(currentBeamLocation);
    currentBeamLocation.dispose();
    updateListenable?.removeListener(_update);
    super.dispose();
  }
}
