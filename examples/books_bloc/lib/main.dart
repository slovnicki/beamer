import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'books_bloc/books_bloc.dart';

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
    final state = context.watch<BooksBloc>().state;

    return state is BooksLoaded
        ? Scaffold(
            appBar: AppBar(
              title: Text('Books'),
            ),
            body: ListView(
              children: state.books
                  .map(
                    (book) => ListTile(
                      title: Text(book.title),
                      subtitle: Text(book.author),
                      onTap: () => context.beamToNamed('/books/${book.id}'),
                    ),
                  )
                  .toList(),
            ),
          )
        : Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}

class BookDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<BooksBloc>().state;

    return state is BookLoaded
        ? Scaffold(
            appBar: AppBar(
              title: Text(state.book.title),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Author: ${state.book.author}'),
            ),
          )
        : Scaffold(
            body: Center(
              child: state is BookNotFound
                  ? Text('Book not found')
                  : CircularProgressIndicator(),
            ),
          );
  }
}

// LOCATIONS
class BooksLocation extends BeamLocation<BeamState> {
  late BooksBloc _booksBloc;

  @override
  void initState() {
    super.initState();
    _booksBloc = BooksBloc();
  }

  @override
  void disposeState() {
    _booksBloc.close();
    super.disposeState();
  }

  @override
  void onUpdate() {
    if (state.pathPatternSegments.isEmpty) return;

    final bookId = state.pathParameters.containsKey('bookId')
        ? int.parse(state.pathParameters['bookId']!)
        : null;

    bookId == null
        ? _booksBloc.add(LoadBooks())
        : _booksBloc.add(LoadBook(bookId));
  }

  @override
  Widget builder(BuildContext context, Widget navigator) {
    return BlocProvider.value(
      value: _booksBloc,
      child: navigator,
    );
  }

  @override
  List<String> get pathPatterns => ['/books/:bookId'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('home'),
          title: 'Home',
          child: HomeScreen(),
        ),
        if (state.uri.pathSegments.contains('books'))
          BeamPage(
            key: ValueKey('books'),
            title: 'Books',
            child: BooksScreen(),
          ),
        if (state.pathParameters.containsKey('bookId'))
          BeamPage(
            key: ValueKey('book-${state.pathParameters['bookId']}'),
            title: 'Book Details',
            child: BookDetailsScreen(),
          ),
      ];
}

// APP
class MyApp extends StatelessWidget {
  final routerDelegate = BeamerDelegate(
    locationBuilder: BeamerLocationBuilder(
      beamLocations: [
        BooksLocation(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: routerDelegate,
      routeInformationParser: BeamerParser(),
    );
  }
}

void main() => runApp(MyApp());
