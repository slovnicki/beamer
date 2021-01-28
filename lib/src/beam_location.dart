import 'package:beamer/src/beam_page.dart';

abstract class BeamLocation {
  BeamLocation({
    String path,
    Map<String, String> pathParameters,
    Map<String, String> queryParameters,
    Map<String, dynamic> data,
  })  : pathSegments =
            path != null ? List.from(Uri.parse(path).pathSegments) : <String>[],
        pathParameters = pathParameters ?? <String, String>{},
        queryParameters = queryParameters ?? <String, String>{},
        data = data ?? <String, dynamic>{};

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
  List<String> get pathBlueprints;

  /// The list of pages to be built by the [Navigator] when this [BeamLocation]
  /// is beamed to or internally inferred.
  List<BeamPage> get pages;

  /// Will be executed before [pages] are drawn onto screen.
  void Function() executeBefore = () => {};

  List<String> pathSegments;

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

  Map<String, dynamic> data;

  /// Complete URI of this [BeamLocation], with path and query parameters.
  ///
  /// If the [BeamLocation] hasn't been used yet, [uri] will be [pathBlueprint].
  String get uri => (_path ?? '') + _query;

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
    final realizedPathSegments = List.from(pathSegments);
    pathParameters.forEach((key, value) {
      var index = realizedPathSegments.indexWhere(
          (segment) => segment[0] == ':' && segment.substring(1) == key);
      if (index != -1) {
        realizedPathSegments[index] = value;
      }
    });
    _path = '/' + realizedPathSegments.join('/');
  }
}

class NotFound extends BeamLocation {
  @override
  List<BeamPage> get pages => [];

  @override
  List<String> get pathBlueprints => ['404'];
}
