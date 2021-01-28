import 'package:beamer/src/beam_page.dart';

abstract class BeamLocation {
  BeamLocation({
    pathParameters,
    queryParameters,
  })  : pathParameters = pathParameters ?? const <String, String>{},
        queryParameters = queryParameters ?? const <String, String>{};

  /// Represents the form of URI path for this [BeamLocation].
  ///
  /// Optional path segments are denoted with ':xxx' and consequently
  /// `{'xxx': <real>}` will be put to [pathParameters] by
  /// [BeamerRouteInformationParser] upon receiving the real path from browser.
  ///
  /// Optional path segments can be used as a mean to pass data regardless of
  /// whether there is a browser.
  ///
  /// For example: '/books/:id'
  String get pathBlueprint;

  /// The list of pages to be built by the [Navigator] when this [BeamLocation]
  /// is beamed to or internally inferred.
  List<BeamPage> get pages;

  /// Will be executed before [pages] are drawn onto screen.
  void Function() executeBefore = () => {};

  /// Path parameters extracted from URI
  ///
  /// For example, if [pathBlueprint] is '/books/:id',
  /// and incoming URI '/books/1', then [pathParameters] will be `{'id': '1'}`.
  Map<String, String> pathParameters;

  /// Query parameters extracted from URI
  ///
  /// For example, if incoming URI '/books?title=stranger',
  /// then [queryParameters] will be `{'title': 'stranger'}`.
  Map<String, String> queryParameters;

  /// Complete URI of this [BeamLocation], with path and query parameters.
  ///
  /// If the [BeamLocation] hasn't been used yet, [uri] will be [pathBlueprint].
  String get uri => (_path ?? pathBlueprint) + _query;

  String _path;
  String _query;

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
    final queryString = Uri(queryParameters: queryParameters).query;
    _query = queryString.isNotEmpty ? '?' + queryString : '';
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
}

class NotFound extends BeamLocation {
  @override
  List<BeamPage> get pages => [];

  @override
  String get pathBlueprint => '404';
}
