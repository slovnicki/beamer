import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestLocation extends BeamLocation<BeamState> {
  TestLocation([RouteInformation? routeInformation]) : super(routeInformation);

  @override
  List<String> get pathPatterns => [
        '/books/:bookId/details/buy',
        '/books/:bookId/author/:authorId',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final bookId = state.pathParameters['bookId'];
    final authorId = state.pathParameters['authorId'];
    return [
      BeamPage(
        key: const ValueKey('home'),
        child: Container(),
      ),
      if (state.pathPatternSegments.contains('books'))
        BeamPage(
          key: const ValueKey('books'),
          onPopPage: (context, delegate, _, page) {
            return false;
          },
          child: Container(),
        ),
      if (bookId != null)
        BeamPage(
          key: ValueKey('book-$bookId'),
          path: '/books/$bookId',
          popToNamed: '/',
          child: Container(),
        ),
      if (authorId != null)
        BeamPage(
          key: ValueKey('author-$authorId'),
          child: Container(),
        ),
      if (state.pathPatternSegments.contains('details'))
        BeamPage(
          key: ValueKey('book-$bookId-details'),
          onPopPage: (context, delegate, _, page) {
            delegate.currentBeamLocation.update(
              (state) => (state as BeamState).copyWith(
                pathPatternSegments: ['books'],
                pathParameters: {},
              ),
            );
            return true;
          },
          child: Container(),
        ),
      if (state.pathPatternSegments.contains('buy'))
        BeamPage(
          key: ValueKey('book-$bookId-buy'),
          child: Container(),
        ),
    ];
  }
}

