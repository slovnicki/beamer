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
final List<BeamLocation> _beamLocations = [
  BooksLocation(pathBlueprint: '/books'),
  ArticlesLocation(pathBlueprint: '/articles'),
];

class BottomNavigationBarWidget extends StatefulWidget {
  BottomNavigationBarWidget({this.beamerKey});

  final GlobalKey<BeamerState> beamerKey;

  @override
  _BottomNavigationBarWidgetState createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  int _currentIndex = 0;

  @override
  void initState() {
    widget.beamerKey.currentState.routerDelegate
        .addListener(() => _updateCurrentIndex());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(label: 'Books', icon: Icon(Icons.book)),
          BottomNavigationBarItem(label: 'Articles', icon: Icon(Icons.article)),
        ],
        onTap: (index) {
          widget.beamerKey.currentState.routerDelegate
              .beamTo(_beamLocations[index]);
        });
  }

  void _updateCurrentIndex() {
    final index =
        (widget.beamerKey.currentState.currentLocation is BooksLocation)
            ? 0
            : 1;
    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }
}

class MyApp extends StatelessWidget {
  final _beamerKey = GlobalKey<BeamerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Beamer(
          key: _beamerKey,
          routerDelegate:
              BeamerRouterDelegate(initialLocation: _beamLocations[0]),
          routeInformationParser: BeamerRouteInformationParser(
            beamLocations: _beamLocations,
          ),
        ),
        bottomNavigationBar: BottomNavigationBarWidget(
          beamerKey: _beamerKey,
        ),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
