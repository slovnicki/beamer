import 'package:flutter/widgets.dart';

/// A no-animation transition delegate for [BeamerDelegate.transitionDelegate].
///
/// See example at https://api.flutter.dev/flutter/widgets/TransitionDelegate-class.html.
class NoAnimationTransitionDelegate extends TransitionDelegate<void> {
  /// Creates a [NoAnimationTransitionDelegate].
  const NoAnimationTransitionDelegate() : super();

  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
        locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>>
        pageRouteToPagelessRoutes,
  }) {
    final results = <RouteTransitionRecord>[];

    for (final pageRoute in newPageRouteHistory) {
      if (pageRoute.isWaitingForEnteringDecision) {
        pageRoute.markForAdd();
      }
      results.add(pageRoute);
    }
    for (final exitingPageRoute in locationToExitingPageRoute.values) {
      if (exitingPageRoute.isWaitingForExitingDecision) {
        exitingPageRoute.markForRemove();
        final pagelessRoutes = pageRouteToPagelessRoutes[exitingPageRoute];
        if (pagelessRoutes != null) {
          for (final pagelessRoute in pagelessRoutes) {
            pagelessRoute.markForRemove();
          }
        }
      }
      results.add(exitingPageRoute);
    }
    return results;
  }
}

/// A transition delegate that will look like pop, regardless of whether an action is actuallly a pop.
///
/// New pages are added behind and then the remove animation on old pages is done.
class ReverseTransitionDelegate extends TransitionDelegate<void> {
  /// Creates a [ReverseTransitionDelegate],
  const ReverseTransitionDelegate() : super();

  @override
  Iterable<RouteTransitionRecord> resolve({
    required List<RouteTransitionRecord> newPageRouteHistory,
    required Map<RouteTransitionRecord?, RouteTransitionRecord>
        locationToExitingPageRoute,
    required Map<RouteTransitionRecord?, List<RouteTransitionRecord>>
        pageRouteToPagelessRoutes,
  }) {
    final results = <RouteTransitionRecord>[];

    void handleExitingRoute(RouteTransitionRecord? location) {
      final exitingPageRoute = locationToExitingPageRoute[location];
      if (exitingPageRoute == null) return;
      if (exitingPageRoute.isWaitingForExitingDecision) {
        final hasPagelessRoute =
            pageRouteToPagelessRoutes.containsKey(exitingPageRoute);
        exitingPageRoute.markForPop(exitingPageRoute.route.currentResult);
        if (hasPagelessRoute) {
          final pagelessRoutes = pageRouteToPagelessRoutes[exitingPageRoute]!;
          for (final pagelessRoute in pagelessRoutes) {
            if (pagelessRoute.isWaitingForExitingDecision) {
              pagelessRoute.markForPop(pagelessRoute.route.currentResult);
            }
          }
        }
      }
      results.add(exitingPageRoute);

      handleExitingRoute(exitingPageRoute);
    }

    for (final pageRoute in newPageRouteHistory) {
      if (pageRoute.isWaitingForEnteringDecision) {
        pageRoute.markForAdd();
      }
      results.add(pageRoute);
      handleExitingRoute(pageRoute);
    }

    handleExitingRoute(null);

    return results;
  }
}
