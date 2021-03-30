import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// BOOKS PROVIDER
class Books extends ChangeNotifier {
  List<Map<String, String>> books = [
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
    final books = context.read<Books>().books;
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
    final books = context.read<Books>().books;
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
  HomeLocation(BeamState state) : super(state);

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
  BooksLocation(BeamState state) : super(state);

  @override
  Widget builder(BuildContext context, Widget navigator) =>
      ChangeNotifierProvider(
        create: (context) => Books(),
        child: navigator,
      );

  @override
  List<String> get pathBlueprints => ['/books/:bookId'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) {
    return [
      ...HomeLocation(state).pagesBuilder(context),
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
        locationBuilder: (state) {
          if (state.uri.pathSegments.contains('books')) {
            return BooksLocation(state);
          }
          return HomeLocation(state);
        },
      ),
      routeInformationParser: BeamerRouteInformationParser(),
    );
  }
}

void main() {
  runApp(MyApp());
}
