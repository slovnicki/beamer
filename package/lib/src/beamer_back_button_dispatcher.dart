import 'package:flutter/material.dart';

import 'beamer_router_delegate.dart';

/// Overrides default back button behavior in [RootBackButtonDispatcher]
/// to do [BeamerRouterDelegate.beamBack] when possible.
class BeamerBackButtonDispatcher extends RootBackButtonDispatcher {
  final BeamerRouterDelegate delegate;
  BeamerBackButtonDispatcher({@required this.delegate});

  @override
  Future<bool> invokeCallback(Future<bool> defaultValue) async {
    var canPop = await super.invokeCallback(defaultValue);
    if (!canPop) {
      canPop = delegate.beamBack();
    }
    return Future.value(canPop);
  }
}
