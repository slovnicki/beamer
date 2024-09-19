import 'package:beamer/beamer.dart';
import 'package:beamer/src/utils.dart';
import 'package:flutter/widgets.dart';

/// Parameters used while beaming.
class BeamParameters {
  /// Creates a [BeamParameters] with specified properties.
  ///
  /// All attributes can be null.
  const BeamParameters({
    this.transitionDelegate = const DefaultTransitionDelegate(),
    this.popConfiguration,
    this.beamBackOnPop = false,
    this.popBeamStackOnPop = false,
    this.stacked = true,
  });

  /// Which transition delegate to use when building pages.
  final TransitionDelegate transitionDelegate;

  /// Which route to pop to, instead of default pop.
  ///
  /// This is more general than [beamBackOnPop].
  final RouteInformation? popConfiguration;

  /// Whether to implicitly [BeamerDelegate.beamBack] instead of default pop.
  final bool beamBackOnPop;

  /// Whether to remove entire current [BeamStack] from history,
  /// instead of default pop.
  final bool popBeamStackOnPop;

  /// Whether all the pages produced by [BeamStack.buildPages] are stacked.
  /// If not (`false`), just the last page is taken.
  final bool stacked;

  /// Returns a copy of this with optional changes.
  BeamParameters copyWith({
    TransitionDelegate? transitionDelegate,
    RouteInformation? popConfiguration,
    bool resetPopConfiguration = false,
    bool? beamBackOnPop,
    bool? popBeamStackOnPop,
    bool? stacked,
  }) {
    return BeamParameters(
      transitionDelegate: transitionDelegate ?? this.transitionDelegate,
      popConfiguration: resetPopConfiguration
          ? null
          : popConfiguration ?? this.popConfiguration,
      beamBackOnPop: beamBackOnPop ?? this.beamBackOnPop,
      popBeamStackOnPop: popBeamStackOnPop ?? this.popBeamStackOnPop,
      stacked: stacked ?? this.stacked,
    );
  }
}

/// An element of [BeamStack.history] list.
///
/// Contains the [RouteInformation] and [BeamParameters] at the moment
/// of beaming to it.
class HistoryElement {
  /// Creates a [HistoryElement] with specified properties.
  ///
  /// [routeInformation] must not be null.
  const HistoryElement(
    this.routeInformation, [
    this.parameters = const BeamParameters(),
  ]);

  /// A [RouteInformation] of this history entry.
  final RouteInformation routeInformation;

  /// Parameters that were used during beaming.
  final BeamParameters parameters;
}

