import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Types for how to route should be built.
enum BeamPageType {
  material,
  cupertino,
  noTransition,
  fadeTransition,
}

/// A wrapper for pages / screens that will be drawn.
class BeamPage extends Page {
  BeamPage({
    Key key,
    String name,
    @required this.child,
    this.type = BeamPageType.material,
    this.pageRouteBuilder,
    this.keepQueryOnPop = false,
  }) : super(key: key, name: name);

  /// The concrete Widget representing app's screen.
  final Widget child;

  /// The type to determine how a route should be built.
  ///
  /// See [BeamPageType] for available types.
  final BeamPageType type;

  /// A completely custom [PageRouteBuilder] to use for [createRoute].
  ///
  /// `settings` must be passed to [PageRouteBuilder.settings].
  final PageRouteBuilder Function(RouteSettings settings, Widget child)
      pageRouteBuilder;

  /// When this [BeamPage] pops from [Navigator] stack, whether to keep the
  /// query parameters within current [BeamLocation].
  ///
  /// Defaults to `false`.
  final bool keepQueryOnPop;

  @override
  Route createRoute(BuildContext context) {
    if (pageRouteBuilder != null) {
      return pageRouteBuilder(this, child);
    }
    switch (type) {
      case BeamPageType.material:
        return MaterialPageRoute(
          settings: this,
          builder: (context) => child,
        );
      case BeamPageType.cupertino:
        return CupertinoPageRoute(
          settings: this,
          builder: (context) => child,
        );
      case BeamPageType.noTransition:
        return PageRouteBuilder(
          settings: this,
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );
      case BeamPageType.fadeTransition:
        return PageRouteBuilder(
          settings: this,
          pageBuilder: (_, __, ___) => child,
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      default:
        return MaterialPageRoute(
          settings: this,
          builder: (context) => child,
        );
    }
  }

  @override
  int get hashCode => super.hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) || other is BeamPage && key == other.key;
  }
}
