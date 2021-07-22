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
    'title': 'Explaining Flutter Nav 2.0 and Beamer',
    'author': 'Toby Lewis',
  },
  {
    'id': '2',
    'title': 'Flutter Navigator 2.0 for mobile dev: 101',
    'author': 'Lulupointu',
  },
  {
    'id': '3',
    'title': 'Flutter: An Easy and Pragmatic Approach to Navigator 2.0',
    'author': 'Marco Muccinelli',
  },
];

// SCREENS
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key, required this.initialIndex}) : super(key: key);

  final int initialIndex;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            BooksScreen(),
            ArticlesScreen(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(label: 'Books', icon: Icon(Icons.book)),
            BottomNavigationBarItem(
                label: 'Articles', icon: Icon(Icons.article)),
          ],
          onTap: (index) {
            Beamer.of(context).update(
              configuration: RouteInformation(
                location: index == 0 ? '/?tab=books' : '/?tab=articles',
              ),
              rebuild: false,
            );
            setState(() => _currentIndex = index);
          },
        ));
  }
}

class BooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books'),
      ),
      body: ListView(
        children: books
            .map(
              (book) => ListTile(
                title: Text(book['title']!),
                subtitle: Text(book['author']!),
                onTap: () => context.beamToNamed('/books/${book['id']}'),
              ),
            )
            .toList(),
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({required this.book});
  final Map<String, String> book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Author: ${book['author']!}'),
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
            .map(
              (article) => ListTile(
                title: Text(article['title']!),
                subtitle: Text(article['author']!),
                onTap: () => context.beamToNamed('/articles/${article['id']}'),
              ),
            )
            .toList(),
      ),
    );
  }
}

class ArticleDetailsScreen extends StatelessWidget {
  const ArticleDetailsScreen({required this.article});
  final Map<String, String> article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(article['title']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Author: ${article['author']!}'),
      ),
    );
  }
}

// APP
class MyApp extends StatelessWidget {
  final routerDelegate = BeamerDelegate(
    locationBuilder: SimpleLocationBuilder(
      routes: {
        '/': (context, state) {
          final initialIndex =
              state.queryParameters['tab'] == 'articles' ? 1 : 0;
          return HomeScreen(initialIndex: initialIndex);
        },
        '/books/:bookId': (context, state) {
          final bookId = state.pathParameters['bookId'];
          final book = books.firstWhere((book) => book['id'] == bookId);
          return BeamPage(
            key: ValueKey('book-$bookId'),
            title: book['title'],
            child: BookDetailsScreen(book: book),
            onPopPage: (context, delegate, page) {
              delegate.update(
                configuration: RouteInformation(
                  location: '/?tab=books',
                ),
                rebuild: false,
              );
              return true;
            },
          );
        },
        'articles/:articleId': (context, state) {
          final articleId = state.pathParameters['articleId'];
          final article =
              articles.firstWhere((article) => article['id'] == articleId);
          return BeamPage(
            key: ValueKey('articles-$articleId'),
            title: article['title'],
            child: ArticleDetailsScreen(article: article),
            onPopPage: (context, delegate, page) {
              delegate.update(
                configuration: RouteInformation(
                  location: '/?tab=articles',
                ),
                rebuild: false,
              );
              return true;
            },
          );
        },
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: routerDelegate,
      routeInformationParser: BeamerParser(),
      backButtonDispatcher: BeamerBackButtonDispatcher(
        delegate: routerDelegate,
      ),
    );
  }
}

void main() => runApp(MyApp());
