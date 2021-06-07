import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestLocation extends BeamLocation {
  TestLocation([BeamState? state]) : super(state);

  @override
  List<String> get pathBlueprints => ['/books/:bookId/details/buy'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('home'),
          child: Container(),
        ),
        if (state.pathBlueprintSegments.contains('books'))
          BeamPage(
            key: ValueKey('books'),
            onPopPage: (context, delegate, page) {
              return false;
            },
            child: Container(),
          ),
        if (state.pathParameters.containsKey('bookId'))
          BeamPage(
            key: ValueKey('book-${state.pathParameters['bookId']}'),
            popToNamed: '/',
            child: Container(),
          ),
        if (state.pathBlueprintSegments.contains('details'))
          BeamPage(
            key: ValueKey('book-${state.pathParameters['bookId']}-details'),
            onPopPage: (context, delegate, page) {
              delegate.currentBeamLocation.update(
                (state) => state.copyWith(
                  pathBlueprintSegments: ['books'],
                  pathParameters: {},
                ),
              );
              return true;
            },
            child: Container(),
          ),
        if (state.pathBlueprintSegments.contains('buy'))
          BeamPage(
            key: ValueKey('book-${state.pathParameters['bookId']}-buy'),
            child: Container(),
          ),
      ];
}

void main() {
  group('Hash & Equality', () {
    test('equal', () {
      final state1 = BeamState.fromUri(Uri.parse('/test'));
      final state2 = BeamState.fromUri(Uri.parse('/test'));
      expect(state1 == state2, isTrue);

      final state3 = BeamState.fromUri(Uri.parse('/test'), data: {'x': 'y'});
      final state4 = BeamState.fromUri(Uri.parse('/test'), data: {'x': 'y'});
      expect(state3 == state4, isTrue);

      final set1 = <BeamState>{state1, state2};
      expect(set1.length, 1);
    });

    test('not equal', () {
      final state1 = BeamState.fromUri(Uri.parse('/test1'));
      final state2 = BeamState.fromUri(Uri.parse('/test2'));
      expect(state1 == state2, isFalse);

      final state3 = BeamState.fromUri(Uri.parse('/test'), data: {'x': 'y'});
      final state4 = BeamState.fromUri(Uri.parse('/test'));
      expect(state3 == state4, isFalse);

      final state5 = BeamState.fromUri(Uri.parse('/test'), data: {'x': 'y'});
      final state6 = BeamState.fromUri(Uri.parse('/test'), data: {'x': 'z'});
      expect(state5 == state6, isFalse);

      final state7 = BeamState.fromUri(Uri.parse('/test1'), data: {'x': 'y'});
      final state8 = BeamState.fromUri(Uri.parse('/test2'), data: {'x': 'y'});
      expect(state7 == state8, isFalse);

      final set1 = <BeamState>{state1, state2};
      expect(set1.length, 2);
    });
  });

  group('Pops', () {
    testWidgets('path parameter is removed on pop', (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: SimpleLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/:id': (context, state) => Container(),
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
      expect(delegate.currentBeamLocation.state.pathParameters['id'], 'my-id');

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentBeamLocation.state.pathParameters, {});
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
      await tester.pump();
      expect(delegate.currentPages.length, 2);
      expect(delegate.currentPages.last.key, ValueKey('books'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 2);
      expect(delegate.currentPages.last.key, ValueKey('books'));
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
      expect(delegate.currentPages.last.key, ValueKey('book-1'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 1);
      expect(delegate.currentPages.last.key, ValueKey('home'));
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
      expect(delegate.currentPages.last.key, ValueKey('book-1-details'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 2);
      expect(delegate.currentPages.last.key, ValueKey('books'));
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
      expect(delegate.currentPages.last.key, ValueKey('book-1-buy'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 4);
      expect(delegate.currentPages.last.key, ValueKey('book-1-details'));
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
      expect(delegate.currentPages.last.key, ValueKey('book-1-details'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 2);
      expect(delegate.currentPages.last.key, ValueKey('books'));

      delegate.beamToNamed('/books/1/details');
      await tester.pump();
      expect(delegate.currentPages.length, 4);
      expect(delegate.currentPages.last.key, ValueKey('book-1-details'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 2);
      expect(delegate.currentPages.last.key, ValueKey('books'));
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
        delegate.currentBeamLocation.state.uri.path,
        equals('/books/1/details'),
      );
      expect(
        delegate.currentBeamLocation.state.queryParameters,
        equals({'x': 'y'}),
      );

      delegate.beamToNamed('/books/1/details/buy');
      await tester.pump();
      expect(
        delegate.currentBeamLocation.state.uri.path,
        equals('/books/1/details/buy'),
      );
      expect(delegate.currentBeamLocation.state.queryParameters, equals({}));

      delegate.navigator.pop();
      await tester.pump();
      expect(
        delegate.currentBeamLocation.state.uri.path,
        equals('/books/1/details'),
      );
      expect(
        delegate.currentBeamLocation.state.queryParameters,
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
      expect(delegate.currentPages.last.key, ValueKey('book-1'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 3);
      expect(delegate.currentPages.last.key, ValueKey('book-1'));
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
      expect(delegate.currentPages.last.key, ValueKey('book-1'));

      delegate.beamToNamed('/books/2', beamBackOnPop: true);
      await tester.pump();
      expect(delegate.currentPages.length, 3);
      expect(delegate.currentPages.last.key, ValueKey('book-2'));

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 3);
      expect(delegate.currentPages.last.key, ValueKey('book-1'));
      expect(delegate.state.uri.path, '/books/1');
    });

    testWidgets('pop removes from beamStateHistory', (tester) async {
      final delegate = BeamerDelegate(
        locationBuilder: SimpleLocationBuilder(
          routes: {
            '/': (context, state) => Container(),
            '/test': (context, state) => Container(),
            '/test/2': (context, state) => Container(),
            '/xx': (context, state) => Container(),
            '/xx/2': (context, state) => Container(),
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
      expect(delegate.beamStateHistory.length, 2);
      expect(delegate.beamStateHistory[0].uri.path, '/');
      expect(delegate.beamStateHistory[1].uri.path, '/test');
      expect(delegate.currentBeamLocation.state.uri.path, '/test');

      delegate.beamToNamed('/test/2');
      await tester.pump();
      expect(delegate.beamStateHistory.length, 3);
      expect(delegate.beamStateHistory[0].uri.path, '/');
      expect(delegate.beamStateHistory[1].uri.path, '/test');
      expect(delegate.beamStateHistory[2].uri.path, '/test/2');
      expect(delegate.currentBeamLocation.state.uri.path, '/test/2');

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.beamStateHistory.length, 2);
      expect(delegate.beamStateHistory[0].uri.path, '/');
      expect(delegate.beamStateHistory[1].uri.path, '/test');
      expect(delegate.currentBeamLocation.state.uri.path, '/test');

      delegate.beamToNamed('/xx');
      await tester.pump();
      expect(delegate.beamStateHistory.length, 3);
      expect(delegate.beamStateHistory[0].uri.path, '/');
      expect(delegate.beamStateHistory[1].uri.path, '/test');
      expect(delegate.beamStateHistory[2].uri.path, '/xx');
      expect(delegate.currentBeamLocation.state.uri.path, '/xx');

      delegate.beamToNamed('/xx/2');
      await tester.pump();
      expect(delegate.beamStateHistory.length, 4);
      expect(delegate.beamStateHistory[0].uri.path, '/');
      expect(delegate.beamStateHistory[1].uri.path, '/test');
      expect(delegate.beamStateHistory[2].uri.path, '/xx');
      expect(delegate.beamStateHistory[3].uri.path, '/xx/2');
      expect(delegate.currentBeamLocation.state.uri.path, '/xx/2');

      delegate.navigator.pop();
      await tester.pump();
      expect(delegate.beamStateHistory.length, 3);
      expect(delegate.beamStateHistory[0].uri.path, '/');
      expect(delegate.beamStateHistory[1].uri.path, '/test');
      expect(delegate.beamStateHistory[2].uri.path, '/xx');
      expect(delegate.currentBeamLocation.state.uri.path, '/xx');

      delegate.beamBack();
      expect(delegate.beamStateHistory.length, 2);
      expect(delegate.beamStateHistory[0].uri.path, '/');
      expect(delegate.beamStateHistory[1].uri.path, '/test');
      expect(delegate.currentBeamLocation.state.uri.path, '/test');
    });
  });

  group('Transitions', () {
    final delegate = BeamerDelegate(
      locationBuilder: SimpleLocationBuilder(
        routes: {
          '/': (context, state) => BeamPage(
                key: ValueKey('/'),
                type: BeamPageType.material,
                child: Scaffold(body: Container(child: Text('0'))),
              ),
          '/1': (context, state) => BeamPage(
                key: ValueKey('/1'),
                type: BeamPageType.cupertino,
                child: Scaffold(body: Container(child: Text('1'))),
              ),
          '/1/2': (context, state) => BeamPage(
                key: ValueKey('/1/2'),
                type: BeamPageType.fadeTransition,
                child: Scaffold(body: Container(child: Text('2'))),
              ),
          '/1/2/3': (context, state) => BeamPage(
                key: ValueKey('/1/2/3'),
                type: BeamPageType.slideTransition,
                child: Scaffold(body: Container(child: Text('3'))),
              ),
          '/1/2/3/4': (context, state) => BeamPage(
                key: ValueKey('/1/2/3/4'),
                type: BeamPageType.scaleTransition,
                child: Scaffold(body: Container(child: Text('4'))),
              ),
          '/1/2/3/4/5': (context, state) => BeamPage(
                key: ValueKey('/1/2/3/4/5'),
                type: BeamPageType.noTransition,
                child: Scaffold(body: Container(child: Text('5'))),
              ),
          '/1/2/3/4/5/6': (context, state) => BeamPage(
                key: ValueKey('/1/2/3/4/5/6'),
                pageRouteBuilder: (settings, child) => PageRouteBuilder(
                  settings: settings,
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      child,
                ),
                child: Scaffold(body: Container(child: Text('6'))),
              ),
        },
      ),
    );
    testWidgets('all', (tester) async {
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
    });
  });
}
