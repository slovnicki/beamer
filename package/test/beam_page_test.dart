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
            onPopPage: (context, location, page) {
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
            onPopPage: (context, location, page) {
              location.update(
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
  TestWidgetsFlutterBinding.ensureInitialized();
  final delegate = BeamerRouterDelegate(
    locationBuilder: (state) => TestLocation(state),
  );
  delegate.beamToNamed('/');

  group('Pops', () {
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
  });
}
