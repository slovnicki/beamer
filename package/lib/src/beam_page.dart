import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'beam_location.dart';
import 'beam_state.dart';

/// Types for how to route should be built.
enum BeamPageType {
  material,
  cupertino,
  noTransition,
  fadeTransition,
}

/// The default pop behavior for [BeamPage].
bool _defaultOnPopPage(
  BuildContext context,
  BeamLocation location,
  BeamPage page,
) {
  final pathBlueprintSegments =
      List<String>.from(location.state.pathBlueprintSegments);
  final pathParameters =
      Map<String, String>.from(location.state.pathParameters);
  final pathSegment = pathBlueprintSegments.removeLast();
  if (pathSegment[0] == ':') {
    pathParameters.remove(pathSegment.substring(1));
  }
  location.update(
    (state) => BeamState(
      pathBlueprintSegments: pathBlueprintSegments,
      pathParameters: pathParameters,
      queryParameters:
          !page.keepQueryOnPop ? {} : location.state.queryParameters,
      data: location.state.data,
    ),
  );
  return true;
}

/// A wrapper for pages / screens that will be drawn.
class BeamPage extends Page {
  BeamPage({
    LocalKey? key,
    String? name,
    required this.child,
    this.onPopPage = _defaultOnPopPage,
    this.popToNamed,
    this.type = BeamPageType.material,
    this.pageRouteBuilder,
    this.keepQueryOnPop = false,
  }) : super(key: key, name: name);

  /// The concrete Widget representing app's screen.
  final Widget child;

  /// Overrides the default pop by executing an arbitrary closure.
  /// Mainly used to manually update the `location` state.
  ///
  /// Return `false` (rarely used) to prevent **any** navigation from happening,
  /// otherwise return `true`.
  ///
  /// More general than [popToNamed].
  final bool Function(
    BuildContext context,
    BeamLocation location,
    BeamPage page,
  ) onPopPage;

  /// Overrides the default pop by beaming to specified URI string.
  ///
  /// Less powerful than [onPopPage].
  final String? popToNamed;

  /// The type to determine how a route should be built.
  ///
  /// See [BeamPageType] for available types.
  final BeamPageType type;

  /// A completely custom [PageRouteBuilder] to use for [createRoute].
  ///
  /// `settings` must be passed to [PageRouteBuilder.settings].
  final PageRouteBuilder Function(RouteSettings settings, Widget child)?
      pageRouteBuilder;

  /// When this [BeamPage] pops from [Navigator] stack, whether to keep the
  /// query parameters within current [BeamLocation].
  ///
  /// Defaults to `false`.
  final bool keepQueryOnPop;

  @override
  Route createRoute(BuildContext context) {
    if (pageRouteBuilder != null) {
      return pageRouteBuilder!(this, child);
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
