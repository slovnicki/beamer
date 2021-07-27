import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../beamer.dart';

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
  const BeamPage({
    LocalKey? key,
    String? name,
    required this.child,
    this.title,
    this.onPopPage = pathSegmentPop,
    this.popToNamed,
    this.type = BeamPageType.material,
    this.routeBuilder,
    this.fullScreenDialog = false,
    this.keepQueryOnPop = false,
  }) : super(key: key, name: name);

  /// The default pop behavior for [BeamPage].
  ///
  /// Pops the last path segment from URI and calls [BeamerDelegate.update].
  static bool pathSegmentPop(
    BuildContext context,
    BeamerDelegate delegate,
    BeamPage poppedPage,
  ) {
    if (delegate.beamingHistoryCompleteLength <= 1) {
      return false;
    }

    final poppedHistoryElement = delegate.removeLastHistoryElement();
    final previousHistoryElement = delegate.beamingHistory.last.history.last;

    final previousUri = Uri.parse(
      previousHistoryElement.state.routeInformation.location ?? '/',
    );

    final location =
        poppedHistoryElement!.state.routeInformation.location ?? '/';
    final pathSegments = Uri.parse(location).pathSegments;
    final queryParameters = Uri.parse(location).queryParameters;
    var popUri = Uri(
      pathSegments: List.from(pathSegments)..removeLast(),
      queryParameters: poppedPage.keepQueryOnPop ? queryParameters : null,
    );
    final popUriPath = '/' + popUri.path;

    popUri = Uri(
      pathSegments: popUri.pathSegments,
      queryParameters:
          (popUriPath == previousUri.path && !poppedPage.keepQueryOnPop)
              ? previousUri.queryParameters
              : popUri.queryParameters,
    );

    if (popUriPath == previousUri.path) {
      delegate.removeLastHistoryElement();
    }
    delegate.update(
      configuration: delegate.configuration.copyWith(
        location:
            popUriPath + (popUri.query.isNotEmpty ? '?${popUri.query}' : ''),
      ),
    );

    return true;
  }

  /// Pops the last route from history and calls [BeamerDelegate.update].
  static bool routePop(
    BuildContext context,
    BeamerDelegate delegate,
    BeamPage poppedPage,
  ) {
    if (delegate.beamingHistoryCompleteLength <= 1) {
      return false;
    }

    delegate.removeLastHistoryElement();
    final previousHistoryElement = delegate.removeLastHistoryElement();

    delegate.update(
      configuration: previousHistoryElement!.state.routeInformation.copyWith(),
    );

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
  final Route Function(RouteSettings settings, Widget child)? routeBuilder;

  /// Whether to present current [BeamPage] as a fullscreen dialog
  ///
  /// On iOS, dialog transitions animate differently and are also not closeable with the back swipe gesture
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
          title: title,
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
                Tween(begin: const Offset(0, 1), end: const Offset(0, 0))
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
