import 'package:bottom_navigation_complex/data/data.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

class ArticlesScreen extends StatefulWidget {
  const ArticlesScreen({super.key});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      body: ListView(
        children: articles
            .map(
              (article) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(context).primaryColor,
                  child: Text(article.id),
                ),
                title: Text(article.title),
                subtitle: Text(article.seller),
                onTap: () => context.beamToNamed('/Articles/${article.id}'),
                onLongPress: () => Beamer.of(context).root.beamToNamed('/Article/${article.id}'),
              ),
            )
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        child: Text('$counter'),
        onPressed: () => setState(() => counter++),
      ),
    );
  }
}
