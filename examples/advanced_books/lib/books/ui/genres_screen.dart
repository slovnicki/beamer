import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

class GenresScreen extends StatelessWidget {
  GenresScreen(this.book) : genres = book['genres']!.split(', ');

  final Map<String, String> book;
  final List<String> genres;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title']! + "'s genres"),
      ),
      body: Center(
        child: ListView(
          children: genres
              .map((genre) => ListTile(
                    title: Text(genre),
                    onTap: () => Beamer.of(context).updateCurrentLocation(
                      pathBlueprint: '/books/:bookId/genres/:genreId',
                      pathParameters: {
                        'genreId': (genres.indexOf(genre) + 1).toString()
                      },
                      data: {'genre': genre},
                    ),
                  ))
              .toList(),
        ),
      ),
    );
  }
}
