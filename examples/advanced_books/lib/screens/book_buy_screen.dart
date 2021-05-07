import 'package:flutter/material.dart';

class BookBuyScreen extends StatelessWidget {
  BookBuyScreen({required this.book, required this.title});
  final Map<String, dynamic> book;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Text(
          '${book['author']}: ${book['title']}\n\nBuying in progress...',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
