import 'package:flutter/material.dart';

import 'package:beamer/beamer.dart';
import 'package:beamer/src/utils.dart';

/// A convenience typedef for [BeamerDelegate.stackBuilder].
typedef StackBuilder = BeamStack Function(
  BeamerDelegate parent,
  RouteInformation,
  BeamParameters?,
);

/// A pre-made builder to be used for [BeamerDelegate.stackBuilder].
///
/// Determines the appropriate [BeamStack] from the list
/// and populates it with configured state.
class BeamerStackBuilder {
  /// Creates a [BeamerStackBuilder] with specified property.
  ///
  /// [beamStacks] is a required list of [BeamStack]s.
  BeamerStackBuilder({required this.beamStacks});

  /// List of all [BeamStack]s that this builder handles.
  final List<BeamStack> beamStacks;

  /// Makes this callable as [StackBuilder].
  ///
  /// Returns [Utils.chooseBeamStack].
  BeamStack call(
    RouteInformation routeInformation,
    BeamParameters? beamParameters,
  ) {
    return Utils.chooseBeamStack(
      routeInformation.uri,
      beamStacks,
      routeState: routeInformation.state,
      beamParameters: beamParameters,
    );
  }
}

/// A pre-made builder to be used for [BeamerDelegate.stackBuilder].
///
/// Creates a single [BeamStack]; [RoutesBeamStack]
/// and configures its [BeamStack.buildPages] from specified [routes].
class RoutesStackBuilder {
  /// Creates a [RoutesStackBuilder] with specified properties.
  ///
  /// [routes] are required to build pages from.
  RoutesStackBuilder({
    required this.routes,
    this.builder,
  });

  /// List of all routes this builder handles.
  ///
  /// isPinnacle is true when the route is the outer/last in the stack.
  final Map<
      Pattern,
      dynamic Function(
        BuildContext,
        BeamState,
        // BeamPageNotifierReference,
        // BeamPageStateNotifier,
        Object?,
      )> routes;

  /// Used as a [BeamStack.builder].
  final Widget Function(BuildContext context, Widget navigator)? builder;

  /// Makes this callable as [StackBuilder].
  ///
  /// Returns [RoutesBeamStack] configured with chosen routes from [routes] or [NotFound].
  BeamStack call(
    BeamerDelegate parent,
    RouteInformation routeInformation,
    BeamParameters? beamParameters,
  ) {
    final matched = RoutesBeamStack.chooseRoutes(routeInformation, routes.keys);
    if (matched.isNotEmpty) {
      return RoutesBeamStack(
        parent: parent,
        routeInformation: routeInformation,
        routes: routes,
        navBuilder: builder,
      );
    } else {
      return NotFound(path: routeInformation.uri.toString());
    }
  }
}
