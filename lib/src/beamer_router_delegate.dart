import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:beamer/src/beam_location.dart';

class BeamerRouterDelegate extends RouterDelegate<BeamLocation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BeamLocation> {
  BeamerRouterDelegate({
    @required BeamLocation initialLocation,
    @required List<BeamLocation> beamLocations,
  })  : _navigatorKey = GlobalKey<NavigatorState>(),
        _beamLocations = beamLocations,
        _currentLocation = initialLocation..prepare(),
        _pages = initialLocation.pages,
        _previousLocation = null;

  final GlobalKey<NavigatorState> _navigatorKey;

  /// A [List] of all available [BeamLocation]s in the [Router]'s scope.
  final List<BeamLocation> _beamLocations;

  BeamLocation _currentLocation;
  List<Page> _pages;
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
    _pages = _currentLocation.pages;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _pages,
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }
        _pages.removeAt(_pages.length - 1);
        final location = _matchPages();
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
  /// Used in [Navigator.onPopPage] to determine whether the pop resulted
  /// in "implicit beam" to a known location for which the URL can be updated.
  BeamLocation _matchPages() {
    for (var location in _beamLocations) {
      if (location.pages.length != _pages.length) {
        continue;
      }
      var found = true;
      for (var i = 0; i < location.pages.length; i++) {
        if (location.pages[i] != _pages[i]) {
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
