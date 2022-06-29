import 'package:bottom_navigation_complex/data/data.dart';
import 'package:bottom_navigation_complex/models/article.models.dart';
import 'package:flutter/material.dart';

class ArticleDetailsScreen extends StatelessWidget {
  final String articleID;
  late final Article article = articles.firstWhere((article) => article.id == articleID);

  ArticleDetailsScreen({super.key, required this.articleID});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Article ${article.title}')),
      body: Center(
        child: ElevatedButton(
          child: Text('Open ${article.id} in root page'),
          onPressed: () {}, // TODO: Open in root page
        ),
      ),
    );
  }
}
