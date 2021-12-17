import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'data.dart' as booksData;
import 'screens/screens.dart';

// OPTION A: SimpleLocationBuilder
final simpleLocationBuilder = RoutesLocationBuilder(
  routes: {
    '/': (context, state, data) => BeamPage(
          key: ValueKey('home'),
          title: 'Home',
          child: HomeScreen(),
        ),
    '/books': (context, state, data) {
      final titleQuery =
          state.queryParameters['title'] ?? (data as Map)['title'] ?? '';
      final genreQuery = state.queryParameters['genre'] ?? '';
      final pageTitle = titleQuery != ''
          ? "Books with name '$titleQuery'"
          : genreQuery != ''
              ? "Books with genre '$genreQuery'"
              : 'All Books';
      final books = titleQuery != ''
          ? booksData.books.where((book) =>
              book['title'].toLowerCase().contains(titleQuery.toLowerCase()))
          : genreQuery != ''
              ? booksData.books
                  .where((book) => book['genres'].contains(genreQuery))
              : booksData.books;

      return BeamPage(
        key: ValueKey('books-$titleQuery-$genreQuery'),
        title: pageTitle,
        child: BooksScreen(
          books: books.toList(),
          title: pageTitle,
        ),
      );
    },
    '/books/:bookId': (context, state, data) {
      final bookId = state.pathParameters['bookId'];
      final book = booksData.books.firstWhere((book) => book['id'] == bookId);
      final pageTitle = book['title'];

      return BeamPage(
        key: ValueKey('book-$bookId'),
        title: pageTitle,
        child: BookDetailsScreen(
          book: book,
          title: pageTitle,
        ),
      );
    },
    '/books/:bookId/genres': (context, state, data) {
      final bookId = state.pathParameters['bookId'];
      final book = booksData.books.firstWhere((book) => book['id'] == bookId);
      final pageTitle = "${book['title']}'s Genres";

      return BeamPage(
        key: ValueKey('book-$bookId-genres'),
        title: pageTitle,
        child: BookGenresScreen(
          book: book,
          title: pageTitle,
        ),
      );
    },
    '/books/:bookId/buy': (context, state, data) {
      final bookId = state.pathParameters['bookId'];
      final book = booksData.books.firstWhere((book) => book['id'] == bookId);
      final pageTitle = 'Buy ${book['title']}';

      return BeamPage(
        key: ValueKey('book-$bookId-buy'),
        title: pageTitle,
        child: BookBuyScreen(
          book: book,
          title: pageTitle,
        ),
      );
    },
  },
);

// OPTION B: BeamerLocationBuilder
final beamerLocationBuilder = BeamerLocationBuilder(
  beamLocations: [
    HomeLocation(),
    BooksLocation(),
  ],
);

class HomeLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('home'),
          title: 'Home',
          child: HomeScreen(),
        ),
      ];
}

class BooksLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => [
        '/books/:bookId/genres/:genreId',
        '/books/:bookId/buy',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final beamPages = [...HomeLocation().buildPages(context, state)];

    if (state.pathPatternSegments.contains('books')) {
      final titleQuery = state.queryParameters['title'] ?? '';
      final genreQuery = state.queryParameters['genre'] ?? '';
      final pageTitle = titleQuery != ''
          ? "Books with name '$titleQuery'"
          : genreQuery != ''
              ? "Books with genre '$genreQuery'"
              : 'All Books';
      final books = titleQuery != ''
          ? booksData.books.where((book) =>
              book['title'].toLowerCase().contains(titleQuery.toLowerCase()))
          : genreQuery != ''
              ? booksData.books
                  .where((book) => book['genres'].contains(genreQuery))
              : booksData.books;

      beamPages.add(
        BeamPage(
          key: ValueKey('books-$titleQuery-$genreQuery'),
          title: pageTitle,
          child: BooksScreen(
            books: books.toList(),
            title: pageTitle,
          ),
        ),
      );
    }

    if (state.pathParameters.containsKey('bookId')) {
      final bookId = state.pathParameters['bookId'];
      final book = booksData.books.firstWhere((book) => book['id'] == bookId);
      final pageTitle = book['title'];

      beamPages.add(
        BeamPage(
          key: ValueKey('book-$bookId'),
          title: pageTitle,
          child: BookDetailsScreen(
            book: book,
            title: pageTitle,
          ),
        ),
      );
    }

    if (state.uri.pathSegments.contains('genres')) {
      final bookId = state.pathParameters['bookId'];
      final book = booksData.books.firstWhere((book) => book['id'] == bookId);
      final pageTitle = "${book['title']}'s Genres";

      beamPages.add(
        BeamPage(
          key: ValueKey('book-$bookId-genres'),
          title: pageTitle,
          child: BookGenresScreen(
            book: book,
            title: pageTitle,
          ),
        ),
      );
    }

    if (state.uri.pathSegments.contains('buy')) {
      final bookId = state.pathParameters['bookId'];
      final book = booksData.books.firstWhere((book) => book['id'] == bookId);
      final pageTitle = 'Buy ${book['title']}';

      beamPages.add(
        BeamPage(
          key: ValueKey('book-$bookId-buy'),
          title: pageTitle,
          child: BookBuyScreen(
            book: book,
            title: pageTitle,
          ),
        ),
      );
    }

    return beamPages;
  }
}
