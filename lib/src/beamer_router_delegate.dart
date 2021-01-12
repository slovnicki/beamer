import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:beamer/src/beam_location.dart';

class BeamerRouterDelegate extends RouterDelegate<BeamLocation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BeamLocation> {
  BeamerRouterDelegate({
    @required BeamLocation initialLocation,
  })  : _navigatorKey = GlobalKey<NavigatorState>(),
        _currentLocation = initialLocation..prepare(),
        _previousLocation = null {
    _pages = _currentLocation.pages;
  }

  final GlobalKey<NavigatorState> _navigatorKey;
  BeamLocation _currentLocation;
  List<Page> _pages;
  BeamLocation _previousLocation;

  void beamTo(BeamLocation location) {
    _update(location);
    notifyListeners();
  }

  void beamBack() {
    this.beamTo(_previousLocation);
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
    print('building ${_currentLocation.uri}');
    return Navigator(
      key: navigatorKey,
      pages: _pages,
      onPopPage: (route, result) {
        print('entering onPopPage');
        if (!route.didPop(result)) {
          return false;
        }
        print('onPopPage didPop');
        if (_currentLocation.popLocation != null) {
          this.beamTo(_currentLocation.popLocation);
          print('onPopPage didBeam');
          return true;
        }
        if (_currentLocation.popToPrevious && _previousLocation != null) {
          this.beamTo(_previousLocation);
          print('beamTo previous: ' + _previousLocation.pathBlueprint);
          return true;
        }
        _pages.removeAt(_pages.length - 1);
        return true;
      },
    );
  }

  @override
  SynchronousFuture<void> setNewRoutePath(BeamLocation location) {
    _update(location);
    return SynchronousFuture(null);
  }
}
