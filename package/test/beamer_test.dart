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
      stackBuilder: RoutesStackBuilder(
        routes: {
          '/test2/x': (context, state, data) {
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
        stackBuilder: RoutesStackBuilder(
          routes: {
            '/': (context, state, data) {
              testContext = context;
              return Container();
            },
            '/test': (context, state, data) => Container(),
            '/test2/*': (context, state, data) => Beamer(
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

  testWidgets('Beaming updates stack state', (tester) async {
    await tester.pumpWidget(app);
    testContext!.beamToNamed('/test');
    await tester.pump();
    expect(
        testContext!.currentBeamStack.state.routeInformation.uri.path, '/test');
    expect(
        (testContext!.currentBeamStack.state as BeamState)
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
    expect(testContext!.currentBeamStack.state.routeInformation.uri.path, '/');
  });

  testWidgets(
      'Beaming to another stack pushes it into history which can be popped',
      (tester) async {
    await tester.pumpWidget(app);
    testContext!.beamTo(NotFound(path: '/not-found'));
    await tester.pump();
    expect(testContext!.currentBeamStack, isA<NotFound>());
    expect(Beamer.of(testContext!).beamingHistory.length, 2);
    expect(testContext!.canPopBeamStack, true);
    testContext!.popBeamStack();
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
            .currentState!.currentBeamStack.state.routeInformation.uri.path,
        '/test2/x');
  });

  testWidgets('3 layers deep recursively finds root', (tester) async {
    BuildContext? testContext;
    await tester.pumpWidget(
      MaterialApp.router(
        routeInformationParser: BeamerParser(),
        routerDelegate: BeamerDelegate(
          stackBuilder: RoutesStackBuilder(
            routes: {
              '/': (context, state, data) => Beamer(
                    routerDelegate: BeamerDelegate(
                      stackBuilder: RoutesStackBuilder(
                        routes: {
                          '/': (context, state, data) => Beamer(
                                routerDelegate: BeamerDelegate(
                                  stackBuilder: RoutesStackBuilder(
                                    routes: {
                                      '/': (context, state, data) {
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
      stackBuilder: RoutesStackBuilder(
        routes: {
          '/': (context, state, data) => Container(),
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
