import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Beamer.setPathUrlStrategy();

  BuildContext? testContext;
  var rootDelegate;

  final beamerKey = GlobalKey<BeamerState>();

  final app = BeamerProvider(
    routerDelegate: BeamerRouterDelegate(
      locationBuilder: SimpleLocationBuilder(
        routes: {
          '/test2/x': (context) {
            rootDelegate = Beamer.of(context, root: true);
            return Container();
          },
        },
      ),
    ),
    child: MaterialApp.router(
      routeInformationParser: BeamerRouteInformationParser(),
      routerDelegate: BeamerRouterDelegate(
        transitionDelegate: NoAnimationTransitionDelegate(),
        locationBuilder: SimpleLocationBuilder(
          routes: {
            '/': (context) {
              testContext = context;
              return Container();
            },
            '/test': (context) => Container(),
            '/test2/*': (context) => Beamer(
                  key: beamerKey,
                  routerDelegate: BeamerProvider.of(context)!.routerDelegate,
                ),
          },
        ),
      ),
    ),
  );
  testWidgets('Context has BeamerRouterDelegate', (tester) async {
    await tester.pumpWidget(app);
    expect(Beamer.of(testContext!), isA<BeamerRouterDelegate>());
  });

  testWidgets('Beaming updates location state', (tester) async {
    await tester.pumpWidget(app);
    testContext!.beamToNamed('/test');
    await tester.pump();
    expect(testContext!.currentBeamLocation.state.uri.toString(), '/test');
    expect(testContext!.currentBeamLocation.state.uriBlueprint.toString(),
        '/test');
    expect(testContext!.currentBeamPages.length, 2);
  });

  testWidgets(
      'beamStateHistory contains multiple entries and beamBack is possible',
      (tester) async {
    await tester.pumpWidget(app);
    expect(Beamer.of(testContext!).beamStateHistory.length, 2);
    expect(testContext!.canBeamBack, true);
    testContext!.beamBack();
    await tester.pump();
    expect(Beamer.of(testContext!).beamStateHistory.length, 1);
    expect(testContext!.canBeamBack, false);
    expect(testContext!.currentBeamLocation.state.uri.toString(), '/');
  });

  testWidgets(
      'Beaming to another location pushes it into history which can be popped',
      (tester) async {
    await tester.pumpWidget(app);
    testContext!.beamTo(NotFound(path: '/not-found'));
    await tester.pump();
    expect(testContext!.currentBeamLocation, isA<NotFound>());
    expect(Beamer.of(testContext!).beamLocationHistory.length, 2);
    expect(testContext!.canPopBeamLocation, true);
    testContext!.popBeamLocation();
  });

  testWidgets('Root delegate can be obtained from children', (tester) async {
    await tester.pumpWidget(app);
    testContext!.beamToNamed('/test2/x');
    await tester.pump();
    expect(rootDelegate, isA<BeamerRouterDelegate>());
  });

  testWidgets('Beamer can be used via key', (tester) async {
    await tester.pumpWidget(app);
    expect(beamerKey.currentState, isNotNull);
    expect(beamerKey.currentState!.currentLocation.state.uri.toString(),
        '/test2/x');
  });
}
