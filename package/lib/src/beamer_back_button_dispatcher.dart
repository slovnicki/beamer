import 'package:flutter/material.dart';

import 'beamer_delegate.dart';

/// Overrides default back button behavior in [RootBackButtonDispatcher]
/// to do custom [onBack] or [BeamerDelegate.beamBack].
class BeamerBackButtonDispatcher extends RootBackButtonDispatcher {
  BeamerBackButtonDispatcher({
    required this.delegate,
    this.onBack,
    this.alwaysBeamBack = false,
    this.fallbackToBeamBack = true,
  });

  /// A [BeamerDelegate] that belongs to the same [Router]/[Beamer] as this.
  final BeamerDelegate delegate;

  /// A custom closure that has precedence over other behaviors.
  ///
  /// Return `true` if back action can be handled and `false` otherwise.
  final Future<bool> Function(BeamerDelegate delegate)? onBack;

  /// Whether to always do [BeamerDelegate.beamBack] when Android back button
  /// is pressed, i.e. always go to previous route in navigation history
  /// instead of trying to pop first.
  final bool alwaysBeamBack;

  /// Whether to try to use `beamBack()` when pop cannot be done.
  final bool fallbackToBeamBack;

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) async {
    if (onBack != null) {
      return (await onBack!(delegate));
    }

    if (alwaysBeamBack) {
      return delegate.beamBack();
    }

    bool didPopRoute = await super.invokeCallback(defaultValue);
    if (didPopRoute) {
      return didPopRoute;
    }

    if (fallbackToBeamBack) {
      return delegate.beamBack();
    } else {
      return false;
    }
  }
}

/// Overrides default back button behavior in [ChildBackButtonDispatcher]
/// to do custom [onBack] or [BeamerDelegate.beamBack].
class BeamerChildBackButtonDispatcher extends ChildBackButtonDispatcher {
  BeamerChildBackButtonDispatcher({
    required BeamerBackButtonDispatcher parent,
    required this.delegate,
    this.onBack,
  })  : alwaysBeamBack = parent.alwaysBeamBack,
        fallbackToBeamBack = parent.fallbackToBeamBack,
        super(parent);

  /// A [BeamerDelegate] that belongs to the same [Router]/[Beamer] as this.
  final BeamerDelegate delegate;

  /// A custom closure that has precedence over other behaviors.
  ///
  /// Return `true` if back action can be handled and `false` otherwise.
  final Future<bool> Function(BeamerDelegate delegate)? onBack;

  /// Whether to always do [BeamerDelegate.beamBack] when Android back button
  /// is pressed, i.e. always go to previous route in navigation history
  /// instead of trying to pop first.
  final bool alwaysBeamBack;

  /// Whether to try to use `beamBack()` when pop cannot be done.
  final bool fallbackToBeamBack;

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) async {
    if (!delegate.active) {
      return false;
    }

    if (onBack != null) {
      return (await onBack!(delegate));
    }

    if (alwaysBeamBack) {
      return delegate.beamBack();
    }

    bool didPopRoute = await super.invokeCallback(defaultValue);
    if (didPopRoute) {
      return didPopRoute;
    }

    if (fallbackToBeamBack) {
      return delegate.beamBack();
    } else {
      return false;
    }
  }
}
