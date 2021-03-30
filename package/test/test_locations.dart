import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class Location1 extends BeamLocation {
  Location1(BeamState state) : super(state);

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
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
  Location2(BeamState state) : super(state);

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
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
  CustomStateLocation() : super(CustomState(pathBlueprintSegments: ['path']));

  @override
  List<String> get pathBlueprints => ['/custom/:customVar'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, CustomState state) => [
        BeamPage(
          key: ValueKey('custom-${state.customVar}'),
          child: Container(),
        )
      ];

  @override
  CustomState createState(BeamState state) => CustomState(
        pathBlueprintSegments: state.pathBlueprintSegments,
        pathParameters: state.pathParameters,
        queryParameters: state.queryParameters,
        data: state.data,
        customVar: 'test',
      );
}

class NoStateLocation extends BeamLocation {
  NoStateLocation() : super(BeamState());

  @override
  List<String> get pathBlueprints => ['/page'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('page'),
          child: Container(),
        )
      ];
}
