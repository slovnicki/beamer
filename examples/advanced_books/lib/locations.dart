import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import './home_screen.dart';
import './books/ui/screens.dart';
import './articles/ui/screens.dart';

class HomeLocation extends BeamLocation {
  HomeLocation(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => ['/'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('home'),
          child: HomeScreen(),
        ),
      ];
}

class BooksLocation extends BeamLocation {
  BooksLocation(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => [
        '/books/:bookId/genres/:genreId',
        '/books/:bookId/buy',
      ];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        ...HomeLocation(state).pagesBuilder(context, state),
        if (state.pathBlueprintSegments.contains('books'))
          BeamPage(
            key: ValueKey('books-${state.queryParameters['title'] ?? ''}'),
            child: BooksScreen(
              titleQuery: state.queryParameters['title'] ?? '',
            ),
          ),
        if (state.pathParameters.containsKey('bookId'))
          BeamPage(
            key: ValueKey('book-${state.pathParameters['bookId']}'),
            child: BookDetailsScreen(
              bookId: state.pathParameters['bookId'],
            ),
          ),
        if (state.uri.pathSegments.contains('buy'))
          BeamPage(
            key: ValueKey('book-${state.pathParameters['bookId']}-buy'),
            child: BuyScreen(
              book: state.data['book'],
            ),
          ),
        if (state.uri.pathSegments.contains('genres'))
          BeamPage(
            key: ValueKey('book-${state.pathParameters['bookId']}-genres'),
            child: GenresScreen(
              book: state.data['book'],
            ),
          ),
        if (state.pathParameters.containsKey('genreId'))
          BeamPage(
            key: ValueKey('genres-${state.pathParameters['genreId']}'),
            child: GenreDetailsScreen(
              genre: state.data['genre'],
            ),
          ),
      ];
}

class ArticlesLocation extends BeamLocation {
  ArticlesLocation(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => ['/articles/:articleId'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        ...HomeLocation(state).pagesBuilder(context, state),
        if (state.uri.pathSegments.contains('articles'))
          BeamPage(
            key: ValueKey('articles'),
            child: ArticlesScreen(),
          ),
        if (state.pathParameters.containsKey('articleId'))
          BeamPage(
            key: ValueKey('articles-${state.pathParameters['articleId']}'),
            child: ArticleDetailsScreen(
              articleId: state.pathParameters['articleId'],
            ),
          ),
      ];
}
