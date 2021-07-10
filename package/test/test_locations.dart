import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class Location1 extends BeamLocation {
  Location1([BeamState? state]) : super(state);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: const ValueKey('l1'),
          child: Container(),
        ),
        if (state.pathBlueprintSegments.contains('one'))
          BeamPage(
            key: const ValueKey('l1-one'),
            child: Container(),
          ),
        if (state.pathBlueprintSegments.contains('two'))
          BeamPage(
            key: const ValueKey('l1-two'),
            child: Container(),
          )
      ];

  @override
  List<String> get pathBlueprints => ['/l1/one', '/l1/two'];
}

class Location2 extends BeamLocation {
  Location2(BeamState state) : super(state);

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: const ValueKey('l2'),
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
    this.customVar = '',
  }) : super(
          pathBlueprintSegments: pathBlueprintSegments,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          data: data,
        );

  final String customVar;

  @override
  CustomState copyWith({
    List<String>? pathBlueprintSegments,
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? data,
    String? customVar,
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
  CustomStateLocation() : super(CustomState(pathBlueprintSegments: ['custom']));

  factory CustomStateLocation.fromBeamState(BeamState state) {
    return CustomStateLocation()
      ..state = CustomState(
        pathBlueprintSegments: state.pathBlueprintSegments,
        pathParameters: state.pathParameters,
        queryParameters: state.queryParameters,
        data: state.data,
        customVar: state.pathBlueprintSegments.length > 1
            ? state.pathBlueprintSegments[1]
            : 'test',
      );
  }

  @override
  List<String> get pathBlueprints => ['/custom/:customVar'];

  @override
  List<BeamPage> buildPages(BuildContext context, CustomState state) => [
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
        customVar: state.pathBlueprintSegments.length > 2
            ? state.pathBlueprintSegments[1]
            : 'test',
      );
}

class NoStateLocation extends BeamLocation {
  NoStateLocation() : super(BeamState());

  @override
  List<String> get pathBlueprints => ['/page'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: const ValueKey('page'),
          child: Container(),
        )
      ];
}

class RegExpLocation extends BeamLocation {
  RegExpLocation([BeamState? state]) : super(state);

  @override
  List get pathBlueprints => [RegExp('/reg')];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: const ValueKey('reg'),
          child: Container(),
        )
      ];
}

class AsteriskLocation extends BeamLocation {
  AsteriskLocation([BeamState? state]) : super(state);

  @override
  List get pathBlueprints => ['/anything/*'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: const ValueKey('anything'),
          child: Container(),
        )
      ];
}