/// Configuration for a navigatable application region.
///
/// Responsible for
///   * knowing which URIs it can handle: [pathPatterns]
///   * knowing how to build a stack of pages: [buildPages]
///   * keeping a [state] that provides the link between the first 2
///
/// Extend this class to define your stacks to which you can then beam to.
abstract class BeamStack<T extends RouteInformationSerializable>
    extends ChangeNotifier {
  /// Creates a [BeamStack] with specified properties.
  ///
  /// All attributes can be null.
  BeamStack(
    this.debugLabel, [
    RouteInformation? routeInformation,
    BeamParameters? beamParameters,
  ]) {
    create(routeInformation, beamParameters);
  }

  // final debugLabel = DateTime.now().millisecondsSinceEpoch.toString();

  final String debugLabel;

  late T _state;

  /// A state of this [BeamStack].
  ///
  /// Upon beaming, it will be populated by all necessary attributes.
  /// See also: [BeamState].
  T get state => _state;

  /// Sets the [state] and adds to [history].
  set state(T state) {
    _state = state;
    addToHistory(_state.routeInformation);
  }

  /// Beam parameters used to beam to the current [state].
  BeamParameters get beamParameters => history.last.parameters;

  /// An arbitrary data to be stored in this.
  /// This will persist while navigating within this [BeamStack].
  ///
  /// Therefore, in the case of using [RoutesStackBuilder] which uses only
  /// a single [RoutesBeamStack] for all page stacks, this data will
  /// be available always, until overriden with some new data.
  Object? data;

  bool _mounted = false;

  /// Whether [buildInit] was called.
  ///
  /// See [buildInit].
  bool get mounted => _mounted;

  bool _isCurrent = false;

  /// Whether this [BeamStack] is currently in use by [BeamerDelegate].
  ///
  /// This influences on the behavior of [create] that gets called on existing
  /// [BeamStack]s when using [BeamerStackBuilder] that uses [Utils.chooseBeamStack].
  bool get isCurrent => _isCurrent;

  /// Creates the [state] and adds the [routeInformation] to [history].
  /// This is called only once during the lifetime of [BeamStack].
  ///
  /// See [createState] and [addToHistory].
  void create([
    RouteInformation? routeInformation,
    BeamParameters? beamParameters,
    bool tryPoppingHistory = true,
  ]) {
    if (!isCurrent) {
      try {
        disposeState();
      } catch (e) {
        //
      }
      history.clear();
    }
    state = createState(
      routeInformation ?? RouteInformation(uri: Uri.parse('/')),
    );
    addToHistory(
      state.routeInformation,
      beamParameters ?? const BeamParameters(),
      tryPoppingHistory,
    );
  }

  /// How to create state from [RouteInformation] given by
  /// [BeamerDelegate] and passed via [BeamerDelegate.stackBuilder].
  ///
  /// This will be called only once during the lifetime of [BeamStack].
  /// One should override this if using a custom state class.
  ///
  /// See [create].
  T createState(RouteInformation routeInformation) =>
      BeamState.fromRouteInformation(
        routeInformation,
        beamStack: this,
      ) as T;

  /// What to do on state initialization.
  ///
  /// For example, add listeners to [state] if it's a [ChangeNotifier].
  @mustCallSuper
  void initState() {
    _isCurrent = true;
  }

  /// Updates the [state] upon receiving new [RouteInformation], which usually
  /// happens after [BeamerDelegate.setNewRoutePath].
  ///
  /// Override this if you are using custom state whose copying
  /// should be handled customly.
  ///
  /// See [update].
  void updateState(RouteInformation routeInformation) {
    state = createState(routeInformation);
  }

  /// Called after [initState] and on each [update],
  /// i.e. whenever we navigate with this [BeamStack].
  ///
  /// Useful for delegating some tasks that depend on navigation.
  void onUpdate() {}

  /// How to release any resources used by [state].
  ///
  /// Override this if
  /// e.g. using a custom [ChangeNotifier] [state] to remove listeners.
  @mustCallSuper
  void disposeState() {
    _isCurrent = false;
  }

  /// Updates the [state] and [history], depending on inputs.
  ///
  /// If [copy] function is provided, state should be created from given current [state].
  /// New [routeInformation] gets added to history.
  ///
  /// If [copy] is `null`, then [routeInformation] is used, either `null` or not.
  /// If [routeInformation] is `null`, then the state will upadate from
  /// last [history] element and nothing shall be added to [history].
  /// Else, the state updates from available [routeInformation].
  ///
  /// See [updateState] and [addToHistory].
  void update([
    T Function(T)? copy,
    RouteInformation? routeInformation,
    BeamParameters? beamParameters,
    bool rebuild = true,
    bool tryPoppingHistory = true,
  ]) {
    if (copy != null) {
      state = copy(state);
      addToHistory(
        state.routeInformation,
        beamParameters ?? const BeamParameters(),
        tryPoppingHistory,
      );
    } else {
      if (routeInformation == null) {
        updateState(history.last.routeInformation);
      } else if (routeInformation.uri == state.routeInformation.uri) {
        // if the new route information is the same as in the state it means
        // the state changed first and notified listeners, so updating it
        // will be unnecessary. Let's just add route to history with [tryPoppingHistory] set to true
        addToHistory(
          state.routeInformation,
          beamParameters ?? const BeamParameters(),
        );
      } else {
        updateState(routeInformation);
        addToHistory(
          state.routeInformation,
          beamParameters ?? const BeamParameters(),
          tryPoppingHistory,
        );
      }
    }
    onUpdate();
    if (rebuild) {
      notifyListeners();
    }
  }

  /// The history of beaming for this.
  final List<HistoryElement> history = [];

  /// Adds another [HistoryElement] to [history] list.
  /// The history element is created from given [state] and [beamParameters].
  ///
  /// If [tryPopping] is set to `true`, the state with the same `stack`
  /// will be searched in [history] and if found, entire history segment
  /// `[foundIndex, history.length-1]` will be removed before adding a new
  /// history element.
  void addToHistory(
    RouteInformation routeInformation, [
    BeamParameters beamParameters = const BeamParameters(),
    bool tryPopping = true,
  ]) {
    if (tryPopping) {
      final sameStateIndex = history.indexWhere((element) {
        return element.routeInformation.uri == state.routeInformation.uri;
      });
      if (sameStateIndex != -1) {
        history.removeRange(sameStateIndex, history.length);
      }
    }
    if (history.isEmpty ||
        routeInformation.uri != history.last.routeInformation.uri) {
      history.add(HistoryElement(routeInformation, beamParameters));
    }
  }

  /// Removes the last [HistoryElement] from [history] and returns it.
  HistoryElement? removeFirstFromHistory() {
    if (history.isEmpty) {
      return null;
    }
    return history.removeAt(0);
  }

  /// Removes the last [HistoryElement] from [history] and returns it.
  HistoryElement? removeLastFromHistory() {
    if (history.isEmpty) {
      return null;
    }
    return history.removeLast();
  }

  /// Initialize custom bindings for this [BeamStack] using [BuildContext].
  /// Similar to [builder], but is not tied to Widget tree.
  ///
  /// This will be called on just the first build of this [BeamStack]
  /// and sets [mounted] to true. It is called right before [buildPages].
  @mustCallSuper
  void buildInit(BuildContext context) {
    _mounted = true;
  }

  /// Can this handle the [uri] based on its [pathPatterns].
  ///
  /// Can be useful in a custom [BeamerDelegate.stackBuilder].
  bool canHandle(Uri uri) => Utils.canBeamStackHandleUri(this, uri);

  /// Gives the ability to wrap the [navigator].
  ///
  /// Mostly useful for providing something to the entire stack,
  /// i.e. to all of the pages.
  ///
  /// For example:
  ///
  /// ```dart
  /// @override
  /// Widget builder(BuildContext context, Widget navigator) {
  ///   return MyProvider<MyObject>(
  ///     create: (context) => MyObject(),
  ///     child: navigator,
  ///   );
  /// }
  /// ```
  Widget builder(BuildContext context, Widget navigator) => navigator;

  /// Represents the "form" of URI paths supported by this [BeamStack].
  ///
  /// You can pass in either a String or a RegExp. Beware of using greedy regular
  /// expressions as this might lead to unexpected behavior.
  ///
  /// For strings, optional path segments are denoted with ':xxx' and consequently
  /// `{'xxx': <real>}` will be put to `pathParameters`.
  /// For regular expressions we use named groups as optional path segments, following
  /// regex is tested to be effective in most cases `RegExp('/test/(?<test>[a-z]+){0,1}')`
  /// This will put `{'test': <real>}` to `pathParameters`. Note that we use the name from the regex group.
  ///
  /// Optional path segments can be used as a mean to pass data regardless of
  /// whether there is a browser.
  ///
  /// For example: '/books/:id' or using regex `RegExp('/test/(?<test>[a-z]+){0,1}')`
  List<Pattern> get pathPatterns;

  /// Whether [pathPatterns] are strictly matched agains incoming URI.
  ///
  /// If this is false (default), then a path pattern '/some/path' will match
  /// '/' and '/some' and '/some/path'.
  /// If this is true, then it will match just '/some/path'.
  bool get strictPathPatterns => false;

  /// Creates and returns the list of pages to be built by the [Navigator]
  /// when this [BeamStack] is beamed to or internally inferred.
  ///
  /// [context] can be useful while building the pages.
  /// It will also contain anything injected via [builder].
  List<BeamPage> buildPages(BuildContext context, T state);

  /// Guards that will be executing [BeamGuard.check] when this gets beamed to.
  ///
  /// Checks will be executed in order; chain of responsibility pattern.
  /// When some guard returns `false`, a candidate will not be accepted
  /// and stack of pages will be updated as is configured in [BeamGuard].
  ///
  /// Override this in your subclasses, if needed.
  /// See [BeamGuard].
  List<BeamGuard> get guards => const <BeamGuard>[];

  /// A transition delegate to be used by [Navigator].
  ///
  /// This will be used only by this stack, unlike
  /// [BeamerDelegate.transitionDelegate] that will be used for all stacks.
  ///
  /// This transition delegate will override the one in [BeamerDelegate].
  ///
  /// See [Navigator.transitionDelegate].
  TransitionDelegate? get transitionDelegate => null;
}

