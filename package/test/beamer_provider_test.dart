import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('BeamerProvider overrides shouldNotify with false', () {
    final delegate = BeamerDelegate(
      locationBuilder: SimpleLocationBuilder(
        routes: {
          '/': (context, state) => Container(),
        },
      ),
    );
    final provider = BeamerProvider(
      routerDelegate: delegate,
      child: MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: delegate,
      ),
    );
    expect(
        provider.updateShouldNotify(
            BeamerProvider(routerDelegate: delegate, child: Container())),
        false);

    final delegate2 = BeamerDelegate(
      locationBuilder: SimpleLocationBuilder(
        routes: {
          '/': (context, state) => Container(),
        },
      ),
    );
    expect(
        provider.updateShouldNotify(
            BeamerProvider(routerDelegate: delegate2, child: Container())),
        false);
  });
}
