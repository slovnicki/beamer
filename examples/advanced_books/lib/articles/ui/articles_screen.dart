import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import '../data.dart';

class ArticlesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Articles'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: GestureDetector(
              onTap: () => Beamer.of(context).beamBack(),
              child: Row(
                children: [Text('Beam back  '), Icon(Icons.backup)],
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        children: articles
            .map((article) => ListTile(
                  title: Text(article['title']),
                  subtitle: Text(article['author']),
                  onTap: () => Beamer.of(context).updateCurrentLocation(
                    pathBlueprint: '/articles/:articleId',
                    pathParameters: {'articleId': article['id']},
                  ),
                ))
            .toList(),
      ),
    );
  }
}
