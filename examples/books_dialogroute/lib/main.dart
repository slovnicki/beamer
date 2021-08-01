import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

void main() => runApp(MyApp());

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
          child: Text('See books'),
        ),
      ),
    );
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
                onTap: () =>
                    context.beamToNamed('/books/${book['id']}?buy=true'),
              ),
            )
            .toList(),
      ),
    );
  }
}

class BookDetailsScreen extends StatefulWidget {
  BookDetailsScreen({
    required this.bookId,
  }) : book = books.firstWhere((book) => book['id'] == bookId);

  final String bookId;
  final Map<String, String> book;

  @override
  _BookDetailsScreenState createState() => _BookDetailsScreenState();
}

class _BookDetailsScreenState extends State<BookDetailsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.book['title']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: () => context.currentBeamLocation.update(
            (state) =>
                (state as BeamState).copyWith(queryParameters: {'buy': 'true'}),
          ),
          child: Text('Author: ${widget.book['author']}'),
        ),
      ),
    );
  }
}

// LOCATIONS
class BooksLocation extends BeamLocation<BeamState> {
  BooksLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<String> get pathPatterns => ['/books/:bookId'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('home'),
          child: HomeScreen(),
        ),
        if (state.uri.pathSegments.contains('books'))
          BeamPage(
            key: ValueKey('books'),
            child: BooksScreen(),
          ),
        if (state.pathParameters.containsKey('bookId'))
          BeamPage(
            key: ValueKey('book-${state.pathParameters['bookId']}'),
            child: BookDetailsScreen(bookId: state.pathParameters['bookId']!),
          ),
        if (state.queryParameters.containsKey('buy'))
          BeamPage(
              routeBuilder: (RouteSettings settings, Widget child) =>
                  DialogRoute<void>(
                      context: context,
                      builder: (context) => child,
                      settings: settings),
              key: ValueKey('book-buy-${state.pathParameters['bookId']}'),
              onPopPage: (context, delegate, _, page) {
                // when the dialog is dismissed, we only want to pop the `buy=true` query parameter
                // instead of also popping the bookId.
                delegate.currentBeamLocation.update(
                  (state) => (state as BeamState).copyWith(queryParameters: {}),
                );
                return true;
              },
              child: AlertDialog(
                title: Text("Buy book"),
                actions: [],
              ))
      ];
}

// APP
class MyApp extends StatelessWidget {
  final routerDelegate = BeamerDelegate(
    locationBuilder: (routeInformation, _) => BooksLocation(routeInformation),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: routerDelegate,
      routeInformationParser: BeamerParser(),
      backButtonDispatcher:
          BeamerBackButtonDispatcher(delegate: routerDelegate),
    );
  }
}
