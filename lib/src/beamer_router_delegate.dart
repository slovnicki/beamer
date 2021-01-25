import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:beamer/src/beam_location.dart';

class BeamerRouterDelegate extends RouterDelegate<BeamLocation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BeamLocation> {
  BeamerRouterDelegate({
    @required BeamLocation initialLocation,
    @required List<BeamLocation> beamLocations,
    Widget notFoundPage,
  })  : _navigatorKey = GlobalKey<NavigatorState>(),
        _beamLocations = beamLocations,
        _currentLocation = initialLocation..prepare(),
        _previousLocation = null,
        notFoundPage = notFoundPage ?? Container() {
    _currentPages = _currentLocation.pages;
  }

  final GlobalKey<NavigatorState> _navigatorKey;

  /// A [List] of all available [BeamLocation]s in the [Router]'s scope.
  final List<BeamLocation> _beamLocations;
  final notFoundPage;

  BeamLocation _currentLocation;
  List<BeamPage> _currentPages;
  BeamLocation _previousLocation;

  /// Updates the [currentConfiguration]
  /// and rebuilds the [Navigator] to contain the [location.pages] stack of pages.
  ///
  /// Also remembers the previous location so we can beam back.
  void beamTo(BeamLocation location) {
    _update(location);
    notifyListeners();
  }

  /// Beams to previous location.
  void beamBack() {
    beamTo(_previousLocation);
  }

  @override
  BeamLocation get currentConfiguration => _currentLocation;

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  void _update(BeamLocation location) {
    _previousLocation = _currentLocation;
    _currentLocation = location..prepare();
    _currentPages = _currentLocation.pages;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: currentConfiguration is NotFound
          ? [BeamPage(page: notFoundPage)]
          : _currentPages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        final keepPathParameters = _currentPages.last.keepPathParametersOnPop;
        _currentPages.removeLast();
        final location = _matchPages(keepPathParameters);
        if (location != null) {
          _previousLocation = _currentLocation;
          _currentLocation = location..prepare();
          notifyListeners();
        }
        return true;
      },
    );
  }

  @override
  SynchronousFuture<void> setNewRoutePath(BeamLocation location) {
    _update(location);
    return SynchronousFuture(null);
  }

  /// Finds the [BeamLocation] that has the same stack of pages as current.
  ///
  /// Used in [Navigator.onPopPage] to determine whether the pop resulted
  /// in "implicit beam" to a known location for which the URL can be updated.
  ///
  /// For this comparison, parameters are ignored as they can influence pages
  /// lists that use collection-if on parameters. Until a better solution.
  BeamLocation _matchPages(bool keepPathParameters) {
    for (var location in _beamLocations) {
      if (keepPathParameters) {
        location.pathParameters = _currentLocation.pathParameters;
      } else {
        location.pathParameters = {};
      }
      if (location.pages.length != _currentPages.length) {
        continue;
      }
      var found = true;
      for (var i = 0; i < location.pages.length; i++) {
        if (location.pages[i] != _currentPages[i]) {
          found = false;
          break;
        }
      }
      if (found == true) {
        return location;
      }
    }

    return null;
  }
}
