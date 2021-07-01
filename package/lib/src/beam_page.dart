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

/// A wrapper for screens in a navigation stack.
class BeamPage extends Page {
  BeamPage({
    LocalKey? key,
    String? name,
    required this.child,
    this.title,
    this.onPopPage = defaultOnPopPage,
    this.popToNamed,
    this.type = BeamPageType.material,
    this.routeBuilder,
    this.fullScreenDialog = false,
    this.keepQueryOnPop = false,
  }) : super(key: key, name: name);

  /// The default pop behavior for [BeamPage].
  static bool defaultOnPopPage(
    BuildContext context,
    BeamerDelegate delegate,
    BeamPage poppedPage,
  ) {
    final location = delegate.currentBeamLocation;
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

    delegate.removeLastBeamState();

    location.update((state) => beamState);
    return true;
  }

  /// The concrete Widget representing app's screen.
  final Widget child;

  /// The BeamPage's title. On the web, this is used for the browser tab title.
  final String? title;

  /// Overrides the default pop by executing an arbitrary closure.
  /// Mainly used to manually update the [delegate.currentBeamLocation] state.
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

  /// A builder for custom [Route] to use in [createRoute].
  ///
  /// [settings] must be passed to [PageRoute.settings].
  /// [child] is the child of this [BeamPage]
  final Route Function(RouteSettings settings, Widget child)?
      routeBuilder;

  /// Whether to present current [BeamPage] in fullscreen
  ///
  /// On iOS the transitions animate differently when it's presented in fullscreen
  final bool fullScreenDialog;

  /// When this [BeamPage] pops from [Navigator] stack, whether to keep the
  /// query parameters within current [BeamLocation].
  ///
  /// Defaults to `false`.
  final bool keepQueryOnPop;

  @override
  Route createRoute(BuildContext context) {
    if (routeBuilder != null) {
      return routeBuilder!(this, child);
    }
    switch (type) {
      case BeamPageType.cupertino:
        return CupertinoPageRoute(
          fullscreenDialog: fullScreenDialog,
          settings: this,
          builder: (context) => child,
        );
      case BeamPageType.fadeTransition:
        return PageRouteBuilder(
          fullscreenDialog: fullScreenDialog,
          settings: this,
          pageBuilder: (_, __, ___) => child,
          transitionsBuilder: (_, animation, __, child) => FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
      case BeamPageType.slideTransition:
        return PageRouteBuilder(
          fullscreenDialog: fullScreenDialog,
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
          fullscreenDialog: fullScreenDialog,
          settings: this,
          pageBuilder: (_, __, ___) => child,
          transitionsBuilder: (_, animation, __, child) => ScaleTransition(
            scale: animation,
            child: child,
          ),
        );
      case BeamPageType.noTransition:
        return PageRouteBuilder(
          fullscreenDialog: fullScreenDialog,
          settings: this,
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );
      default:
        return MaterialPageRoute(
          fullscreenDialog: fullScreenDialog,
          settings: this,
          builder: (context) => child,
        );
    }
  }
}
