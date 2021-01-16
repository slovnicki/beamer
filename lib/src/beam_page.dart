import 'package:flutter/material.dart';

class BeamPage extends Page {
  final Widget page;

  BeamPage({
    Key key,
    @required this.page,
  }) : super(key: key);

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => page,
    );
  }

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is BeamPage && key == other.key;
  }
}
