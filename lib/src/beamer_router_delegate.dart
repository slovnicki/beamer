import 'package:flutter/widgets.dart';

import 'package:beamer/src/beam_location.dart';

class BeamerRouterDelegate extends RouterDelegate<BeamLocation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BeamLocation> {
  BeamerRouterDelegate({
    @required BeamLocation initialLocation,
  })  : navigatorKey = GlobalKey<NavigatorState>(),
        _currentLocation = initialLocation..prepare(),
        _previousLocation = null;

  final GlobalKey<NavigatorState> navigatorKey;
  BeamLocation _currentLocation;
  BeamLocation _previousLocation;
  List<int> _removePagesAt = [];
  bool _removeLast = false;

  void beamTo(BeamLocation location) {
    _previousLocation = _currentLocation;
    _currentLocation = location..prepare();
    _removePagesAt = [];
    _removeLast = false;
    notifyListeners();
  }

  void beamBack() {
    this.beamTo(_previousLocation);
  }

  List<Page> _createPages() {
    List<Page> currentPages = _currentLocation.pages;
    for (int index in _removePagesAt) {
      currentPages.removeAt(index);
    }
    if (_removeLast) {
      currentPages.removeAt(currentPages.length - 1);
    }
    return currentPages;
  }

  @override
  BeamLocation get currentConfiguration => _currentLocation;

  @override
  Widget build(BuildContext context) {
    print('building ${_currentLocation.uri}');
    return Navigator(
      key: navigatorKey,
      pages: _createPages(),
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
        this._removeLast = true;
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(BeamLocation location) async {
    _currentLocation = location..prepare();
  }
}
