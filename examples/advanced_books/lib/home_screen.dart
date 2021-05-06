import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final booksQueryController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.beamToNamed('books'),
              child: Text('See all books'),
            ),
            SizedBox(height: 15),
            SizedBox(
              width: 250,
              child: TextField(
                controller: booksQueryController,
                decoration: InputDecoration(
                  hintText: 'Search book by title...',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () => context.beamToNamed(
                        'books?title=${booksQueryController.text}'),
                  ),
                ),
                onSubmitted: (title) =>
                    context.beamToNamed('books?title=$title'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
