import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'package:advanced_books/locations.dart';

class GenreDetailsScreen extends StatelessWidget {
  GenreDetailsScreen({
    this.genre,
  });

  final String genre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(genre),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => context.beamToNamed('/books'),
              child: Text('Go back to books'),
            ),
            ElevatedButton(
              onPressed: () => context.beamToNamed('/articles'),
              child: Text('Beam to articles'),
            ),
          ],
        ),
      ),
    );
  }
}
