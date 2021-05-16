import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'beam_location.dart';
import 'beam_state.dart';
import 'beamer_delegate.dart';

/// Types for how to route should be built.
enum BeamPageType {
  material,
  cupertino,
  fadeTransition,
  slideTransition,
  scaleTransition,
  noTransition,
}

/// The default pop behavior for [BeamPage].
bool _defaultOnPopPage(
  BuildContext context,
  BeamerDelegate delegate,
  BeamPage poppedPage,
) {
  final location = delegate.currentLocation;
  final previousBeamState = delegate.beamStateHistory.length > 1
      ? delegate.beamStateHistory[delegate.beamStateHistory.length - 2]
      : null;

  final pathBlueprintSegments =
      List<String>.from(location.state.pathBlueprintSegments);
  final pathParameters =
      Map<String, String>.from(location.state.pathParameters);
  final pathSegment = pathBlueprintSegments.removeLast();
  if (pathSegment[0] == ':') {
    pathParameters.remove(pathSegment.substring(1));
  }

  var beamState = BeamState(
    pathBlueprintSegments: pathBlueprintSegments,
    pathParameters: pathParameters,
    queryParameters:
        poppedPage.keepQueryOnPop ? location.state.queryParameters : {},
    data: location.state.data,
  );

  if (beamState.uri.path == previousBeamState?.uri.path &&
      !poppedPage.keepQueryOnPop) {
    beamState = beamState.copyWith(
      queryParameters: previousBeamState?.queryParameters,
    );
  }

  location.update((state) => beamState);
  return true;
}

/// A wrapper for screens in a navigation stack.
class BeamPage extends Page {
  BeamPage({
    LocalKey? key,
    String? name,
    required this.child,
    this.title,
    this.onPopPage = _defaultOnPopPage,
    this.popToNamed,
    this.type = BeamPageType.material,
    this.pageRouteBuilder,
    this.keepQueryOnPop = false,
  }) : super(key: key, name: name);

  /// The concrete Widget representing app's screen.
  final Widget child;

  /// The BeamPage's title. On the web, this is used for the browser tab title.
  final String? title;

  /// Overrides the default pop by executing an arbitrary closure.
  /// Mainly used to manually update the [delegate.currentLocation] state.
  ///
  /// [poppedPage] is this [BeamPage].
  ///
  /// Return `false` (rarely used) to prevent **any** navigation from happening,
  /// otherwise return `true`.
  ///
  /// More powerful than [popToNamed].
  final bool Function(
    BuildContext context,
    BeamerDelegate delegate,
    BeamPage poppedPage,
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
  /// [settings] must be passed to [PageRouteBuilder.settings].
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
      case BeamPageType.cupertino:
        return CupertinoPageRoute(
          settings: this,
          builder: (context) => child,
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
      case BeamPageType.slideTransition:
        return PageRouteBuilder(
          settings: this,
          pageBuilder: (_, __, ___) => child,
          transitionsBuilder: (_, animation, __, child) => SlideTransition(
            position: animation.drive(
                Tween(begin: Offset(0, 1), end: Offset(0, 0))
                    .chain(CurveTween(curve: Curves.ease))),
            child: child,
          ),
        );
      case BeamPageType.scaleTransition:
        return PageRouteBuilder(
          settings: this,
          pageBuilder: (_, __, ___) => child,
          transitionsBuilder: (_, animation, __, child) => ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      case BeamPageType.noTransition:
        return PageRouteBuilder(
          settings: this,
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );
      default:
        return MaterialPageRoute(
          settings: this,
          builder: (context) => child,
        );
    }
  }
}
