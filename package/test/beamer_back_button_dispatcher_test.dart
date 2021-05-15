import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('back button pops', (tester) async {
    final delegate = BeamerRouterDelegate(
      locationBuilder: SimpleLocationBuilder(
        routes: {
          '/': (context) => Container(),
          '/test': (context) => Container(),
        },
      ),
    );
    final backButtonDispatcher = BeamerBackButtonDispatcher(delegate: delegate);
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerRouteInformationParser(),
        routerDelegate: delegate,
        backButtonDispatcher: backButtonDispatcher,
      ),
    );
    delegate.beamToNamed('/test');
    await tester.pump();
    expect(delegate.currentLocation.state.uri.toString(), '/test');

    await backButtonDispatcher.invokeCallback(Future.value(true));
    await tester.pump();
    expect(delegate.currentLocation.state.uri.toString(), '/');

    await backButtonDispatcher.invokeCallback(Future.value(true));
    await tester.pump();
    expect(delegate.currentLocation.state.uri.toString(), '/');
  });
}
