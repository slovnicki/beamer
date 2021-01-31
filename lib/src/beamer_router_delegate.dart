import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'package:beamer/src/beam_location.dart';

class BeamerRouterDelegate extends RouterDelegate<BeamLocation>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BeamLocation> {
  BeamerRouterDelegate({
    @required BeamLocation initialLocation,
    Widget notFoundPage,
  })  : _navigatorKey = GlobalKey<NavigatorState>(),
        _currentLocation = initialLocation..prepare(),
        _previousLocation = null,
        notFoundPage = notFoundPage ?? Container() {
    _currentPages = _currentLocation.pages;
  }

  final GlobalKey<NavigatorState> _navigatorKey;

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

  void updateCurrentLocation({
    @required String path,
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Map<String, dynamic> data = const <String, dynamic>{},
    bool rewriteParameters = false,
  }) {
    _currentLocation.pathSegments = List.from(Uri.parse(path).pathSegments);
    if (rewriteParameters) {
      _currentLocation.pathParameters = Map.from(pathParameters);
    } else {
      pathParameters.forEach((key, value) {
        _currentLocation.pathParameters[key] = value;
      });
    }
    if (rewriteParameters) {
      _currentLocation.queryParameters = Map.from(queryParameters);
    } else {
      queryParameters.forEach((key, value) {
        _currentLocation.queryParameters[key] = value;
      });
    }
    if (rewriteParameters) {
      _currentLocation.data = Map.from(data);
    } else {
      data.forEach((key, value) {
        _currentLocation.data[key] = value;
      });
    }
    _currentLocation.prepare();
    _currentPages = _currentLocation.pages;
    notifyListeners();
  }

  BeamLocation get currentLocation => currentConfiguration;

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
          ? [BeamPage(pathSegment: '', page: notFoundPage)]
          : _currentPages,
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
    _update(location);
    return SynchronousFuture(null);
  }

  void _handlePop(BeamPage page) {
    if (page.pathSegment[0] == ':') {
      _currentLocation.pathParameters.remove(page.pathSegment.substring(1));
    }
    _currentLocation.pathSegments.remove(page.pathSegment);
    if (!page.keepQueryOnPop) {
      _currentLocation.queryParameters = {};
    }
    _currentLocation.prepare();
    _currentPages = _currentLocation.pages;
    notifyListeners();
  }
}
