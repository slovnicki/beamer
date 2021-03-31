import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

// BOOKS
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

// SCREENS
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.beamToNamed('/books'),
          child: Text('Beam to books location'),
        ),
      ),
    );
  }
}

class BooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final titleQuery =
        Beamer.of(context).currentLocation.state.queryParameters['title'] ?? '';
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
                  onTap: () => Beamer.of(context).currentLocation.update(
                        (state) => state.copyWith(
                          pathBlueprintSegments: ['books', ':bookId'],
                          pathParameters: {'bookId': book['id']},
                        ),
                      ),
                ))
            .toList(),
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  BookDetailsScreen({this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context) {
    final book = books.firstWhere((book) => book['id'] == bookId);
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title']),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Author: ${book['author']}'),
      ),
    );
  }
}

// LOCATIONS
class HomeLocation extends BeamLocation {
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
  @override
  List<String> get pathBlueprints => ['/books/:bookId'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) {
    return [
      ...HomeLocation().pagesBuilder(context, state),
      if (state.uri.pathSegments.contains('books'))
        BeamPage(
          key: ValueKey('books-${state.queryParameters['title'] ?? ''}'),
          child: BooksScreen(),
        ),
      if (state.pathParameters.containsKey('bookId'))
        BeamPage(
          key: ValueKey('book-${state.pathParameters['bookId']}'),
          child: BookDetailsScreen(
            bookId: state.pathParameters['bookId'],
          ),
        ),
    ];
  }
}

// APP
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: BeamerRouterDelegate(
        locationBuilder: BeamerLocationBuilder(beamLocations: [
          BooksLocation(),
          HomeLocation(),
        ]),
      ),
      routeInformationParser: BeamerRouteInformationParser(),
    );
  }
}

void main() {
  runApp(MyApp());
}