/// Default stack to choose if requested URI doesn't parse to any stack.
class NotFound extends BeamStack<BeamState> {
  /// Creates a [NotFound] [BeamStack] with
  /// `RouteInformation(uri: Uri.parse(path)` as its state.
  NotFound({String path = '/'})
      : super('NotFound', RouteInformation(uri: Uri.parse(path)));

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [];

  @override
  List<String> get pathPatterns => [];
}

/// Empty stack used to initialize a non-nullable BeamStack variable.
///
/// See [BeamerDelegate.currentBeamStack].
class EmptyBeamStack extends BeamStack<BeamState> {
  EmptyBeamStack() : super('EmptyBeamStack');

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [];

  @override
  List<String> get pathPatterns => [];
}

/// A specific single-page [BeamStack] for [BeamGuard.showPage]
class GuardShowPage extends BeamStack<BeamState> {
  /// Creates a [GuardShowPage] [BeamStack] with
  /// `RouteInformation(uri: Uri.parse(path)` as its state.
  GuardShowPage(
    this.routeInformation,
    this.beamPage,
  ) : super('GuardShowPage', routeInformation);

  /// [RouteInformation] to show in URL
  final RouteInformation routeInformation;

  /// A single page to show in stack.
  final BeamPage beamPage;

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) =>
      [beamPage];

  @override
  List<String> get pathPatterns => [routeInformation.uri.path];
}

