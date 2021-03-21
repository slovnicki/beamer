import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class Location1 extends BeamLocation {
  Location1({
    String pathBlueprint,
  }) : super(
          state: BeamState(
            pathBlueprintSegments: Uri.parse(pathBlueprint).pathSegments,
          ),
        );

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('l1'),
          child: Container(),
        ),
        if (state.pathBlueprintSegments.contains('one'))
          BeamPage(
            key: ValueKey('l1-one'),
            child: Container(),
          ),
        if (state.pathBlueprintSegments.contains('two'))
          BeamPage(
            key: ValueKey('l1-two'),
            child: Container(),
          )
      ];

  @override
  List<String> get pathBlueprints => ['/l1/one', '/l1/two'];
}

class Location2 extends BeamLocation {
  Location2({
    String pathBlueprint,
  }) : super(
          state: BeamState(
            pathBlueprintSegments: Uri.parse(pathBlueprint).pathSegments,
          ),
        );

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('l2'),
          child: Container(),
        )
      ];

  @override
  List<String> get pathBlueprints => ['/l2/:id'];
}

class CustomState extends BeamState {
  CustomState({
    List<String> pathBlueprintSegments = const <String>[],
    Map<String, String> pathParameters = const <String, String>{},
    Map<String, String> queryParameters = const <String, String>{},
    Map<String, dynamic> data = const <String, dynamic>{},
    this.customVar,
  }) : super(
          pathBlueprintSegments: pathBlueprintSegments,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          data: data,
        );

  final String customVar;

  @override
  CustomState copyWith({
    List<String> pathBlueprintSegments,
    Map<String, String> pathParameters,
    Map<String, String> queryParameters,
    Map<String, dynamic> data,
    String customVar,
  }) =>
      CustomState(
        pathBlueprintSegments:
            pathBlueprintSegments ?? this.pathBlueprintSegments,
        pathParameters: pathParameters ?? this.pathParameters,
        queryParameters: queryParameters ?? this.queryParameters,
        data: data ?? this.data,
        customVar: customVar ?? this.customVar,
      )..configure();
}

class CustomStateLocation extends BeamLocation<CustomState> {
  @override
  List<String> get pathBlueprints => ['/custom/:customVar'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('custom-${state.customVar}'),
          child: Container(),
        )
      ];

  @override
  CustomState createState(
    List<String> pathBlueprintSegments,
    Map<String, String> pathParameters,
    Map<String, String> queryParameters,
    Map<String, dynamic> data,
  ) =>
      CustomState(
        pathBlueprintSegments: pathBlueprintSegments,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        data: data,
        customVar: 'test',
      );
}
