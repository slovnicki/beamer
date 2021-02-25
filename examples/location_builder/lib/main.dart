import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

// BOOKS PROVIDER
class BooksProvider extends InheritedWidget {
  BooksProvider({
    Key key,
    @required Widget child,
  }) : super(key: key, child: child);

  final List<Map<String, String>> books = [
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

  static BooksProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BooksProvider>();

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

// SCREENS
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home Screen (I don't have access to books)"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () =>
              context.beamTo(BooksLocation(pathBlueprint: '/books')),
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
        Beamer.of(context).currentLocation.queryParameters['title'] ?? '';
    final books = BooksProvider.of(context).books;
    return Scaffold(
      appBar: AppBar(
        title: Text('Books (I' +
            (books != null ? '' : " don't") +
            ' have access to books)'),
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
  BookDetailsScreen({this.bookId});

  final String bookId;

  @override
  Widget build(BuildContext context) {
    final books = BooksProvider.of(context).books;
    final book = books.firstWhere((book) => book['id'] == bookId);
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title'] +
            (' (I also' +
                (books != null ? '' : " don't") +
                ' have access to books)')),
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
  }) : super(
          pathBlueprint: pathBlueprint,
          pathParameters: pathParameters,
        );

  @override
  Widget builder(BuildContext context, Widget navigator) =>
      BooksProvider(child: navigator);

  @override
  List<String> get pathBlueprints => ['/books/:bookId'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context) {
    print('books: ${BooksProvider.of(context).books.length}');
    return [
      ...HomeLocation().pagesBuilder(context),
      if (pathSegments.contains('books'))
        BeamPage(
          key: ValueKey('books-${queryParameters['title'] ?? ''}'),
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
}

// APP
class MyApp extends StatelessWidget {
  final BeamLocation initialLocation = HomeLocation();
  final List<BeamLocation> beamLocations = [
    HomeLocation(),
    BooksLocation(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: BeamerRouterDelegate(
        initialLocation: initialLocation,
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
