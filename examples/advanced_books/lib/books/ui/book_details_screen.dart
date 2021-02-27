import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import '../data.dart';

class BookDetailsScreen extends StatelessWidget {
  BookDetailsScreen({
    this.bookId = '',
  }) : book = books.firstWhere((book) => book['id'] == bookId);

  final String bookId;
  final Map<String, String> book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title']!),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => Beamer.of(context).updateCurrentLocation(
                pathBlueprint: '/books/:bookId/genres',
                data: {'book': book},
              ),
              child: Text('See genres'),
            ),
            ElevatedButton(
              onPressed: () => Beamer.of(context).updateCurrentLocation(
                pathBlueprint: '/books/:bookId/buy',
                data: {'book': book},
              ),
              child: Text('Buy'),
            ),
          ],
        ),
      ),
    );
  }
}
