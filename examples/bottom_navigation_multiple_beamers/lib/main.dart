import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

// DATA
const List<Map<String, String>> books = [
  {
    'id': '1',
    'title': 'Stranger in a Strange Land',
    'author': 'Robert A. Heinlein',
  },
  {
    'id': '2',
    'title': 'Foundation',
    'author': 'Isaac Asimov',
  },
  {
    'id': '3',
    'title': 'Fahrenheit 451',
    'author': 'Ray Bradbury',
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
class BooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books'),
      ),
      body: ListView(
        children: books
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
      appBar: AppBar(title: Text('Book: ${book['title']}')),
      body: Text('Author: ${book['author']}'),
    );
  }
}

class ArticlesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Articles')),
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
      appBar: AppBar(title: Text('Article: ${article['title']}')),
      body: Text('Author: ${article['author']}'),
    );
  }
}

// LOCATIONS
class BooksLocation extends BeamLocation {
  BooksLocation({
    String pathBlueprint,
  }) : super(pathBlueprint: pathBlueprint);

  @override
  List<String> get pathBlueprints => ['/books/:bookId'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
        BeamPage(
          key: ValueKey('books'),
          child: BooksScreen(),
        ),
        if (pathParameters.containsKey('bookId'))
          BeamPage(
            key: ValueKey('book-${pathParameters['bookId']}'),
            child: BookDetailsScreen(
              bookId: pathParameters['bookId'],
            ),
          ),
      ];
}

class ArticlesLocation extends BeamLocation {
  ArticlesLocation({
    String pathBlueprint,
  }) : super(pathBlueprint: pathBlueprint);

  @override
  List<String> get pathBlueprints => ['/articles/:articleId'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [
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
class MyApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: BeamerRouteInformationParser(),
      routerDelegate: RootRouterDelegate(
        homeBuilder: (context, uri) {
          return Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: [
                Beamer(
                  beamLocations: [ArticlesLocation()],
                ),
                Container(
                  color: Colors.blueAccent,
                  padding: const EdgeInsets.all(32.0),
                  child: Beamer(
                    beamLocations: [BooksLocation()],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _currentIndex,
              items: [
                BottomNavigationBarItem(label: 'A', icon: Icon(Icons.article)),
                BottomNavigationBarItem(label: 'B', icon: Icon(Icons.book)),
              ],
              onTap: (index) => setState(() => _currentIndex = index),
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
