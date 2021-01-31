import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

// DATA
const List<Map<String, String>> books = [
  {
    'id': '1',
    'title': 'Stranger in a Strange Land',
    'author': 'Robert A. Heinlein',
    'genres': 'Science fiction',
  },
  {
    'id': '2',
    'title': 'Foundation',
    'author': 'Isaac Asimov',
    'genres': 'Science fiction, Political drama',
  },
  {
    'id': '3',
    'title': 'Fahrenheit 451',
    'author': 'Ray Bradbury',
    'genres': '	Dystopian',
  },
];

const List<Map<String, String>> articles = [
  {
    'id': '1',
    'title': 'Article 1',
    'author': 'Author 1',
  },
  {
    'id': '2',
    'title': 'Article 2',
    'author': 'Author 2',
  },
];

// SCREENS
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () =>
                      context.beamTo(BooksLocation(pathBlueprint: '/books')),
                  child: Text('Beam to books location'),
                ),
                ElevatedButton(
                  onPressed: () => context.beamTo(BooksLocation(
                    pathBlueprint: '/books/:bookId',
                    pathParameters: {'bookId': '2'},
                  )),
                  child: Text('Beam to favorite book location'),
                ),
              ],
            ),
            ElevatedButton(
              onPressed: () =>
                  context.beamTo(ArticlesLocation(pathBlueprint: '/articles')),
              child: Text('Beam to articles location'),
            ),
          ],
        ),
      ),
    );
  }
}

class BooksScreen extends StatelessWidget {
  BooksScreen({this.titleQuery = ''});

  final String titleQuery;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books'),
      ),
      body: ListView(
        children: books
            .where((book) =>
                book['title'].toLowerCase().contains(titleQuery.toLowerCase()))
            .map((book) => ListTile(
                  title: Text(book['title']),
                  subtitle: Text(book['author']),
                  onTap: () => Beamer.of(context).updateCurrentLocation(
                    pathBlueprint: '/books/:bookId',
                    pathParameters: {'bookId': book['id']},
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  BookDetailsScreen({
    this.bookId,
  }) : book = books.firstWhere((book) => book['id'] == bookId);

  final String bookId;
  final Map<String, String> book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title']),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => Beamer.of(context).updateCurrentLocation(
                pathBlueprint: '/books/:bookId/genres',
                data: {'book': book},
              ),
              child: Text('See genres'),
            ),
            ElevatedButton(
              onPressed: () => Beamer.of(context).updateCurrentLocation(
                pathBlueprint: '/books/:bookId/buy',
                data: {'book': book},
              ),
              child: Text('Buy'),
            ),
          ],
        ),
      ),
    );
  }
}

class BuyScreen extends StatelessWidget {
  BuyScreen({
    this.book,
  });

  final Map<String, String> book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Book'),
      ),
      body: Center(
        child:
            Text('${book['author']}: ${book['title']}\nbuying in progress...'),
      ),
    );
  }
}

class GenresScreen extends StatelessWidget {
  GenresScreen({
    this.book,
  }) : genres = book['genres'].split(', ');

  final Map<String, String> book;
  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title'] + "'s genres"),
      ),
      body: Center(
        child: ListView(
          children: genres
              .map((genre) => ListTile(
                    title: Text(genre),
                    onTap: () => Beamer.of(context).updateCurrentLocation(
                      pathBlueprint: '/books/:bookId/genres/:genreId',
                      pathParameters: {
                        'genreId': (genres.indexOf(genre) + 1).toString()
                      },
                      data: {'genre': genre},
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}

class GenreDetailsScreen extends StatelessWidget {
  GenreDetailsScreen({
    this.genre,
  });

  final String genre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(genre),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => Beamer.of(context).updateCurrentLocation(
                pathBlueprint: '/books',
                rewriteParameters: true,
              ),
              child: Text('Go back to books'),
            ),
            ElevatedButton(
              onPressed: () => Beamer.of(context)
                  .beamTo(ArticlesLocation(pathBlueprint: '/articles')),
              child: Text('Beam to articles'),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticlesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Articles'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => Beamer.of(context).beamBack(),
              child: Row(
                children: [Text('Beam back  '), Icon(Icons.backup)],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: articles
            .map((article) => ListTile(
                  title: Text(article['title']),
                  subtitle: Text(article['author']),
                  onTap: () => Beamer.of(context).updateCurrentLocation(
                    pathBlueprint: '/articles/:articleId',
                    pathParameters: {'articleId': article['id']},
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class ArticleDetailsScreen extends StatelessWidget {
  ArticleDetailsScreen({
    this.articleId,
  }) : article = articles.firstWhere((article) => article['id'] == articleId);

  final String articleId;
  final Map<String, String> article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article['title']),
      ),
      body: Text('Author: ${article['author']}'),
    );
  }
}

// LOCATIONS
class HomeLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/'];

  @override
  List<BeamPage> get pages => [
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
  List<BeamPage> get pages => [
        ...HomeLocation().pages,
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
  List<BeamPage> get pages => [
        ...HomeLocation().pages,
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

// APP
class MyApp extends StatelessWidget {
  final BeamLocation initialLocation = HomeLocation();
  final List<BeamLocation> beamLocations = [
    HomeLocation(),
    BooksLocation(),
    ArticlesLocation(),
  ];
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: BeamerRouterDelegate(
        initialLocation: initialLocation,
        notFoundPage: Scaffold(body: Center(child: Text('Not found'))),
      ),
      routeInformationParser: BeamerRouteInformationParser(
        beamLocations: beamLocations,
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
