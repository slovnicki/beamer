import 'package:beamer/beamer.dart';

/// Configuration for a navigatable application region.
///
/// Extend this class to define your locations to which you can then `beamTo`.
abstract class BeamLocation {
  BeamLocation({
    String pathBlueprint,
    Map<String, String> pathParameters,
    Map<String, String> queryParameters,
    Map<String, dynamic> data,
    this.executeBefore,
  })  : pathSegments = pathBlueprint != null
            ? List.from(Uri.parse(pathBlueprint).pathSegments)
            : <String>[],
        pathParameters = pathParameters ?? <String, String>{},
        queryParameters = queryParameters ?? <String, String>{},
        data = data ?? <String, dynamic>{};

  /// Represents the "form" of URI paths supported by this [BeamLocation].
  ///
  /// Optional path segments are denoted with ':xxx' and consequently
  /// `{'xxx': <real>}` will be put to [pathParameters] by
  /// [BeamerRouteInformationParser] upon receiving the real path from browser.
  ///
  /// Optional path segments can be used as a mean to pass data regardless of
  /// whether there is a browser.
  ///
  /// For example: '/books/:id'.
  List<String> get pathBlueprints;

  /// The list of pages to be built by the [Navigator] when this [BeamLocation]
  /// is beamed to or internally inferred.
  List<BeamPage> get pages;

  /// Guards that will be executing [check] when this gets beamed to.
  ///
  /// Checks will be executed in order; chain of responsibility pattern.
  /// When some guard returns `false`, location will not be accepted
  /// and stack of pages will be updated as is configured in [BeamGuard].
  ///
  /// Override this in your subclasses, if needed.
  List<BeamGuard> get guards => const <BeamGuard>[];

  /// Will be executed before [pages] are drawn onto screen.
  void Function() executeBefore;

  List<String> pathSegments;

  String get pathBlueprint => '/' + pathSegments.join('/');

  /// Path parameters extracted from URI.
  ///
  /// For example, if [pathBlueprint] is '/books/:id',
  /// and incoming URI '/books/1', then [pathParameters] will be `{'id': '1'}`.
  Map<String, String> pathParameters;

  /// Query parameters extracted from URI.
  ///
  /// For example, if incoming URI '/books?title=stranger',
  /// then [queryParameters] will be `{'title': 'stranger'}`.
  Map<String, String> queryParameters;

  /// Used for passing any custom data to [BeamLocation].
  Map<String, dynamic> data;

  /// Complete URI of this [BeamLocation], with path and query parameters.
  String get uri => _path + _query;

  String _path;
  String _query;

  /// Recreates the [uri] for this [BeamLocation]
  /// considering current value of [pathParameters] and [queryParameters].
  ///
  /// Calls [executeBefore] if defined.
  void prepare() {
    _makePath();
    _makeQuery();
    executeBefore?.call();
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
  NotFound({
    String path,
  }) : super(pathBlueprint: path);

  @override
  List<BeamPage> get pages => [];

  @override
  List<String> get pathBlueprints => [''];
}