/// A beam stack for [RoutesStackBuilder], but can be used freely.
///
/// Useful when needing a simple beam stack with a single or few pages.
class RoutesBeamStack extends BeamStack<BeamState> {
  /// Creates a [RoutesBeamStack] with specified properties.
  ///
  /// [routeInformation] and [routes] are required.
  RoutesBeamStack({
    required String debugLabel,
    required String creationReason,
    required RouteInformation routeInformation,
    Object? data,
    BeamParameters? beamParameters,
    required this.routes,
    this.navBuilder,
  }) : super(debugLabel, routeInformation, beamParameters) {
    print('RoutesBeamStack.constructor() -- $debugLabel -- $creationReason');
  }

  /// Map of all routes this stack handles.
  final Map<
      Pattern,
      dynamic Function(
        BuildContext,
        BeamState,
        // BeamPageNotifier,
        BeamPageNotifierReference,
        Object? data,
      )> routes;

  /// A wrapper used as [BeamStack.builder].
  final Widget Function(BuildContext context, Widget navigator)? navBuilder;

  /// They are regenerated on [buildPages],
  /// so they are only valid for one build cycle.
  ///
  /// The reason for not making them persistent across build cycles is that
  /// we can't know the [BeamPage.key] before creating them (see [buildPages]).
  final Map<LocalKey, BeamPageNotifier> _pageNotifiers = {};
  // final List<BeamPageNotifier> _pageNotifiers = [];
  // final Map<ValueKey, BeamPageNotifier> _pageNotifiers = {};

  @override
  Widget builder(BuildContext context, Widget navigator) {
    return navBuilder?.call(context, navigator) ?? navigator;
  }

  int _compareKeys(Pattern a, Pattern b) {
    if (a is RegExp && b is RegExp) {
      return a.pattern.length - b.pattern.length;
    }
    if (a is RegExp && b is String) {
      return a.pattern.length - b.length;
    }
    if (a is String && b is RegExp) {
      return a.length - b.pattern.length;
    }
    if (a is String && b is String) {
      return a.length - b.length;
    }
    return 0;
  }

  @override
  List<Pattern> get pathPatterns => routes.keys.toList();

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    // _printCurrentPageNotifiers('buildPages');

