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
