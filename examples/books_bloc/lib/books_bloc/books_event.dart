part of 'books_bloc.dart';

@immutable
abstract class BooksEvent {}

class LoadBooks extends BooksEvent {}

class LoadBook extends BooksEvent {
  LoadBook(this.bookId);

  final int bookId;
}
