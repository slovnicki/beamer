import 'package:flutter/material.dart';

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
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        child: Text('$counter'),
        onPressed: () => setState(() => counter++),
      ),
    );
  }
}
