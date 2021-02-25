import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import './home_screen.dart';
import './books/ui/screens.dart';
import './articles/ui/screens.dart';

class HomeLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('home'),
          child: HomeScreen(),
        ),
      ];
}

class BooksLocation extends BeamLocation {
  BooksLocation({
    String pathBlueprint,
    Map<String, String> pathParameters,
    Map<String, String> queryParameters,
    Map<String, dynamic> data,
  }) : super(
          pathBlueprint: pathBlueprint,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          data: data,
        );

  @override
  List<String> get pathBlueprints => [
        '/books/:bookId/genres/:genreId',
        '/books/:bookId/buy',
      ];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        ...HomeLocation().pagesBuilder(context),
        if (pathSegments.contains('books'))
          BeamPage(
            key: ValueKey('books-${queryParameters['title'] ?? ''}'),
            child: BooksScreen(
              titleQuery: queryParameters['title'] ?? '',
            ),
          ),
        if (pathParameters.containsKey('bookId'))
          BeamPage(
            key: ValueKey('book-${pathParameters['bookId']}'),
            child: BookDetailsScreen(
              bookId: pathParameters['bookId'],
            ),
          ),
        if (pathSegments.contains('buy'))
          BeamPage(
            key: ValueKey('book-${pathParameters['bookId']}-buy'),
            child: BuyScreen(
              book: data['book'],
            ),
          ),
        if (pathSegments.contains('genres'))
          BeamPage(
            key: ValueKey('book-${pathParameters['bookId']}-genres'),
            child: GenresScreen(
              book: data['book'],
            ),
          ),
        if (pathParameters.containsKey('genreId'))
          BeamPage(
            key: ValueKey('genres-${pathParameters['genreId']}'),
            child: GenreDetailsScreen(
              genre: data['genre'],
            ),
          ),
      ];
}

class ArticlesLocation extends BeamLocation {
  ArticlesLocation({
    String pathBlueprint,
    Map<String, String> pathParameters,
    Map<String, String> queryParameters,
    Map<String, dynamic> data,
  }) : super(
          pathBlueprint: pathBlueprint,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          data: data,
        );

  @override
  List<String> get pathBlueprints => ['/articles/:articleId'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        ...HomeLocation().pagesBuilder(context),
        if (pathSegments.contains('articles'))
          BeamPage(
            key: ValueKey('articles'),
            child: ArticlesScreen(),
          ),
        if (pathParameters.containsKey('articleId'))
          BeamPage(
            key: ValueKey('articles-${pathParameters['articleId']}'),
            child: ArticleDetailsScreen(
              articleId: pathParameters['articleId'],
            ),
          ),
      ];
}
