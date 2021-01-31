import 'package:flutter/material.dart';

class BeamPage extends Page {
  BeamPage({
    Key key,
    @required this.pathSegment,
    @required this.child,
    this.keepQueryOnPop = false,
  }) : super(key: key);

  final String pathSegment;
  final Widget child;
  final bool keepQueryOnPop;

  @override
  Route createRoute(BuildContext context) {
    return MaterialPageRoute(
      settings: this,
      builder: (context) => child,
    );
  }

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is BeamPage && key == other.key;
  }
}
