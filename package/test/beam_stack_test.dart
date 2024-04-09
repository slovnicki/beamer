import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'test_stacks.dart';

void main() {
  final stack2 = Stack2(RouteInformation(uri: Uri.parse('/l2/1')));

  group('prepare', () {
    test('BeamStack can create valid URI', () {
      stack2.state = stack2.state.copyWith(
        pathParameters: {'id': '42'},
        queryParameters: {'q': 'xxx'},
      );
      expect(stack2.state.uri.toString(), '/l2/42?q=xxx');
    });
  });

  group('NotFound', () {
    testWidgets('has "empty" function overrides, but has a state',
        (tester) async {
      BuildContext? testContext;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            testContext = context;
            return Container();
          },
        ),
      );

      final notFound = NotFound(path: '/test');
      expect(notFound.pathPatterns, []);
      expect(notFound.buildPages(testContext!, BeamState()), []);
      expect(notFound.state.uri.toString(), '/test');
    });
  });

  group('EmptyBeamStack', () {
    testWidgets('has "empty" function overrides', (tester) async {
      BuildContext? testContext;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            testContext = context;
            return Container();
          },
        ),
      );

      final notFound = EmptyBeamStack();
      expect(notFound.pathPatterns, []);
      expect(notFound.buildPages(testContext!, BeamState()), []);
    });
  });

  group('State', () {
    test('updating state directly will add to history', () {
      final beamStack = Stack1();
      expect(beamStack.history.length, 1);
      expect(beamStack.history[0].routeInformation.uri.path, '/');

      beamStack.state = BeamState.fromUriString('/l1');
      expect(beamStack.history.length, 2);
      expect(beamStack.history[1].routeInformation.uri.path, '/l1');
    });
  });

  group('Listeners', () {
    testWidgets('are registered after beamBack', (tester) async {
      final beamStack1 = Stack1();
      final beamStack2 = Stack2();

      final beamerDelegate = BeamerDelegate(
        initialPath: '/l1',
        stackBuilder: BeamerStackBuilder(
          beamStacks: [
            beamStack1,
            beamStack2,
          ],
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerDelegate: beamerDelegate,
          routeInformationParser: BeamerParser(),
        ),
      );
      expect(beamerDelegate.currentBeamStack, isA<Stack1>());
      expect(
        (beamerDelegate.currentBeamStack as Stack1).doesHaveListeners,
        true,
      );

      beamerDelegate.beamToNamed('/l2');
      expect(beamerDelegate.currentBeamStack, isA<Stack2>());
      expect(
        (beamerDelegate.currentBeamStack as Stack2).doesHaveListeners,
        true,
      );

      beamerDelegate.beamBack();
      expect(beamerDelegate.currentBeamStack, isA<Stack1>());
      expect(
        (beamerDelegate.currentBeamStack as Stack1).doesHaveListeners,
        true,
      );
    });
  });

  testWidgets('strict path patterns', (tester) async {
    final delegate = BeamerDelegate(
      stackBuilder: BeamerStackBuilder(
        beamStacks: [StrictPatternsStack()],
      ),
    );

    await tester.pumpWidget(
      MaterialApp.router(
        routerDelegate: delegate,
        routeInformationParser: BeamerParser(),
      ),
    );

    expect(delegate.currentBeamStack, isA<NotFound>());

    delegate.beamToNamed('/strict');
    expect(delegate.currentBeamStack, isA<StrictPatternsStack>());

    delegate.beamToNamed('/strict/deeper');
    expect(delegate.currentBeamStack, isA<StrictPatternsStack>());

    delegate.beamToNamed('/');
    expect(delegate.currentBeamStack, isA<NotFound>());
  });

  group('pattern matching', () {
    test('pattern matching works correctly when choosing routes', () {
      void checkMatch(
        String routeMatcher,
        String routeToBeMatched,
        bool shouldMatch,
      ) {
        expect(
          RoutesBeamStack.chooseRoutes(
            RouteInformation(uri: Uri.parse(routeToBeMatched)),
            [routeMatcher],
          ),
          shouldMatch ? isNotEmpty : isEmpty,
        );
      }

      checkMatch('*', '/', true);
      checkMatch('*', '/home', true);
      checkMatch('*', '/home/one/two', true);
      checkMatch('*', 'pretty much anything', true);
      checkMatch('/*', '/home', true);
      checkMatch('/*', '/home/one/two', true);
      checkMatch('/*', '/', true);
      checkMatch('/home', '/home', true);
      checkMatch('/home', '/home/', true);
      checkMatch('/home/*', '/home/one', true);
      checkMatch('/home/*', '/home/one/two', true);

      checkMatch('*', '', false);
      checkMatch('/*', '', false);
      checkMatch('/*', 'home', false);
      checkMatch('/', '/home', false);
      checkMatch('/home', '/home/one', false);
      checkMatch('/home', '/home/one/two', false);
      checkMatch('/home/*', '/home', false);
      checkMatch('/home/*', '/home/', false);
    });
  });

  group('Lifecycle', () {
    testWidgets('updateState gets called on every beaming', (tester) async {
      final updateStateStub = UpdateStateStub();

      final delegate = BeamerDelegate(
        stackBuilder: BeamerStackBuilder(
          beamStacks: [UpdateStateStubBeamStack(updateStateStub)],
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerDelegate: delegate,
          routeInformationParser: BeamerParser(),
        ),
      );

      registerFallbackValue(RouteInformation(uri: Uri.parse('/')));

      delegate.update(
        configuration: RouteInformation(uri: Uri.parse('/x')),
      );
      verify(() => updateStateStub.call()).called(1);

      delegate.update(
        configuration: RouteInformation(uri: Uri.parse('/x?y=z')),
      );
      verify(() => updateStateStub.call()).called(1);

      delegate.update(
        configuration: RouteInformation(uri: Uri.parse('/x?y=w')),
      );
      verify(() => updateStateStub.call()).called(1);
    });
  });
}
