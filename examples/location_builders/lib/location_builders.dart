import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'screens.dart';
import 'data.dart';

// OPTION A: SimpleLocationBuilder
final simpleLocationBuilder = SimpleLocationBuilder(
  routes: {
    '/': (context) => BeamPage(
          key: ValueKey('home'),
          title: 'Home',
          child: HomeScreen(),
        ),
    '/books': (context) => BeamPage(
          key: ValueKey('books'),
          title: 'Books',
          child: BooksScreen(),
        ),
    '/books/:bookId': (context) {
      final book = books.firstWhere((book) =>
          book['id'] ==
          context.currentBeamLocation.state.pathParameters['bookId']);

      return BeamPage(
        key: ValueKey('book-${book['id']}'),
        title: book['title'],
        child: BookDetailsScreen(book: book),
      );
    }
  },
);

// OPTION B: BeamerLocationBuilder
final beamerLocationBuilder = BeamerLocationBuilder(
  beamLocations: [
    HomeLocation(),
    BooksLocation(),
  ],
);

class HomeLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) {
    return [
      BeamPage(
        key: ValueKey('home'),
        title: 'Home',
        child: HomeScreen(),
      ),
    ];
  }
}

class BooksLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/books/:bookId'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) {
    return [
      ...HomeLocation().pagesBuilder(context, state),
      if (state.uri.pathSegments.contains('books'))
        BeamPage(
          key: ValueKey('books'),
          title: 'Books',
          child: BooksScreen(),
        ),
      if (state.pathParameters.containsKey('bookId'))
        BeamPage(
          key: ValueKey('book-${state.pathParameters['bookId']}'),
          title: books.firstWhere((book) =>
              book['id'] ==
              context
                  .currentBeamLocation.state.pathParameters['bookId'])['title'],
          child: BookDetailsScreen(
            book: books.firstWhere((book) =>
                book['id'] ==
                context.currentBeamLocation.state.pathParameters['bookId']),
          ),
        ),
    ];
  }
}
