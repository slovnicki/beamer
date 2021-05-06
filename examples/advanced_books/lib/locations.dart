import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'books_data.dart';
import 'home_screen.dart';
import 'book_screens/screens.dart';

class HomeLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('home'),
          title: 'Home',
          child: HomeScreen(),
        ),
      ];
}

class BooksLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => [
        'books/:bookId/genres/:genreId',
        'books/:bookId/buy',
      ];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) {
    final beamPages = [...HomeLocation().pagesBuilder(context, state)];

    if (state.pathBlueprintSegments.contains('books')) {
      final _titleQuery = state.queryParameters['title'] ?? '';
      final _genreQuery = state.queryParameters['genre'] ?? '';
      final _title = _titleQuery != ''
          ? "Books with name '$_titleQuery'"
          : _genreQuery != ''
              ? "Books with genre '$_genreQuery'"
              : 'All Books';
      final _books = _titleQuery != ''
          ? books.where((book) =>
              book['title'].toLowerCase().contains(_titleQuery.toLowerCase()))
          : _genreQuery != ''
              ? books.where((book) => book['genres'].contains(_genreQuery))
              : books;

      beamPages.add(
        BeamPage(
          key: ValueKey('books-$_titleQuery-$_genreQuery'),
          title: _title,
          child: BooksScreen(
            title: _title,
            books: _books.toList(),
          ),
        ),
      );
    }

    if (state.pathParameters.containsKey('bookId')) {
      final _bookId = state.pathParameters['bookId'];
      final _book = books.firstWhere((book) => book['id'] == _bookId);

      beamPages.add(
        BeamPage(
          key: ValueKey('book-$_bookId'),
          title: _book['title'],
          child: BookDetailsScreen(book: _book),
        ),
      );
    }

    if (state.uri.pathSegments.contains('genres')) {
      final _bookId = state.pathParameters['bookId'];
      final _book = books.firstWhere((book) => book['id'] == _bookId);
      final _title = "${_book['title']}'s Genres";

      beamPages.add(
        BeamPage(
          key: ValueKey('book-$_bookId-genres'),
          title: _title,
          child: BookGenresScreen(
            book: _book,
            title: _title,
          ),
        ),
      );
    }

    if (state.uri.pathSegments.contains('buy')) {
      final _bookId = state.pathParameters['bookId'];
      final _book = books.firstWhere((book) => book['id'] == _bookId);
      final _title = 'Buy ${_book['title']}';

      beamPages.add(
        BeamPage(
          key: ValueKey('book-$_bookId-buy'),
          title: _title,
          child: BookBuyScreen(
            book: _book,
            title: _title,
          ),
        ),
      );
    }

    return beamPages;
  }
}
