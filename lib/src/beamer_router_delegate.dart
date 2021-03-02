import 'package:back_button_interceptor/back_button_interceptor.dart';
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
    BeamPage notFoundPage,
    this.guards = const <BeamGuard>[],
    this.navigatorObservers = const <NavigatorObserver>[],
  })  : _navigatorKey = GlobalKey<NavigatorState>(),
        _currentLocation = beamLocations[0]..prepare(),
        notFoundPage = notFoundPage ?? BeamPage(child: Container()) {
    if (!kIsWeb) {
      BackButtonInterceptor.add(backInterceptor, name: 'BeamerInterceptor');
    }
  }

  /// List of all [BeamLocation]s that this router handles.
  final List<BeamLocation> beamLocations;

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
  bool _beamBackOnPop;

  /// Beams to `location`.
  ///
  /// Specifically,
  ///
  /// 1. adds the prepared `location` to [beamHistory]
  /// 2. updates [currentLocation]
  /// 3. notifies that the [Navigator] should be rebuilt
  ///
  /// if `beamBackOnPop` is set to `true`, default pop action on the newly
  /// beamed location will triger `beamBack` instead.
  void beamTo(BeamLocation location, {bool beamBackOnPop = false}) {
    _beamBackOnPop = beamBackOnPop;
    _beamHistory.add(location..prepare());
    _currentLocation = _beamHistory.last;
    notifyListeners();
  }

  /// Beams to [BeamLocation] that handles `uri`.
  ///
  /// See [beamTo].
  void beamToNamed(String uri, {bool beamBackOnPop = false}) {
    final location = Utils.chooseBeamLocation(Uri.parse(uri), beamLocations);
    beamTo(location);
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
  /// Note that [_beamBackOnPop] will be reset to `false`.
  void updateCurrentLocation({
    String pathBlueprint,
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Map<String, dynamic> data = const <String, dynamic>{},
    bool rewriteParameters = false,
  }) {
    _beamBackOnPop = false;
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
      beamTo(guard.beamTo(context));
    }
    final navigator = Builder(
      builder: (context) {
        _currentPages = _currentLocation.pagesBuilder(context);
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
    final pathSegment = _currentLocation.pathSegments.removeLast();
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

  @override
  void dispose() {
    BackButtonInterceptor.removeByName('BeamerInterceptor');
    super.dispose();
  }

  bool backInterceptor(bool stopDefaultButtonEvent, RouteInfo info) {
    if (_currentPages.length == 1) {
      return beamBack();
    }
    return false;
  }
}
