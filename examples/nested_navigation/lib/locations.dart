import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

import 'screens.dart';

class HomeLocation extends BeamLocation<BeamState> {
  HomeLocation(RouteInformation routeInformation) : super(routeInformation);
  @override
  List<String> get pathPatterns => ['/*'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('home-${state.uri}'),
          title: 'Home',
          child: HomeScreen(),
        )
      ];
}

class BooksLocation extends BeamLocation<BeamState> {
  BooksLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<String> get pathPatterns => ['/books/*'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('books'),
          title: 'Books',
          child: BooksScreen(),
        )
      ];
}

class BooksContentLocation extends BeamLocation<BeamState> {
  BooksContentLocation(RouteInformation routeInformation)
      : super(routeInformation);

  @override
  List<String> get pathPatterns => [
        '/books/authors',
        '/books/genres',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('books-home'),
          title: 'Books Home',
          child: BooksHomeScreen(),
        ),
        if (state.pathPatternSegments.contains('authors'))
          BeamPage(
            key: ValueKey('books-authors'),
            title: 'Books Authors',
            child: BookAuthorsScreen(),
          ),
        if (state.pathPatternSegments.contains('genres'))
          BeamPage(
            key: ValueKey('books-genres'),
            title: 'Books Genres',
            child: BookGenresScreen(),
          )
      ];
}

class ArticlesLocation extends BeamLocation<BeamState> {
  ArticlesLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<String> get pathPatterns => ['/articles/*'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('articles'),
          title: 'Articles',
          child: ArticlesScreen(),
        )
      ];
}

class ArticlesContentLocation extends BeamLocation<BeamState> {
  ArticlesContentLocation(RouteInformation routeInformation)
      : super(routeInformation);

  @override
  List<String> get pathPatterns => [
        '/articles/authors',
        '/articles/genres',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('articles-home'),
          title: 'Articles Home',
          child: ArticlesHomeScreen(),
        ),
        if (state.pathPatternSegments.contains('authors'))
          BeamPage(
            key: ValueKey('articles-authors'),
            title: 'Articles Authors',
            child: ArticleAuthorsScreen(),
          ),
        if (state.pathPatternSegments.contains('genres'))
          BeamPage(
            key: ValueKey('articles-genres'),
            title: 'Articles Genres',
            child: ArticleGenresScreen(),
          )
      ];
}
