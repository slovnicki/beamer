import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

class GenresScreen extends StatelessWidget {
  GenresScreen({
    this.book,
  }) : genres = book['genres'].split(', ');

  final Map<String, String> book;
  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title'] + "'s genres"),
      ),
      body: Center(
        child: ListView(
          children: genres
              .map((genre) => ListTile(
                    title: Text(genre),
                    onTap: () => context.currentBeamLocation.update(
                      (state) => state.copyWith(
                        pathBlueprintSegments: [
                          'books',
                          ':bookId',
                          'genres',
                          ':genreId'
                        ],
                        pathParameters: {
                          'bookId': book['id'],
                          'genreId': (genres.indexOf(genre) + 1).toString()
                        },
                        data: {'book': book, 'genre': genre},
                      ),
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
