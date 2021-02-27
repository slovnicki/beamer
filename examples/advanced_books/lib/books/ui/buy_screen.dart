import 'package:flutter/material.dart';

class BuyScreen extends StatelessWidget {
  BuyScreen(this.book);

  final Map<String, String> book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy Book'),
      ),
      body: Center(
        child:
            Text('${book['author']}: ${book['title']}\nbuying in progress...'),
      ),
    );
  }
}
