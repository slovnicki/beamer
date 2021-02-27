import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class Location1 extends BeamLocation {
  Location1({
    String? pathBlueprint,
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? data,
  }) : super(
          pathBlueprint: pathBlueprint,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          data: data,
        );

  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('l1'),
          child: Container(),
        ),
        if (pathSegments.contains('one'))
          BeamPage(
            key: ValueKey('l1-one'),
            child: Container(),
          ),
        if (pathSegments.contains('two'))
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
    String? pathBlueprint,
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
    Map<String, dynamic>? data,
  }) : super(
          pathBlueprint: pathBlueprint,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          data: data,
        );

  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('l2'),
          child: Container(),
        )
      ];

  @override
  List<String> get pathBlueprints => ['/l2/:id'];
}