    final filteredRoutes = chooseRoutes(state.routeInformation, routes.keys);
    final routeBuilders = Map.of(routes)
      ..removeWhere((key, value) => !filteredRoutes.containsKey(key));
    final sortedRoutes = routeBuilders.keys.toList()
      ..sort((a, b) => _compareKeys(a, b));
    final pages = sortedRoutes.indexed.map<BeamPage>((value) {
      final index = value.$1;
      final route = value.$2;
      final notifierReference = BeamPageNotifierReference();
      final routeElement =
          routes[route]!(context, state, notifierReference, data);
      final page = routeElement is BeamPage
          ? routeElement
          : BeamPage(
              key: ValueKey(filteredRoutes[route]),
              child: routeElement,
            );
      print('Notifier exists: ${_pageNotifiers.containsKey(page.key)}');
      final notifier = _pageNotifiers[page.key] ??= BeamPageNotifier(
        BeamPageState(isPinnacle: index == sortedRoutes.length - 1),
        parentStackDebugLabel: debugLabel,
      );
      notifierReference.getNotifier = () => notifier;
      return page;
    }).toList();
    return pages;
  }

  /// Chooses all the routes that "sub-match" [routeInformation] to stack their
  /// pages.
  ///
  /// If [routeInformation] doesn't match any of the [routes], nothing will be
  /// selected and [BeamerDelegate] will declare that the stack is
  /// [NotFound].
  static Map<Pattern, String> chooseRoutes(
    RouteInformation routeInformation,
    Iterable<Pattern> routes,
  ) {
    String createMatch(String path, Map<String, String> queryParameters) => Uri(
          path: path == '' ? '/' : path,
          queryParameters: queryParameters.isEmpty ? null : queryParameters,
        ).toString();

    final matched = <Pattern, String>{};
    var overrideNotFound = false;
    final uri = Utils.removeTrailingSlash(routeInformation.uri);

    for (final route in routes) {
      if (route is String) {
        if (uri.path.isEmpty) {
          continue;
        }

        if (route.startsWith('/') && !uri.path.startsWith('/')) {
          continue;
        }

        if (route == '*') {
          matched[route] = createMatch(uri.path, uri.queryParameters);
          overrideNotFound = true;
          continue;
        }

        if (route == '/*' && uri.path == '/') {
          matched[route] = createMatch(uri.path, uri.queryParameters);
          overrideNotFound = true;
          continue;
        }

        final uriPathSegments = uri.pathSegments.toList();
        final routePathSegments = Uri.parse(route).pathSegments;

        if (uriPathSegments.length < routePathSegments.length) {
          continue;
        }

        var checksPassed = true;
        var path = '';
        for (var i = 0; i < routePathSegments.length; i++) {
          path += '/${uriPathSegments[i]}';

          if (routePathSegments[i] == '*') {
            if (i == routePathSegments.length - 1) {
              path = uri.path;
              overrideNotFound = true;
              break;
            }
            continue;
          }
          if (routePathSegments[i].startsWith(':')) {
            continue;
          }
          if (routePathSegments[i] != uriPathSegments[i]) {
            checksPassed = false;
            break;
          }
        }

        if (checksPassed) {
          matched[route] = createMatch(path, uri.queryParameters);
        }
      } else {
        final regexp = Utils.tryCastToRegExp(route);
        if (regexp.hasMatch(uri.toString())) {
          final path = uri.toString();
          matched[regexp] = createMatch(path, uri.queryParameters);
        }
      }
    }

    var isNotFound = true;
    matched.forEach((key, value) {
      if (Utils.urisMatch(key, uri)) {
        isNotFound = false;
      }
    });

    if (overrideNotFound) {
      return matched;
    }

    return isNotFound ? {} : matched;
  }

  void notifyPages(List<BeamPage> pages) {
    // _printCurrentPageNotifiers('notifyPages');

    // Hidden pages
    for (int i = 0; i < pages.length - 1; i++) {
      print('Notifying page: ${pages[i].title} -- Is pinnacle: false');
      _pageNotifiers[pages[i].key]!
        ..value = BeamPageState(isPinnacle: false)
        ..notify();
    }

    // Pinnacle page
    print('Notifying page: ${pages.last.title} -- Is pinnacle: true');
    _pageNotifiers[pages.last.key]!
      ..value = BeamPageState(isPinnacle: true)
      ..notify();
  }

  /// Returns current notifiers and clean them up.
  List<BeamPageNotifier> getPageNotifiers() {
    return [..._pageNotifiers.values];
    // final notifiers = [..._pageNotifiers.values];
    // _pageNotifiers.clear();
    // return notifiers;
  }

  // void _printCurrentPageNotifiers(String debugLabel) {
  //   print('_printCurrentPageNotifiers() -- ${this.debugLabel} -- $debugLabel');
  //   for (final entry in _pageNotifiers.entries) {
  //     print('LocalKey: ${entry.key}, Notifier: ${entry.value.fullDebugLabel}');
  //   }
  // }
}
