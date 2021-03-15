import 'package:beamer/beamer.dart';
import 'package:beamer/src/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A delegate that is used by the [Router] widget
/// to build and configure a navigating widget.
class BeamerRouterDelegate extends RouterDelegate<Uri>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<Uri> {
  BeamerRouterDelegate({
    @required this.beamLocations,
    this.preferUpdate = true,
    this.removeDuplicateHistory = true,
    BeamPage notFoundPage,
    this.notFoundRedirect,
    this.guards = const <BeamGuard>[],
    this.navigatorObservers = const <NavigatorObserver>[],
  })  : _navigatorKey = GlobalKey<NavigatorState>(),
        _currentLocation = beamLocations[0]..prepare(),
        notFoundPage = notFoundPage ?? BeamPage(child: Container()) {
    _beamHistory.add(_currentLocation);
  }

  /// List of all [BeamLocation]s that this router handles.
  final List<BeamLocation> beamLocations;

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
  final BeamPage notFoundPage;

  /// [BeamLocation] to redirect to when no [BeamLocation] supports the incoming URI.
  final BeamLocation notFoundRedirect;

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

  /// Whether to implicitly [beamBack] instead of default pop
  bool _beamBackOnPop = false;

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
  void beamTo(
    BeamLocation location, {
    bool beamBackOnPop = false,
    bool stacked = true,
  }) {
    _beamBackOnPop = beamBackOnPop;
    _stacked = stacked;
    if (preferUpdate && location.runtimeType == _currentLocation.runtimeType) {
      _beamHistory.removeLast();
    }
    if (removeDuplicateHistory) {
      _beamHistory.removeWhere((l) => l.runtimeType == location.runtimeType);
    }
    _beamHistory.add(location..prepare());
    _currentLocation = _beamHistory.last;
    notifyListeners();
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
  /// `data` can be used to pass any data throught the location.
  /// See [BeamLocation.data].
  void beamToNamed(
    String uri, {
    Map<String, dynamic> data = const <String, dynamic>{},
    bool beamBackOnPop = false,
    bool stacked = true,
  }) {
    final location = Utils.chooseBeamLocation(Uri.parse(uri), beamLocations);
    location.data = data;
    beamTo(location, beamBackOnPop: beamBackOnPop, stacked: stacked);
  }

  /// Whether it is possible to [beamBack],
  /// i.e. there is more than 1 location in [beamHistory].
  bool get canBeamBack => _beamHistory.length > 1;

  /// What is the location to which [beamBack] will lead.
  /// If there is none, returns null.
  BeamLocation get beamBackLocation =>
      canBeamBack ? _beamHistory[_beamHistory.length - 2] : null;

  /// Beams to previous location in [beamHistory]
  /// and **removes** the last location from history.
  ///
  /// If there is no previous location, does nothing.
  ///
  /// Returns the success, whether the [currentLocation] was changed.
  bool beamBack() {
    _beamBackOnPop = false;
    _stacked = true;
    if (!canBeamBack) {
      return false;
    }
    _beamHistory.removeLast();
    _currentLocation = _beamHistory.last;
    notifyListeners();
    return true;
  }

  /// Updates [currentLocation] and notifies listeners.
  ///
  /// See [BeamLocation.update] for details.
  ///
  /// If `beamBackOnPop` is not specified, [_beamBackOnPop] will be reset to `false`.
  /// If `stacked` is not specified, [_stacked] will remain as it was.
  void updateCurrentLocation({
    String pathBlueprint,
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Map<String, dynamic> data = const <String, dynamic>{},
    bool rewriteParameters = false,
    bool beamBackOnPop,
    bool stacked,
  }) {
    _beamBackOnPop = beamBackOnPop ?? false;
    _stacked = stacked ?? _stacked;
    _currentLocation.update(
      pathBlueprint: pathBlueprint,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      data: data,
      rewriteParameters: rewriteParameters,
    );
    _currentLocation.prepare();
    notifyListeners();
  }

  @override
  Uri get currentConfiguration => _currentLocation.uri;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  @override
  Widget build(BuildContext context) {
    final BeamGuard guard = _guardCheck(context, _currentLocation);
    if (guard?.beamTo != null) {
      _beamHistory.add(guard.beamTo(context)..prepare());
      _currentLocation = _beamHistory.last;
    } else if ((_currentLocation is NotFound) && notFoundRedirect != null) {
      _currentLocation = notFoundRedirect..prepare();
    }
    final navigator = Builder(
      builder: (context) {
        _currentPages = _stacked
            ? _currentLocation.pagesBuilder(context)
            : [_currentLocation.pagesBuilder(context).last];
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
            if (_beamBackOnPop) {
              beamBack();
              _beamBackOnPop = false;
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
  SynchronousFuture<void> setNewRoutePath(Uri uri) {
    beamTo(Utils.chooseBeamLocation(uri, beamLocations));
    return SynchronousFuture(null);
  }

  void _handlePop(BeamPage page) {
    final pathSegments = List<String>.from(_currentLocation.pathSegments);
    final pathSegment = pathSegments.removeLast();
    _currentLocation.pathSegments = pathSegments;
    if (pathSegment[0] == ':') {
      _currentLocation.pathParameters.remove(pathSegment.substring(1));
    }
    if (!page.keepQueryOnPop) {
      _currentLocation.queryParameters = {};
    }
    _currentLocation.prepare();
    notifyListeners();
  }

  BeamGuard _guardCheck(BuildContext context, BeamLocation location) {
    for (var guard in guards) {
      if (guard.shouldGuard(location) && !guard.check(context, location)) {
        guard.onCheckFailed?.call(context, location);
        return guard;
      }
    }
    for (var guard in location.guards) {
      if (guard.shouldGuard(location) && !guard.check(context, location)) {
        guard.onCheckFailed?.call(context, location);
        return guard;
      }
    }
    return null;
  }
}
