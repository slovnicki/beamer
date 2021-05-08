part of 'books_bloc.dart';

class Book {
  Book({
    required this.id,
    required this.title,
    required this.author,
  });

  final int id;
  final String title;
  final String author;

  Book.fromJson(Map<String, dynamic> json)
      : id = int.parse(json['id']),
        title = json['title'],
        author = json['author'];
}

@immutable
abstract class BooksState {}

class Loading extends BooksState {}

class BooksLoaded extends BooksState {
  BooksLoaded(this.books);

  final List<Book> books;
}

class BookLoaded extends BooksState {
  BookLoaded(this.book);

  final Book book;
}

class BookNotFound extends BooksState {}
