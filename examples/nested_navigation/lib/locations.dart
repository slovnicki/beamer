import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';
import './screens.dart';

class HomeLocation extends BeamLocation {
  HomeLocation(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => ['/*'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('home-${state.uri}'),
          child: HomeScreen(),
        )
      ];
}

class BooksLocation extends BeamLocation {
  BooksLocation(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => ['/books/*'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('books'),
          child: BooksScreen(),
        )
      ];
}

class BooksContentLocation extends BeamLocation {
  BooksContentLocation(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => [
        '/books/authors',
        '/books/genres',
      ];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('books-home'),
          child: BooksHomeScreen(),
        ),
        if (state.pathBlueprintSegments.contains('authors'))
          BeamPage(
            key: ValueKey('books-authors'),
            child: BookAuthorsScreen(),
          ),
        if (state.pathBlueprintSegments.contains('genres'))
          BeamPage(
            key: ValueKey('books-genres'),
            child: BookGenresScreen(),
          )
      ];
}

class ArticlesLocation extends BeamLocation {
  ArticlesLocation(BeamState state) : super(state) {
    print('articles with ${state.uri}');
  }

  @override
  List<String> get pathBlueprints => ['/articles/*'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('articles'),
          child: ArticlesScreen(),
        )
      ];
}

class ArticlesContentLocation extends BeamLocation {
  ArticlesContentLocation(BeamState state) : super(state) {
    print('articles content with ${state.uri}');
  }

  @override
  List<String> get pathBlueprints => [
        '/articles/authors',
        '/articles/genres',
      ];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('articles-home'),
          child: ArticlesHomeScreen(),
        ),
        if (state.pathBlueprintSegments.contains('authors'))
          BeamPage(
            key: ValueKey('articles-authors'),
            child: ArticleAuthorsScreen(),
          ),
        if (state.pathBlueprintSegments.contains('genres'))
          BeamPage(
            key: ValueKey('articles-genres'),
            child: ArticleGenresScreen(),
          )
      ];
}
