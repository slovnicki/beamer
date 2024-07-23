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
      appBar: AppBar(
        title: Text('Book ${book.title}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            onPressed: () => Beamer.of(context).root.beamToNamed('/Book/${book.id}'),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            child: Text('Other books:', style: Theme.of(context).textTheme.titleLarge),
          ),
          ...books
              .where((book) => book.id != bookID)
              .map(
                (book) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(book.id),
                  ),
                  title: Text(book.title),
                  subtitle: Text(book.author),
                  onTap: () => context.beamToNamed('/Books/${book.id}'),
                  onLongPress: () => Beamer.of(context).root.beamToNamed('/Book/${book.id}'),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
