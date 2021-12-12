import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

class BooksScreen extends StatelessWidget {
  BooksScreen({required this.books, required this.title});
  final List<Map<String, dynamic>> books;
  final String title;

  @override
  Widget build(BuildContext context) {
    final titleQuery = (context.currentBeamLocation.state as BeamState)
        .queryParameters['title'];
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: ListView(
        children: books
            .map(
              (book) => ListTile(
                title: Text(book['title']),
                subtitle: Text(book['author']),
                onTap: () => context.beamToNamed(
                  '/books/${book['id']}',
                  data: {'title': titleQuery},
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}
