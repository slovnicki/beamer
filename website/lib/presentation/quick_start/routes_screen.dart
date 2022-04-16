import 'package:beamer_website/presentation/core/code_snippet.dart';
import 'package:beamer_website/presentation/core/paragraph.dart';
import 'package:flutter/material.dart';

class RoutesScreen extends StatelessWidget {
  const RoutesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ParagraphTitle('Defining simple routes'),
              ParagraphText(
                'The simplest setup is achieved by using the RoutesLocationBuilder which yields the least amount of code. This is a great choice for applications with fewer navigation scenarios or with shallow page stacks, i.e. when pages are rarely stacked on top of each other.',
              ),
              CodeSnippet(code: code, hasCopy: true),
              SizedBox(height: 16.0),
              ParagraphText(
                "RoutesLocationBuilder will pick and sort routes based on their paths. For example, navigating to /books/1 will match all 3 entries from routes and stack them on top of each other. Navigating to /books will match the first 2 entries from routes. The corresponding pages are put into Navigator.pages and BeamerDelegate (re)builds the Navigator, showing the selected stack of pages on the screen.",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const code = '''
class ExampleApp extends StatelessWidget {
  final routerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/': (_, __, ___) => const HomeScreen(),
        '/books': (_, __, ___) => const BooksScreen(),
        '/books/:bookId': (_, state, __) {
          final bookIdParameter = state.pathParameters['bookId']!;
          final bookId = int.tryParse(bookIdParameter);
          final book = books.firstWhereOrNull((book) => book.id == bookId);
          return BeamPage(
            key: ValueKey('book-\$bookId'),
            type: BeamPageType.scaleTransition,
            child: BookDetailsScreen(book: book),
          );
        },
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
    );
  }
}
''';
