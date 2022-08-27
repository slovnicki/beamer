part of 'beamer.dart';

/// Returns the provided `String uri` with the constructed `Map<String, dynamic>? queryParameters`
///
/// If `Map<String, dynamic>? queryParameters` is provided, `String uri` should not containt query parameters.
///
/// When `queryParameters` is used the query is built from the provided map.
/// Each key and value in the map is percent-encoded and joined using equal and ampersand characters.
/// A value in the map must be either a `String`, or an `Iterable<String>`, where the latter corresponds to multiple values for the same key.
@visibleForTesting
String constructUri(String uri, Map<String, dynamic>? queryParameters) {
  final _inputQueryParameters = Uri.parse(uri).queryParameters;
  assert(_inputQueryParameters.isEmpty || (queryParameters?.isEmpty ?? true),
      'Avoid passing an uri that already contains query Parameters and a non-empty `queryParameters`');

  if (queryParameters?.isEmpty ?? true) return uri;
  if (_inputQueryParameters.isNotEmpty) return uri;

  return uri + '?' + Uri(queryParameters: queryParameters).query;
}
