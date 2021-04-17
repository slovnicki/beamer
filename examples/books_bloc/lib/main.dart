import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:example/books_bloc/books_bloc.dart';

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
          onPressed: () {
            context.beamToNamed('/books');
            context.read<BooksBloc>().add(LoadBooks());
          },
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
      body: BlocBuilder<BooksBloc, BooksState>(
        builder: (context, state) {
          if (state is BooksLoaded) {
            return ListView(
              children: state.books
                  .map(
                    (book) => ListTile(
                      title: Text(book.title),
                      subtitle: Text(book.author),
                      onTap: () {
                        context.beamToNamed('/books/${book.id}');
                        context.read<BooksBloc>().add(LoadBook(book.id));
                      },
                    ),
                  )
                  .toList(),
            );
          }
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<BooksBloc>().state;
    if (state is Loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: state is BookLoaded ? Text(state.book.title) : Text('Not Found'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: state is BookLoaded
            ? Text('Author: ${state.book.author}')
            : Text('Not Found'),
      ),
    );
  }
}

// LOCATIONS
class BooksLocation extends BeamLocation {
  BooksLocation() : super() {
    addListener(_listener);
  }

  final BooksBloc _booksBloc = BooksBloc();

  void _listener() {
    if (state.pathBlueprintSegments.isEmpty) {
      return;
    }
    final bookId = state.pathParameters.containsKey('bookId')
        ? int.parse(state.pathParameters['bookId'])
        : null;
    if (bookId == null) {
      _booksBloc.add(LoadBooks());
    } else {
      _booksBloc.add(LoadBook(bookId));
    }
  }

  @override
  Widget builder(BuildContext context, Widget navigator) {
    return BlocProvider.value(
      value: _booksBloc,
      child: navigator,
    );
  }

  @override
  List<String> get pathBlueprints => ['/books/:bookId'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
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
            child: BookDetailsScreen(),
          ),
      ];
}

// APP
class MyApp extends StatelessWidget {
  final _routerDelegate = BeamerRouterDelegate(
    locationBuilder: BeamerLocationBuilder(
      beamLocations: [
        BooksLocation(),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: _routerDelegate,
      routeInformationParser: BeamerRouteInformationParser(),
      backButtonDispatcher:
          BeamerBackButtonDispatcher(delegate: _routerDelegate),
    );
  }
}

void main() => runApp(MyApp());
