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
      final _pageTitle = _titleQuery != ''
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
          title: _pageTitle,
          child: BooksScreen(
            books: _books.toList(),
            title: _pageTitle,
          ),
        ),
      );
    }

    if (state.pathParameters.containsKey('bookId')) {
      final _bookId = state.pathParameters['bookId'];
      final _book = books.firstWhere((book) => book['id'] == _bookId);
      final _pageTitle = _book['title'];

      beamPages.add(
        BeamPage(
          key: ValueKey('book-$_bookId'),
          title: _pageTitle,
          child: BookDetailsScreen(
            book: _book,
            title: _pageTitle,
          ),
        ),
      );
    }

    if (state.uri.pathSegments.contains('genres')) {
      final _bookId = state.pathParameters['bookId'];
      final _book = books.firstWhere((book) => book['id'] == _bookId);
      final _pageTitle = "${_book['title']}'s Genres";

      beamPages.add(
        BeamPage(
          key: ValueKey('book-$_bookId-genres'),
          title: _pageTitle,
          child: BookGenresScreen(
            book: _book,
            title: _pageTitle,
          ),
        ),
      );
    }

    if (state.uri.pathSegments.contains('buy')) {
      final _bookId = state.pathParameters['bookId'];
      final _book = books.firstWhere((book) => book['id'] == _bookId);
      final _pageTitle = 'Buy ${_book['title']}';

      beamPages.add(
        BeamPage(
          key: ValueKey('book-$_bookId-buy'),
          title: _pageTitle,
          child: BookBuyScreen(
            book: _book,
            title: _pageTitle,
          ),
        ),
      );
    }

    return beamPages;
  }
}
