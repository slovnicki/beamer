import 'package:beamer/src/beam_page.dart';

abstract class BeamLocation {
  BeamLocation();

  BeamLocation.withParameters({
    Map<String, String> path,
    Map<String, String> query,
  })  : pathParameters = path ?? {},
        queryParameters = query ?? {};

  Map<String, String> queryParameters = {};
  Map<String, String> pathParameters = {};
  String _path;
  String _query;

  String get uri => (_path ?? pathBlueprint) + (_query ?? '');

  /// Recreates the [uri] for this [BeamLocation]
  /// considering current value of [pathParameters] and [queryParameters].
  ///
  /// Calls [executeBefore].
  void prepare() {
    _makePath();
    _makeQuery();
    executeBefore.call();
  }

  void _makeQuery() {
    if (queryParameters.isEmpty) {
      _query = '';
    }
    var result = '?';
    queryParameters.forEach((key, value) {
      result += key + '=' + value + '&';
    });
    _query = result.substring(0, result.length - 1);
  }

  void _makePath() {
    var pathSegments = Uri.parse(pathBlueprint).pathSegments;
    pathSegments = List.from(pathSegments);
    if (pathParameters.isEmpty) {
      pathSegments.removeWhere((segment) => segment[0] == ':');
      _path = '/' + pathSegments.join('/');
    }
    pathParameters.forEach((key, value) {
      var index = pathSegments.indexWhere(
          (segment) => segment[0] == ':' && segment.substring(1) == key);
      if (index != -1) {
        pathSegments[index] = value;
      }
    });
    _path = '/' + pathSegments.join('/');
  }

  String get pathBlueprint;
  List<BeamPage> get pages;
  void Function() executeBefore = () => {};
}

class NotFound extends BeamLocation {
  @override
  List<BeamPage> get pages => [];

  @override
  String get pathBlueprint => '404';
}
