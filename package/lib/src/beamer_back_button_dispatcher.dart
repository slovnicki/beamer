import 'package:flutter/material.dart';

import 'beamer_delegate.dart';

/// Overrides default back button behavior in [RootBackButtonDispatcher]
/// to do [BeamerDelegate.beamBack] when possible.
class BeamerBackButtonDispatcher extends RootBackButtonDispatcher {
  final BeamerDelegate delegate;
  BeamerBackButtonDispatcher({required this.delegate});

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) async {
    var canPop = await super.invokeCallback(defaultValue);
    if (!canPop) {
      canPop = delegate.beamBack();
    }
    return Future.value(canPop);
  }
}