void main() {
  group('Hash & Equality', () {
    test('equal', () {
      final state1 = BeamState.fromUri(Uri.parse('/test'));
      final state2 = BeamState.fromUri(Uri.parse('/test'));
      expect(state1 == state2, isTrue);

      final routeState = {'x': 'y'};
      final state3 =
          BeamState.fromUri(Uri.parse('/test'), routeState: routeState);
      final state4 =
          BeamState.fromUri(Uri.parse('/test'), routeState: routeState);
      expect(state3 == state4, isTrue);

      final set1 = <BeamState>{state1, state2};
      expect(set1.length, 1);
    });

    test('not equal', () {
      final state1 = BeamState.fromUri(Uri.parse('/test1'));
      final state2 = BeamState.fromUri(Uri.parse('/test2'));
      expect(state1 == state2, isFalse);

      final state3 =
          BeamState.fromUri(Uri.parse('/test'), routeState: {'x': 'y'});
      final state4 = BeamState.fromUri(Uri.parse('/test'));
      expect(state3 == state4, isFalse);

      final state5 =
          BeamState.fromUri(Uri.parse('/test'), routeState: {'x': 'y'});
      final state6 =
          BeamState.fromUri(Uri.parse('/test'), routeState: {'x': 'z'});
      expect(state5 == state6, isFalse);

      final state7 =
          BeamState.fromUri(Uri.parse('/test1'), routeState: {'x': 'y'});
      final state8 =
          BeamState.fromUri(Uri.parse('/test2'), routeState: {'x': 'y'});
      expect(state7 == state8, isFalse);

      final set1 = <BeamState>{state1, state2};
      expect(set1.length, 2);
    });
  });

  group('Pops', () {
    testWidgets('path parameter is removed on pop', (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/:id': (context, state, data) => Container(),
          },
        ),
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/my-id');
      await tester.pump();
      expect(
          (delegate.currentBeamLocation.state as BeamState)
              .pathParameters['id'],
          'my-id');

      delegate.navigator.pop();
      await tester.pump();
      expect(
          (delegate.currentBeamLocation.state as BeamState).pathParameters, {});
    });

    final delegate = BeamerDelegate(
      locationBuilder: BeamerLocationBuilder(
        beamLocations: [TestLocation()],
      ),
    );

    testWidgets('onPopPage returning false is not popped', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books');
      await tester.pumpAndSettle();
      expect(delegate.currentPages.length, 2);
      expect(delegate.currentPages.last.key, const ValueKey('books'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 2);
      expect(delegate.currentPages.last.key, const ValueKey('books'));
    });

    testWidgets('popToNamed pops to given URI', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books/1');
      await tester.pump();
      expect(delegate.currentPages.length, 3);
      expect(delegate.currentPages.last.key, const ValueKey('book-1'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 1);
      expect(delegate.currentPages.last.key, const ValueKey('home'));
    });

    testWidgets('popToNamed clears history', (tester) async {
      delegate.beamingHistory.clear();
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books/1');
      await tester.pump();
      expect(delegate.beamingHistory.last.history.length, 2);

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.beamingHistory.last.history.length, 1);
    });

    testWidgets('onPopPage that updates location pops correctly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books/1/details');
      await tester.pump();
      expect(delegate.currentPages.length, 4);
      expect(delegate.currentPages.last.key, const ValueKey('book-1-details'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 2);
      expect(delegate.currentPages.last.key, const ValueKey('books'));
    });

    testWidgets('no customization pops normally', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books/1/details/buy');
      await tester.pump();
      expect(delegate.currentPages.length, 5);
      expect(delegate.currentPages.last.key, const ValueKey('book-1-buy'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 4);
      expect(delegate.currentPages.last.key, const ValueKey('book-1-details'));
    });

    testWidgets('subsequent pops work', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books/1/details');
      await tester.pump();
      expect(delegate.currentPages.length, 4);
      expect(delegate.currentPages.last.key, const ValueKey('book-1-details'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 2);
      expect(delegate.currentPages.last.key, const ValueKey('books'));

      delegate.beamToNamed('/books/1/details');
      await tester.pump();
      expect(delegate.currentPages.length, 4);
      expect(delegate.currentPages.last.key, const ValueKey('book-1-details'));

      delegate.navigator.pop();
      await tester.pump(const Duration(seconds: 1));
      expect(delegate.currentPages.length, 2);
      expect(delegate.currentPages.last.key, const ValueKey('books'));
    });

    testWidgets('query is kept on pop', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books/1/details?x=y');
      await tester.pump();
      expect(
        (delegate.currentBeamLocation.state as BeamState).uri.path,
        equals('/books/1/details'),
      );
      expect(
        (delegate.currentBeamLocation.state as BeamState).queryParameters,
        equals({'x': 'y'}),
      );

      delegate.beamToNamed('/books/1/details/buy');
      await tester.pump();
      expect(
        (delegate.currentBeamLocation.state as BeamState).uri.path,
        equals('/books/1/details/buy'),
      );
      expect((delegate.currentBeamLocation.state as BeamState).queryParameters,
          equals({}));

      delegate.navigator.pop();
      await tester.pump();
      expect(
        (delegate.currentBeamLocation.state as BeamState).uri.path,
        equals('/books/1/details'),
      );
      expect(
        (delegate.currentBeamLocation.state as BeamState).queryParameters,
        equals({'x': 'y'}),
      );
    });

    testWidgets('popBeamLocationOnPop does nothing in single location case',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books/1', popBeamLocationOnPop: true);
      await tester.pump();
      expect(delegate.currentPages.length, 3);
      expect(delegate.currentPages.last.key, const ValueKey('book-1'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 3);
      expect(delegate.currentPages.last.key, const ValueKey('book-1'));
    });

    testWidgets('beamBackOnPop works', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books/1');
      await tester.pump();
      expect(delegate.currentPages.length, 3);
      expect(delegate.currentPages.last.key, const ValueKey('book-1'));

      delegate.beamToNamed('/books/2', beamBackOnPop: true);
      await tester.pump();
      expect(delegate.currentPages.length, 3);
      expect(delegate.currentPages.last.key, const ValueKey('book-2'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 3);
      expect(delegate.currentPages.last.key, const ValueKey('book-1'));
      expect(delegate.configuration.uri.path, '/books/1');
    });

    testWidgets('pop removes from beamStateHistory', (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
            '/test/2': (context, state, data) => Container(),
            '/xx': (context, state, data) => Container(),
            '/xx/2': (context, state, data) => Container(),
          },
        ),
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/test');
      await tester.pump();
      final lastBeamLocationHistory = delegate.beamingHistory.last.history;
      expect(lastBeamLocationHistory.length, 2);
      expect(lastBeamLocationHistory[0].routeInformation.uri.path, '/');
      expect(lastBeamLocationHistory[1].routeInformation.uri.path, '/test');
      expect(
          (delegate.currentBeamLocation.state as BeamState).uri.path, '/test');

      delegate.beamToNamed('/test/2');
      await tester.pump();
      expect(lastBeamLocationHistory.length, 3);
      expect(lastBeamLocationHistory[0].routeInformation.uri.path, '/');
      expect(lastBeamLocationHistory[1].routeInformation.uri.path, '/test');
      expect(lastBeamLocationHistory[2].routeInformation.uri.path, '/test/2');
      expect((delegate.currentBeamLocation.state as BeamState).uri.path,
          '/test/2');

      delegate.navigator.pop();
      await tester.pump();
      expect(lastBeamLocationHistory.length, 2);
      expect(lastBeamLocationHistory[0].routeInformation.uri.path, '/');
      expect(lastBeamLocationHistory[1].routeInformation.uri.path, '/test');
      expect(
          (delegate.currentBeamLocation.state as BeamState).uri.path, '/test');

      delegate.beamToNamed('/xx');
      await tester.pump();
      expect(lastBeamLocationHistory.length, 3);
      expect(lastBeamLocationHistory[0].routeInformation.uri.path, '/');
      expect(lastBeamLocationHistory[1].routeInformation.uri.path, '/test');
      expect(lastBeamLocationHistory[2].routeInformation.uri.path, '/xx');
      expect((delegate.currentBeamLocation.state as BeamState).uri.path, '/xx');

      delegate.beamToNamed('/xx/2');
      await tester.pump();
      expect(lastBeamLocationHistory.length, 4);
      expect(lastBeamLocationHistory[0].routeInformation.uri.path, '/');
      expect(lastBeamLocationHistory[1].routeInformation.uri.path, '/test');
      expect(lastBeamLocationHistory[2].routeInformation.uri.path, '/xx');
      expect(lastBeamLocationHistory[3].routeInformation.uri.path, '/xx/2');
      expect(
          (delegate.currentBeamLocation.state as BeamState).uri.path, '/xx/2');

      delegate.navigator.pop();
      await tester.pump();
      expect(lastBeamLocationHistory.length, 3);
      expect(lastBeamLocationHistory[0].routeInformation.uri.path, '/');
      expect(lastBeamLocationHistory[1].routeInformation.uri.path, '/test');
      expect(lastBeamLocationHistory[2].routeInformation.uri.path, '/xx');
      expect((delegate.currentBeamLocation.state as BeamState).uri.path, '/xx');

      delegate.beamBack();
      expect(lastBeamLocationHistory.length, 2);
      expect(lastBeamLocationHistory[0].routeInformation.uri.path, '/');
      expect(lastBeamLocationHistory[1].routeInformation.uri.path, '/test');
      expect(
          (delegate.currentBeamLocation.state as BeamState).uri.path, '/test');
    });

    testWidgets('pageless', (tester) async {
      final delegate = BeamerDelegate(
        transitionDelegate: const NoAnimationTransitionDelegate(),
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => const Scaffold(body: Text('0')),
            '/1': (context, state, data) => BeamPage(
                  key: const ValueKey('/1'),
                  child: Scaffold(
                    body: ElevatedButton(
                      onPressed: () => showDialog(
                        context: Beamer.of(context).navigator.context,
                        builder: (context) => const Text('1.1'),
                      ),
                      child: const Text('1'),
                    ),
                  ),
                ),
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      expect(find.text('0'), findsOneWidget);

      delegate.beamToNamed('/1');
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(find.text('1.1'), findsOneWidget);
      delegate.navigator.pop();
      await tester.pump();
      expect(find.text('1.1'), findsNothing);
      expect(delegate.configuration.uri.path, '/1');
    });

    testWidgets('routePop works', (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/test': (context, state, data) => Container(),
            '/test/2': (context, state, data) => BeamPage(
                  onPopPage: BeamPage.routePop,
                  child: Container(),
                ),
          },
        ),
      );
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      expect(delegate.configuration.uri.path, '/');

      delegate.beamToNamed('/test/2');
      await tester.pump();
      expect(delegate.configuration.uri.path, '/test/2');

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.configuration.uri.path, '/');
    });

    testWidgets('path of previous page is popped to in BeamLocation',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books/1/author/2');
      await tester.pump();
      expect(delegate.currentPages.length, 4);
      expect(delegate.currentPages.last.key, const ValueKey('author-2'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 3);
      expect(delegate.currentPages.last.key, const ValueKey('book-1'));
      expect(delegate.configuration.uri.path, '/books/1');
    });

    testWidgets('path of previous page is popped to in RoutesLocationBuilder',
        (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => Container(),
            '/books/1': (context, state, data) => Container(),
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books/1');
      await tester.pump();
      expect(delegate.currentPages.length, 2);
      expect(delegate.configuration.uri.path, '/books/1');

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 1);
      expect(delegate.configuration.uri.path, '/');
    });
  });

  group('Transitions', () {
    final delegate = BeamerDelegate(
      locationBuilder: RoutesLocationBuilder(
        routes: {
          '/': (context, state, data) => const BeamPage(
                key: ValueKey('/'),
                type: BeamPageType.material,
                child: Scaffold(body: Text('0')),
              ),
          '/1': (context, state, data) => const BeamPage(
                key: ValueKey('/1'),
                type: BeamPageType.cupertino,
                child: Scaffold(body: Text('1')),
              ),
          '/1/2': (context, state, data) => const BeamPage(
                key: ValueKey('/1/2'),
                type: BeamPageType.fadeTransition,
                child: Scaffold(body: Text('2')),
              ),
          '/1/2/3': (context, state, data) => const BeamPage(
                key: ValueKey('/1/2/3'),
                type: BeamPageType.slideTransition,
                child: Scaffold(body: Text('3')),
              ),
          '/1/2/3/4': (context, state, data) => const BeamPage(
                key: ValueKey('/1/2/3/4'),
                type: BeamPageType.scaleTransition,
                child: Scaffold(body: Text('4')),
              ),
          '/1/2/3/4/5': (context, state, data) => const BeamPage(
                key: ValueKey('/1/2/3/4/5'),
                type: BeamPageType.noTransition,
                child: Scaffold(body: Text('5')),
              ),
          '/1/2/3/4/5/6': (context, state, data) => BeamPage(
                key: const ValueKey('/1/2/3/4/5/6'),
                routeBuilder: (context, settings, child) => PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      Scaffold(body: Row(children: [const Text('6'), child])),
                ),
                child: const Text('Child'),
              ),
          '/1/2/3/4/5/6/7': (context, state, data) => const BeamPage(
                key: ValueKey('/1/2/3/4/5/6/7'),
                type: BeamPageType.slideRightTransition,
                child: Scaffold(body: Text('7')),
              ),
          '/1/2/3/4/5/6/7/8': (context, state, data) => const BeamPage(
                key: ValueKey('/1/2/3/4/5/6/7/8'),
                type: BeamPageType.slideLeftTransition,
                child: Scaffold(body: Text('8')),
              ),
          '/1/2/3/4/5/6/7/8/9': (context, state, data) => const BeamPage(
                key: ValueKey('/1/2/3/4/5/6/7/8/9'),
                type: BeamPageType.slideTopTransition,
                child: Scaffold(body: Text('9')),
              ),
        },
      ),
    );
    testWidgets('page based', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      expect(find.text('0'), findsOneWidget);

      delegate.beamToNamed('/1');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 8));
      var offset = tester.getTopLeft(find.text('1'));
      expect(offset.dx, greaterThan(0.0));
      expect(offset.dx, lessThan(800.0));
      expect(offset.dy, equals(0.0));
      expect(offset.dy, equals(0.0));

      delegate.beamToNamed('/1/2');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 8));
      expect(find.text('2'), findsOneWidget);

      delegate.beamToNamed('/1/2/3');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 8));
      offset = tester.getTopLeft(find.text('3'));
      expect(offset.dx, equals(0.0));
      expect(offset.dx, equals(0.0));
      expect(offset.dy, greaterThan(0.0));
      expect(offset.dy, lessThan(600.0));

      delegate.beamToNamed('/1/2/3/4');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 8));
      offset = tester.getTopLeft(find.text('4'));
      expect(offset.dx, greaterThan(0.0));
      expect(offset.dx, lessThan(800.0));
      expect(offset.dy, greaterThan(0.0));
      expect(offset.dy, lessThan(600.0));

      delegate.beamToNamed('/1/2/3/4/5');
      await tester.pump();
      await tester.pump();
      expect(find.text('5'), findsOneWidget);

      delegate.beamToNamed('/1/2/3/4/5/6');
      await tester.pump();
      await tester.pump();
      expect(find.text('6'), findsOneWidget);
      expect(find.text('Child'), findsOneWidget);

      delegate.beamToNamed('/1/2/3/4/5/6/7');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 8));
      offset = tester.getTopLeft(find.text('7'));
      expect(offset.dx, greaterThan(0.0));
      expect(offset.dx, lessThan(800.0));
      expect(offset.dy, equals(0.0));
      expect(offset.dy, equals(0.0));

      delegate.beamToNamed('/1/2/3/4/5/6/7/8');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 8));
      offset = tester.getTopLeft(find.text('8'));
      expect(offset.dx, greaterThan(-800.0));
      expect(offset.dx, lessThan(0.0));
      expect(offset.dy, equals(0.0));
      expect(offset.dy, equals(0.0));

      delegate.beamToNamed('/1/2/3/4/5/6/7/8/9');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 8));
      offset = tester.getTopLeft(find.text('9'));
      expect(offset.dx, equals(0.0));
      expect(offset.dx, equals(0.0));
      expect(offset.dy, greaterThan(-600.0));
      expect(offset.dy, lessThan(0.0));
    });

    testWidgets('pageless no animation transition', (tester) async {
      final delegate = BeamerDelegate(
        transitionDelegate: const NoAnimationTransitionDelegate(),
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => const Scaffold(body: Text('0')),
            '/1': (context, state, data) => BeamPage(
                  key: const ValueKey('/1'),
                  child: Scaffold(
                    body: ElevatedButton(
                      onPressed: () => showDialog(
                        context: Beamer.of(context).navigator.context,
                        builder: (context) => const Text('1.1'),
                      ),
                      child: const Text('1'),
                    ),
                  ),
                ),
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      expect(find.text('0'), findsOneWidget);

      delegate.beamToNamed('/1');
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      expect(find.text('1.1'), findsOneWidget);
      delegate.beamToNamed('/');
      await tester.pump();
      await tester.pump();
      expect(find.text('1.1'), findsNothing);
      expect(find.text('0'), findsOneWidget);
      expect(delegate.configuration.uri.path, '/');
    });

    testWidgets('pageless reverse transition', (tester) async {
      final delegate = BeamerDelegate(
        transitionDelegate: const ReverseTransitionDelegate(),
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '/': (context, state, data) => const Scaffold(body: Text('0')),
            '/1': (context, state, data) => BeamPage(
                  key: const ValueKey('/1'),
                  child: Scaffold(
                    body: ElevatedButton(
                      onPressed: () => showDialog(
                        context: Beamer.of(context).navigator.context,
                        builder: (context) => const Text('1.1'),
                      ),
                      child: const Text('1'),
                    ),
                  ),
                ),
          },
        ),
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerParser(),
          routerDelegate: delegate,
        ),
      );
      expect(find.text('0'), findsOneWidget);

      delegate.beamToNamed('/1');
      await tester.pump();
      await tester.tap(find.text('1'));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1.1'), findsOneWidget);
      delegate.beamToNamed('/');
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('1.1'), findsNothing);
      expect(find.text('0'), findsOneWidget);
      expect(delegate.configuration.uri.path, '/');
    });
  });
}
