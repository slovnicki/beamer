import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'screens.dart';
import 'data.dart';

// OPTION A:
final simpleLocationBuilder = RoutesLocationBuilder(
  routes: {
    '/': (context, state, data) => BeamPage(
          key: ValueKey('home'),
          title: 'Home',
          child: HomeScreen(),
        ),
    '/books': (context, state, data) => BeamPage(
          key: ValueKey('books'),
          title: 'Books',
          child: BooksScreen(),
        ),
    '/books/:bookId': (context, state, data) {
      final book = books.firstWhere((book) =>
          book['id'] ==
          (context.currentBeamLocation.state as BeamState)
              .pathParameters['bookId']);

      return BeamPage(
        key: ValueKey('book-${book['id']}'),
        title: book['title'],
        child: BookDetailsScreen(book: book),
      );
    }
  },
);

// OPTION B:
final beamerLocationBuilder = BeamerLocationBuilder(
  beamLocations: [
    BooksLocation(),
  ],
);

class BooksLocation extends BeamLocation<BeamState> {
  BooksLocation({RouteInformation? routeInformation}) : super(routeInformation);

  @override
  List<String> get pathPatterns => [
        '/',
        '/books/:bookId',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(
        key: ValueKey('home'),
        title: 'Home',
        child: HomeScreen(),
      ),
      if (state.uri.pathSegments.contains('books'))
        BeamPage(
          key: ValueKey('books'),
          title: 'Books',
          child: BooksScreen(),
        ),
      if (state.pathParameters.containsKey('bookId'))
        BeamPage(
          key: ValueKey('book-${state.pathParameters['bookId']}'),
          title: books.firstWhere(
              (book) => book['id'] == state.pathParameters['bookId'])['title'],
          child: BookDetailsScreen(
            book: books.firstWhere(
                (book) => book['id'] == state.pathParameters['bookId']),
          ),
        ),
    ];
  }
}
