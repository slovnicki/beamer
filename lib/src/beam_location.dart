import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

/// Configuration for a navigatable application region.
///
/// Extend this class to define your locations to which you can then `beamTo`.
abstract class BeamLocation {
  BeamLocation({
    String? pathBlueprint,
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? data,
    this.executeBefore,
  })  : pathSegments = pathBlueprint != null
            ? List.from(Uri.parse(pathBlueprint).pathSegments)
            : <String>[],
        pathParameters = pathParameters ?? <String, String>{},
        queryParameters = queryParameters ?? <String, String>{},
        data = data ?? <String, dynamic>{};

  /// Gives the ability to wrap the `navigator`.
  ///
  /// Mostly useful for providing something to the entire location,
  /// i.e. to all of the [pages].
  ///
  /// For example:
  ///
  /// ```dart
  /// @override
  /// Widget builder(BuildContext context, Widget navigator) {
  ///   return MyProvider<MyObject>(
  ///     create: (context) => MyObject(),
  ///     child: navigator,
  ///   );
  /// }
  /// ```
  Widget builder(BuildContext context, Widget navigator) => navigator;

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

  /// Creates and returns the list of pages to be built by the [Navigator]
  /// when this [BeamLocation] is beamed to or internally inferred.
  ///
  /// `context` can be useful while building the pages.
  /// It will also contain anything injected via [builder].
  List<BeamPage> pagesBuilder(BuildContext context);

  /// Guards that will be executing [check] when this gets beamed to.
  ///
  /// Checks will be executed in order; chain of responsibility pattern.
  /// When some guard returns `false`, location will not be accepted
  /// and stack of pages will be updated as is configured in [BeamGuard].
  ///
  /// Override this in your subclasses, if needed.
  List<BeamGuard> get guards => const <BeamGuard>[];

  /// Will be executed before [pages] are drawn onto screen.
  void Function()? executeBefore;

  /// The list of realized/current path segments.
  ///
  /// Effectively, this is split [pathBlueprint].
  //
  /// For '/user/1/details', this would be `['user', ':id', 'details']`.
  List<String> pathSegments;

  /// The realized/current pathBlueprint, one of [pathBlueprints].
  ///
  /// Effectively, this is joined [pathSegments].
  ///
  /// For '/user/1/details', this would be '/user/:id/details'.
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
  Uri get uri => Uri.parse(_path + _query);

  late String _path;
  late String _query;

  /// Recreates the [uri] for this [BeamLocation]
  /// considering current value of [pathParameters] and [queryParameters].
  ///
  /// Calls [executeBefore] if defined.
  void prepare() {
    _makePath();
    _makeQuery();
    executeBefore?.call();
  }

  /// Update chosen parameters of [currentLocation], in a similar manner
  /// as with [BeamLocation] constructor.
  ///
  /// [pathParameters], [queryParameters] and [data] will be appended to
  /// [currentLocation]'s [pathParameters], [queryParameters] and [data]
  /// unless [rewriteParameters] is set to `true`, in which case
  /// [currentLocation]'s attributes will be set to provided values
  /// or their default values.
  void update({
    String? pathBlueprint,
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Map<String, dynamic> data = const <String, dynamic>{},
    bool rewriteParameters = false,
  }) {
    if (pathBlueprint != null) {
      pathSegments = List.from(Uri.parse(pathBlueprint).pathSegments);
    }
    if (rewriteParameters) {
      this.pathParameters = Map.from(pathParameters);
    } else {
      pathParameters.forEach((key, value) {
        this.pathParameters[key] = value;
      });
    }
    if (rewriteParameters) {
      this.queryParameters = Map.from(queryParameters);
    } else {
      queryParameters.forEach((key, value) {
        this.queryParameters[key] = value;
      });
    }
    if (rewriteParameters) {
      this.data = Map.from(data);
    } else {
      data.forEach((key, value) {
        this.data[key] = value;
      });
    }
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
    required String path,
  }) : super(pathBlueprint: path);

  @override
  List<BeamPage> pagesBuilder(BuildContext? context) => [];

  @override
  List<String> get pathBlueprints => [''];
}
