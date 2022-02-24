import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: BeamerParser(),
      routerDelegate: BeamerDelegate(
        initialPath: '/books',
        transitionDelegate: const NoAnimationTransitionDelegate(),
        locationBuilder: RoutesLocationBuilder(
          routes: {
            '*': (_, __, ___) => HomeScreen(),
          },
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool _showArticles;

  final _beamerDelegates = [
    BeamerDelegate(
      initialPath: '/books',
      locationBuilder: RoutesLocationBuilder(
        routes: {
          '/books': (_, __, ___) => const BooksScreen(),
          '/books/:id': (_, state, __) =>
              BookDetailsScreen(id: state.pathParameters['id']),
        },
      ),
    ),
    BeamerDelegate(
      initialPath: '/articles',
      locationBuilder: RoutesLocationBuilder(
        routes: {
          '/articles': (_, __, ___) => const ArticlesScreen(),
          '/articles/:id': (_, state, __) =>
              ArticleDetailsScreen(id: state.pathParameters['id']),
        },
      ),
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final uri = Beamer.of(context).configuration.location!;
    _showArticles = true; // uri.contains('articles');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiple Beamers'),
      ),
      backgroundColor: Colors.blue[100],
      body: Stack(
        children: [
          Positioned(
            top: 32.0,
            left: 32.0,
            child: SizedBox(
              width: 320,
              height: 320,
              child: Beamer(routerDelegate: _beamerDelegates[0]),
            ),
          ),
          Positioned(
            bottom: 32.0,
            right: 32.0,
            child: Container(
              width: 240,
              height: 320,
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(-2.0, -2.0),
                    blurRadius: 8.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: _showArticles
                  ? Beamer(routerDelegate: _beamerDelegates[1])
                  : Center(
                      child: ElevatedButton(
                        onPressed: () => setState(() => _showArticles = true),
                        child: const Text('Create Beamer'),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class BooksScreen extends StatelessWidget {
  const BooksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Books')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.beamToNamed('/books/1'),
              child: const Text('Book 1: See details'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => context.beamToNamed('/books/2'),
              child: const Text('Book 2: See details'),
            ),
          ],
        ),
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({Key? key, this.id}) : super(key: key);

  final String? id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book $id')),
      body: const Center(child: Text('... A book ...')),
    );
  }
}

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Articles')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => context.beamToNamed('/articles/1'),
              child: const Text('Article 1: See details'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => context.beamToNamed('/articles/2'),
              child: const Text('Article 2: See details'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () => context.beamToNamed('/articles/3'),
              child: const Text('Article 3: See details'),
            ),
          ],
        ),
      ),
    );
  }
}

class ArticleDetailsScreen extends StatelessWidget {
  const ArticleDetailsScreen({Key? key, this.id}) : super(key: key);

  final String? id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Article $id')),
      body: const Center(child: Text('... An article ...')),
    );
  }
}
