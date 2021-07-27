import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Beamer.setPathUrlStrategy();

  BuildContext? testContext;
  late BeamerDelegate rootDelegate;

  final beamerKey = GlobalKey<BeamerState>();

  final app = BeamerProvider(
    routerDelegate: BeamerDelegate(
      locationBuilder: SimpleLocationBuilder(
        routes: {
          '/test2/x': (context, state) {
            rootDelegate = Beamer.of(context, root: true);
            return Container();
          },
        },
      ),
    ),
    child: MaterialApp.router(
      routeInformationParser: BeamerParser(),
      routerDelegate: BeamerDelegate(
        transitionDelegate: const NoAnimationTransitionDelegate(),
        locationBuilder: SimpleLocationBuilder(
          routes: {
            '/': (context, state) {
              testContext = context;
              return Container();
            },
            '/test': (context, state) => Container(),
            '/test2/*': (context, state) => Beamer(
                  key: beamerKey,
                  routerDelegate: BeamerProvider.of(context)!.routerDelegate,
                ),
          },
        ),
      ),
    ),
  );
  testWidgets('Context has BeamerDelegate', (tester) async {
    await tester.pumpWidget(app);
    expect(Beamer.of(testContext!), isA<BeamerDelegate>());
  });

  testWidgets('Beaming updates location state', (tester) async {
    await tester.pumpWidget(app);
    testContext!.beamToNamed('/test');
    await tester.pump();
    expect(testContext!.currentBeamLocation.state.routeInformation.location,
        '/test');
    expect(
        (testContext!.currentBeamLocation.state as BeamState)
            .uriBlueprint
            .toString(),
        '/test');
    expect(testContext!.currentBeamPages.length, 2);
  });

  testWidgets(
      'beamStateHistory contains multiple entries and beamBack is possible',
      (tester) async {
    await tester.pumpWidget(app);
    expect(Beamer.of(testContext!).beamingHistoryCompleteLength, 2);
    expect(testContext!.canBeamBack, true);
    testContext!.beamBack();
    await tester.pump();
    expect(Beamer.of(testContext!).beamingHistoryCompleteLength, 1);
    expect(testContext!.canBeamBack, false);
    expect(
        testContext!.currentBeamLocation.state.routeInformation.location, '/');
  });

  testWidgets(
      'Beaming to another location pushes it into history which can be popped',
      (tester) async {
    await tester.pumpWidget(app);
    testContext!.beamTo(NotFound(path: '/not-found'));
    await tester.pump();
    expect(testContext!.currentBeamLocation, isA<NotFound>());
    expect(Beamer.of(testContext!).beamingHistory, 2);
    expect(testContext!.canPopBeamLocation, true);
    testContext!.popBeamLocation();
  });

  testWidgets('Root delegate can be obtained from children', (tester) async {
    await tester.pumpWidget(app);
    testContext!.popToNamed('/test2/x');
    await tester.pump();
    expect(rootDelegate, isA<BeamerDelegate>());
  });

  testWidgets('Beamer can be used via key', (tester) async {
    await tester.pumpWidget(app);
    expect(beamerKey.currentState, isNotNull);
    expect(
        beamerKey
            .currentState!.currentBeamLocation.state.routeInformation.location,
        '/test2/x');
  });

  testWidgets('3 layers deep recursively finds root', (tester) async {
    BuildContext? testContext;
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: BeamerDelegate(
          locationBuilder: SimpleLocationBuilder(
            routes: {
              '/': (context, state) => Beamer(
                    routerDelegate: BeamerDelegate(
                      locationBuilder: SimpleLocationBuilder(
                        routes: {
                          '/': (context, state) => Beamer(
                                routerDelegate: BeamerDelegate(
                                  locationBuilder: SimpleLocationBuilder(
                                    routes: {
                                      '/': (context, state) {
                                        testContext = context;
                                        Beamer.of(context).active = false;
                                        return Container();
                                      },
                                    },
                                  ),
                                ),
                              ),
                        },
                      ),
                    ),
                  ),
            },
          ),
        ),
      ),
    );
    expect(Beamer.of(testContext!, root: true), isA<BeamerDelegate>());
  });

  testWidgets('Beamer in builder can be accessed with BeamerProvider',
      (tester) async {
    BuildContext? testContext;
    final delegate = BeamerDelegate(
      locationBuilder: SimpleLocationBuilder(
        routes: {
          '/': (context, state) => Container(),
        },
      ),
    );
    await tester.pumpWidget(
      BeamerProvider(
        routerDelegate: delegate,
        child: MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
          builder: (context, child) {
            testContext = context;
            return child!;
          },
        ),
      ),
    );
    expect(Beamer.of(testContext!), isA<BeamerDelegate>());
  });

  testWidgets('history is accessible through context extension method',
      (tester) async {
    await tester.pumpWidget(app);
    expect(testContext!.beamingHistory.length, greaterThan(0));
  });
}
