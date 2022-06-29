import 'package:bottom_navigation_complex/data/data.dart';
import 'package:bottom_navigation_complex/models/book.models.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

class BookDetailsScreen extends StatelessWidget {
  final String bookID;
  late final Book book = books.firstWhere((book) => book.id == bookID);

  BookDetailsScreen({super.key, required this.bookID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${book.title}')),
      body: Center(
        child: ElevatedButton(
          child: Text('Open ${book.id} in root page'),
          onPressed: () => Beamer.of(context).root.beamToNamed('/Book/${book.id}'),
        ),
      ),
    );
  }
}
