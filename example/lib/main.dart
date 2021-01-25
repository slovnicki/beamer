import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

// SCREENS
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () => context.beamTo(BooksLocation()),
          child: Text('Go to books location'),
        ),
      ),
    );
  }
}

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
                  onTap: () => Beamer.of(context).beamTo(
                    BooksLocation.withParameters(
                      path: {'id': book['id']},
                    ),
                  ),
                ))
            .toList(),
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  BookDetailsScreen({
    this.book,
  });

  final Map<String, String> book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title']),
      ),
      body: Text('Author: ${book['author']}'),
    );
  }
}

// LOCATIONS
class HomeLocation extends BeamLocation {
  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('home'),
          page: HomeScreen(),
        ),
      ];

  @override
  String get pathBlueprint => '/';
}

class BooksLocation extends BeamLocation {
  BooksLocation() : super();

  BooksLocation.withParameters({
    Map<String, String> path,
    Map<String, String> query,
  }) : super.withParameters(path: path, query: query);

  @override
  List<BeamPage> get pages => [
        ...HomeLocation().pages,
        BeamPage(
          key: ValueKey('books-${queryParameters['title'] ?? ''}'),
          page: BooksScreen(
            titleQuery: queryParameters['title'] ?? '',
          ),
        ),
        if (pathParameters.containsKey('id'))
          BeamPage(
            key: ValueKey('book-${pathParameters['id']}'),
            page: BookDetailsScreen(
              book: books
                  .firstWhere((book) => book['id'] == pathParameters['id']),
            ),
          ),
      ];

  @override
  String get pathBlueprint => '/books/:id';
}

// APP
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Beamer(
      initialLocation: HomeLocation(),
      beamLocations: [
        HomeLocation(),
        BooksLocation(),
      ],
      notFoundPage: Scaffold(body: Center(child: Text('Not found'))),
      app: MaterialApp(),
    );
  }
}

void main() {
  runApp(MyApp());
}
