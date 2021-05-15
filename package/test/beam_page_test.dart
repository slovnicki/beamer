import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class TestLocation extends BeamLocation {
  TestLocation(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => ['/books/:bookId/details/buy'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
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
              delegate.currentLocation.update(
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
    final delegate = BeamerRouterDelegate(
      locationBuilder: (state) => TestLocation(state),
    );

    testWidgets('onPopPage returning false is not popped', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerRouteInformationParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books');
      await tester.pump();
      expect(delegate.currentPages.length, 2);
      expect(delegate.currentPages.last.key, ValueKey('books'));

      delegate.navigatorKey.currentState!.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 2);
      expect(delegate.currentPages.last.key, ValueKey('books'));
    });

    testWidgets('popToNamed pops to given URI', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerRouteInformationParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books/1');
      await tester.pump();
      expect(delegate.currentPages.length, 3);
      expect(delegate.currentPages.last.key, ValueKey('book-1'));

      delegate.navigatorKey.currentState!.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 1);
      expect(delegate.currentPages.last.key, ValueKey('home'));
    });

    testWidgets('onPopPage that updates location pops correctly',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerRouteInformationParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books/1/details');
      await tester.pump();
      expect(delegate.currentPages.length, 4);
      expect(delegate.currentPages.last.key, ValueKey('book-1-details'));

      delegate.navigatorKey.currentState!.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 2);
      expect(delegate.currentPages.last.key, ValueKey('books'));
    });

    testWidgets('no customization pops normally', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerRouteInformationParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books/1/details/buy');
      await tester.pump();
      expect(delegate.currentPages.length, 5);
      expect(delegate.currentPages.last.key, ValueKey('book-1-buy'));

      delegate.navigatorKey.currentState!.pop();
      await tester.pump();
      expect(delegate.currentPages.length, 4);
      expect(delegate.currentPages.last.key, ValueKey('book-1-details'));
    });

    testWidgets('query is kept on pop', (tester) async {
      await tester.pumpWidget(
        MaterialApp.router(
          routeInformationParser: BeamerRouteInformationParser(),
          routerDelegate: delegate,
        ),
      );
      delegate.beamToNamed('/books/1/details?x=y');
      await tester.pump();
      expect(
        delegate.currentLocation.state.uri.path,
        equals('/books/1/details'),
      );
      expect(
        delegate.currentLocation.state.queryParameters,
        equals({'x': 'y'}),
      );

      delegate.beamToNamed('/books/1/details/buy');
      await tester.pump();
      expect(
        delegate.currentLocation.state.uri.path,
        equals('/books/1/details/buy'),
      );
      expect(delegate.currentLocation.state.queryParameters, equals({}));

      delegate.navigatorKey.currentState!.pop();
      await tester.pump();
      expect(
        delegate.currentLocation.state.uri.path,
        equals('/books/1/details'),
      );
      expect(
        delegate.currentLocation.state.queryParameters,
        equals({'x': 'y'}),
      );
    });
  });

  group('Transitions', () {
    final delegate = BeamerRouterDelegate(
      locationBuilder: SimpleLocationBuilder(
        routes: {
          '/': (context) => BeamPage(
                key: ValueKey('/'),
                type: BeamPageType.material,
                child: Scaffold(body: Container(child: Text('0'))),
              ),
          '/1': (context) => BeamPage(
                key: ValueKey('/1'),
                type: BeamPageType.cupertino,
                child: Scaffold(body: Container(child: Text('1'))),
              ),
          '/1/2': (context) => BeamPage(
                key: ValueKey('/1/2'),
                type: BeamPageType.fadeTransition,
                child: Scaffold(body: Container(child: Text('2'))),
              ),
          '/1/2/3': (context) => BeamPage(
                key: ValueKey('/1/2/3'),
                type: BeamPageType.slideTransition,
                child: Scaffold(body: Container(child: Text('3'))),
              ),
          '/1/2/3/4': (context) => BeamPage(
                key: ValueKey('/1/2/3/4'),
                type: BeamPageType.scaleTransition,
                child: Scaffold(body: Container(child: Text('4'))),
              ),
          '/1/2/3/4/5': (context) => BeamPage(
                key: ValueKey('/1/2/3/4/5'),
                type: BeamPageType.noTransition,
                child: Scaffold(body: Container(child: Text('5'))),
              ),
          '/1/2/3/4/5/6': (context) => BeamPage(
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
          routeInformationParser: BeamerRouteInformationParser(),
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
