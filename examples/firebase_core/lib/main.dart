import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';
import 'package:firebase_core/firebase_core.dart';

// DATA
const List<Map<String, String>> books = [
  {
    'id': '1',
    'title': 'Stranger in a Strange Land',
    'author': 'Robert A. Heinlein',
  },
  {
    'id': '2',
    'title': 'Foundation',
    'author': 'Isaac Asimov',
  },
  {
    'id': '3',
    'title': 'Fahrenheit 451',
    'author': 'Ray Bradbury',
  },
];

// SCREENS
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.beamToNamed('/books'),
          child: Text('See books'),
        ),
      ),
    );
  }
}

class BooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books'),
      ),
      body: ListView(
        children: books
            .map(
              (book) => ListTile(
                title: Text(book['title']!),
                subtitle: Text(book['author']!),
              ),
            )
            .toList(),
      ),
    );
  }
}

// APP
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _routerDelegate = BeamerDelegate(
    locationBuilder: SimpleLocationBuilder(
      routes: {
        '/': (context, state) => HomeScreen(),
        '/books': (context, state) => BooksScreen(),
      },
    ),
  );

  // Future<FirebaseApp> _initialization = Firebase.initializeApp();

  Future<FirebaseApp> _extraDelayedInitialization() async {
    await Future.delayed(Duration(seconds: 5));
    return Firebase.initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return BeamerProvider(
      routerDelegate: _routerDelegate,
      child: MaterialApp.router(
        routerDelegate: _routerDelegate,
        routeInformationParser: BeamerParser(),
        builder: (context, child) {
          return FutureBuilder(
            future: _extraDelayedInitialization(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Container(color: Colors.red);
              }
              if (snapshot.connectionState == ConnectionState.done) {
                // this child is the Navigator stack produced by Beamer
                return child!;
              }
              return Scaffold(
                body: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Extra delayed Firebase loading...'),
                      SizedBox(height: 32),
                      CircularProgressIndicator(),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

void main() => runApp(MyApp());
