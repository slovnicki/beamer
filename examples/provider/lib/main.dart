import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Books'),
      ),
      body: ListView(
        children: context
            .read<Books>()
            .books
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
  const BookDetailsScreen(this.bookDetails);
  final Map<String, String> bookDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookDetails['title']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Author: ${bookDetails['author']!}'),
      ),
    );
  }
}

// LOCATIONS
class HomeLocation extends BeamLocation {
  @override
  List<String> get pathBlueprints => ['/'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) {
    return [
      BeamPage(
        key: ValueKey('home'),
        child: HomeScreen(),
      ),
    ];
  }
}

class BooksLocation extends BeamLocation {
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
            context.read<Books>().books.firstWhere((book) =>
                book['id'] ==
                context.currentBeamLocation.state.pathParameters['bookId']),
          ),
        ),
    ];
  }
}

// APP
class MyApp extends StatelessWidget {
  final routerDelegate = BeamerRouterDelegate(
    locationBuilder: BeamerLocationBuilder(
      beamLocations: [
        HomeLocation(),
        BooksLocation(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: routerDelegate,
      routeInformationParser: BeamerRouteInformationParser(),
    );
  }
}

void main() => runApp(MyApp());
