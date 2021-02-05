import 'package:flutter/material.dart';

/// A wrapper for pages / screens that will be drawn.
class BeamPage extends Page {
  BeamPage({
    Key key,
    @required this.child,
    this.keepQueryOnPop = false,
  }) : super(key: key);

  /// The concrete Widget representing app's screen.
  final Widget child;

  /// When this [BeamPage] pops from [Navigator] stack, whether to keep the
  /// query parameters within current [BeamLocation].
  ///
  /// Defaults to `false`.
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
