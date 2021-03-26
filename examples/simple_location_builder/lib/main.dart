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
  Color _color;
  Color get color => _color;
  set color(Color color) {
    _color = color;
    notifyListeners();
  }
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
      backgroundColor: Provider.of<Books>(context).color,
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
                  onTap: () =>
                      Beamer.of(context).beamToNamed('/books/${book['id']}'),
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

// APP
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Books(),
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerDelegate: BeamerRouterDelegate(
          locationBuilder: SimpleLocationBuilder(routes: {
            '/': (context) => HomeScreen(),
            '/books': (context) => BooksScreen(),
            '/books/:bookId': (context) => BookDetailsScreen(
                bookId:
                    context.currentBeamLocation.state.pathParameters['bookId']),
          }),
        ),
        routeInformationParser: BeamerRouteInformationParser(),
      ),
    );
  }
}

void main() {
  runApp(MyApp());
}
