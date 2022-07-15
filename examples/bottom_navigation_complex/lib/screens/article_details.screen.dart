import 'package:bottom_navigation_complex/app.dart';
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
      appBar: AppBar(
        title: Text('Article ${article.title}'),
        actions: [
          IconButton(
            icon: Icon(Icons.open_in_new),
            onPressed: () => App.router.beamToNamed('/Article/${article.id}'),
          )
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            child: Text('Other articles:', style: Theme.of(context).textTheme.titleLarge),
          ),
          ...articles
              .where((article) => article.id != articleID)
              .map(
                (article) => ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(article.id),
                  ),
                  title: Text(article.title),
                  subtitle: Text(article.seller),
                  onTap: () => App.router.beamToNamed('/Articles/${article.id}'),
                  onLongPress: () => App.router.beamToNamed('/Article/${article.id}'),
                ),
              )
              .toList(),
        ],
      ),
    );
  }
}
