import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A delegate that is used by the [Router] widget
/// to build and configure a navigating widget.
class BeamerRouterDelegate extends RouterDelegate<BeamLocation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BeamLocation> {
  BeamerRouterDelegate({
    @required BeamLocation initialLocation,
    BeamPage notFoundPage,
    this.guards = const <BeamGuard>[],
    this.navigatorObservers = const <NavigatorObserver>[],
  })  : _navigatorKey = GlobalKey<NavigatorState>(),
        notFoundPage = notFoundPage ?? BeamPage(child: Container()) {
    _beamHistory.add(initialLocation..prepare());
    _currentLocation = _beamHistory[0];
    _currentPages = _currentLocation.pages;
  }

  /// Page to show when no [BeamLocation] supports the incoming URI.
  final BeamPage notFoundPage;

  /// Guards that will be executing [check] on [currentLocation] candidate.
  ///
  /// Checks will be executed in order; chain of responsibility pattern.
  /// When some guard returns `false`, location candidate will not be accepted
  /// and stack of pages will be updated as is configured in [BeamGuard].
  final List<BeamGuard> guards;

  /// The list of observers for the [Navigator] created for this app.
  final List<NavigatorObserver> navigatorObservers;

  final GlobalKey<NavigatorState> _navigatorKey;

  final List<BeamLocation> _beamHistory = [];

  /// The history of beaming.
  List<BeamLocation> get beamHistory => _beamHistory;

  BeamLocation _currentLocation;

  /// Access the current [BeamLocation].
  ///
  /// The same thing as [currentConfiguration], but with more familiar name.
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

  List<BeamPage> _currentPages;

  /// Current location's effective pages.
  List<BeamPage> get currentPages => _currentPages;

  /// Beams to `location`.
  ///
  /// Specifically,
  ///
  /// 1. adds the prepared `location` to [beamHistory]
  /// 2. updates [currentLocation] and [currentPages]
  /// 3. notifies that the [Navigator] should be rebuilt
  void beamTo(BeamLocation location) {
    _beamHistory.add(location..prepare());
    _updateCurrent();
    notifyListeners();
  }

  /// Beams to previous location in [beamHistory]
  /// and **removes** the last location from history.
  ///
  /// If there is no previous location, does nothing.
  ///
  /// Returns the success, whether the [currentLocation] was changed.
  bool beamBack() {
    if (_beamHistory.length == 1) {
      return false;
    }
    _beamHistory.removeLast();
    _updateCurrent();
    notifyListeners();
    return true;
  }

  /// Updates [currentLocation] and notifies listeners.
  ///
  /// See [BeamLocation.update] for details.
  void updateCurrentLocation({
    @required String pathBlueprint,
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Map<String, dynamic> data = const <String, dynamic>{},
    bool rewriteParameters = false,
  }) {
    _currentLocation.update(
      pathBlueprint: pathBlueprint,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      data: data,
      rewriteParameters: rewriteParameters,
    );
    _currentLocation.prepare();
    _currentPages = _currentLocation.pages;
    notifyListeners();
  }

  @override
  BeamLocation get currentConfiguration => _currentLocation;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  Widget build(BuildContext context) {
    final BeamGuard guard = _guardCheck(context, _currentLocation);
    if (guard?.beamTo != null) {
      beamTo(guard.beamTo(context));
    }
    return Navigator(
      key: navigatorKey,
      observers: navigatorObservers,
      pages: _currentLocation is NotFound
          ? [notFoundPage]
          : guard == null || guard?.beamTo != null
              ? _currentPages
              : [guard.showPage],
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        final lastPage = _currentPages.removeLast();
        if (lastPage is BeamPage) {
          _handlePop(lastPage);
        }
        return true;
      },
    );
  }

  @override
  SynchronousFuture<void> setNewRoutePath(BeamLocation location) {
    beamTo(location);
    return SynchronousFuture(null);
  }

  void _updateCurrent() {
    _currentLocation = _beamHistory.last;
    _currentPages = _currentLocation.pages;
  }

  void _handlePop(BeamPage page) {
    final pathSegment = _currentLocation.pathSegments.removeLast();
    if (pathSegment[0] == ':') {
      _currentLocation.pathParameters.remove(pathSegment.substring(1));
    }
    if (!page.keepQueryOnPop) {
      _currentLocation.queryParameters = {};
    }
    _currentLocation.prepare();
    _currentPages = _currentLocation.pages;
    notifyListeners();
  }

  BeamGuard _guardCheck(BuildContext context, BeamLocation location) {
    for (var guard in guards) {
      if (guard.shouldGuard(location) && !guard.check(context, location)) {
        return guard;
      }
    }
    for (var guard in location.guards) {
      if (guard.shouldGuard(location) && !guard.check(context, location)) {
        return guard;
      }
    }
    return null;
  }
}
