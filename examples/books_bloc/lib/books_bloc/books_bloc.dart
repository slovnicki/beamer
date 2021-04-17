import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'books_event.dart';
part 'books_state.dart';

class BooksBloc extends Bloc<BooksEvent, BooksState> {
  BooksBloc() : super(Loading());

  final List<Map<String, dynamic>> _books = [
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

  bool _firstTimeBooks = true;

  @override
  Stream<BooksState> mapEventToState(
    BooksEvent event,
  ) async* {
    if (event is LoadBooks) {
      if (_firstTimeBooks) {
        yield Loading();
        await Future.delayed(Duration(milliseconds: 200));
        _firstTimeBooks = false;
      }
      final books = _books.map((book) => Book.fromJson(book)).toList();
      yield BooksLoaded(books);
    }
    if (event is LoadBook) {
      yield Loading();
      await Future.delayed(Duration(milliseconds: 200));
      try {
        final book = _books.firstWhere(
          (book) => book['id'] == event.bookId.toString(),
        );
        yield BookLoaded(Book.fromJson(book));
      } catch (e) {
        yield BookNotFound();
      }
    }
  }
}
