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
      appBar: AppBar(
        title: Text(book['title']),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Beamer.of(context).updateCurrentLocation(
            pathBlueprint: '/books/:bookId/buy',
            data: {'book': book},
          ),
          child: Text('Buy'),
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
        child: ElevatedButton(
          onPressed: () => Beamer.of(context).updateCurrentLocation(
            pathBlueprint: '/books',
            rewriteParameters: true,
          ),
          child: Text('Go back to books'),
        ),
      ),
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
      appBar: AppBar(title: Text(article['title'])),
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
  List<String> get pathBlueprints => ['/books/:bookId/buy'];

  @override
  List<BeamPage> get pages => [
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
        if (pathSegments.contains('buy'))
          BeamPage(
            key: ValueKey('book-${pathParameters['bookId']}-buy'),
            child: BuyScreen(
              book: data['book'],
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
  List<BeamPage> get pages => [
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
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final List<BeamLocation> _beamLocations = [
    BooksLocation(pathBlueprint: '/books'),
    ArticlesLocation(pathBlueprint: '/articles'),
  ];
  final _beamerKey = GlobalKey<BeamerState>();
  Beamer _beamer;
  int _currentIndex = 0;

  @override
  void initState() {
    _beamer = Beamer(
      key: _beamerKey,
      routerDelegate: BeamerRouterDelegate(initialLocation: _beamLocations[0]),
      routeInformationParser: BeamerRouteInformationParser(
        beamLocations: _beamLocations,
      ),
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: _beamer,
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            items: [
              BottomNavigationBarItem(label: 'Books', icon: Icon(Icons.book)),
              BottomNavigationBarItem(
                  label: 'Articles', icon: Icon(Icons.article)),
            ],
            onTap: (index) {
              setState(() => _currentIndex = index);
              _beamerKey.currentState.routerDelegate
                  .beamTo(_beamLocations[index]);
            }),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
