import 'package:flutter/material.dart';

class BeamPage extends Page {
  final String pathBlueprint;
  final Widget page;

  BeamPage({
    @required String pathBlueprint,
    @required this.page,
  })  : pathBlueprint = pathBlueprint,
        super(key: ValueKey(pathBlueprint));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => page,
    );
  }
}
