/// A state for [BeamLocation]
class BeamState {
  BeamState({
    this.pathBlueprintSegments = const <String>[],
    this.pathParameters = const <String, String>{},
    this.queryParameters = const <String, String>{},
    this.data = const <String, dynamic>{},
  }) {
    configure();
  }

  final List<String> pathBlueprintSegments;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
  final Map<String, dynamic> data;

  Uri _uriBlueprint;
  Uri get uriBlueprint => _uriBlueprint;

  Uri _uri;
  Uri get uri => _uri;

  BeamState copyWith({
    List<String> pathBlueprintSegments,
    Map<String, String> pathParameters,
    Map<String, String> queryParameters,
    Map<String, dynamic> data,
  }) =>
      BeamState(
        pathBlueprintSegments:
            pathBlueprintSegments ?? this.pathBlueprintSegments,
        pathParameters: pathParameters ?? this.pathParameters,
        queryParameters: queryParameters ?? this.queryParameters,
        data: data ?? this.data,
      )..configure();

  void configure() {
    _uriBlueprint = Uri(
      pathSegments: [''] + pathBlueprintSegments,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
    final pathSegments = List<String>.from(pathBlueprintSegments);
    for (int i = 0; i < pathSegments.length; i++) {
      if (pathSegments[i][0] == ':') {
        final key = pathSegments[i].substring(1);
        if (pathParameters.containsKey(key)) {
          pathSegments[i] = pathParameters[key];
        }
      }
    }
    _uri = Uri(
      pathSegments: [''] + pathSegments,
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
  }
}
