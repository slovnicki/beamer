import 'package:flutter/material.dart';

class BeamPage extends Page {
  final String identifier;
  final Widget page;

  BeamPage({
    @required String identifier,
    @required this.page,
  })  : identifier = identifier,
        super(key: ValueKey(identifier));

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => page,
    );
  }
}
