import 'package:flutter/material.dart';

import 'beamer_delegate.dart';

/// Overrides default back button behavior in [RootBackButtonDispatcher]
/// to do custom [onBack] or [BeamerDelegate.beamBack].
class BeamerBackButtonDispatcher extends RootBackButtonDispatcher {
  BeamerBackButtonDispatcher({
    required this.delegate,
    this.onBack,
  });

  /// A [BeamerDelegate] that belongs to the same [Router]/[Beamer] as this.
  final BeamerDelegate delegate;

  /// A custom closure that has precedence over the default behavior.
  ///
  /// Return `true` if back action can be handled and `false` otherwise.
  final Future<bool> Function(BeamerDelegate delegate)? onBack;

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) async {
    if (onBack != null) {
      return Future.value(await onBack!(delegate));
    }
    bool didPopRoute = await super.invokeCallback(defaultValue);
    if (didPopRoute) {
      return Future.value(didPopRoute);
    }
    return Future.value(delegate.beamBack());
  }
}

/// Overrides default back button behavior in [ChildBackButtonDispatcher]
/// to do custom [onBack] or [BeamerDelegate.beamBack].
class BeamerChildBackButtonDispatcher extends ChildBackButtonDispatcher {
  BeamerChildBackButtonDispatcher({
    required BackButtonDispatcher parent,
    required this.delegate,
    this.onBack,
  }) : super(parent);

  /// A [BeamerDelegate] that belongs to the same [Router]/[Beamer] as this.
  final BeamerDelegate delegate;

  /// A custom closure that has precedence over the default behavior.
  ///
  /// Return `true` if back action can be handled and `false` otherwise.
  final Future<bool> Function(BeamerDelegate delegate)? onBack;

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) async {
    if (!delegate.active) {
      return Future.value(false);
    }
    if (onBack != null) {
      return Future.value(await onBack!(delegate));
    }
    bool didPopRoute = await super.invokeCallback(defaultValue);
    if (didPopRoute) {
      return Future.value(didPopRoute);
    }
    return Future.value(delegate.beamBack());
  }
}
