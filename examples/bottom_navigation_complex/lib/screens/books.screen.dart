import 'package:bottom_navigation_complex/data/data.dart';
import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

class Books extends StatefulWidget {
  const Books({super.key});

  @override
  State<Books> createState() => _BooksState();
}

class _BooksState extends State<Books> {
  int counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Books')),
      body: ListView(
        children: books
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
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        child: Text('$counter'),
        onPressed: () => setState(() => counter++),
      ),
    );
  }
}
