import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

// DATA
const List<Map<String, String>> books = [
  {
    'id': '1',
    'title': 'Stranger in a Strange Land',
    'author': 'Robert A. Heinlein',
    'genres': 'Science fiction',
  },
  {
    'id': '2',
    'title': 'Foundation',
    'author': 'Isaac Asimov',
    'genres': 'Science fiction, Political drama',
  },
  {
    'id': '3',
    'title': 'Fahrenheit 451',
    'author': 'Ray Bradbury',
    'genres': '	Dystopian',
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => context.beamToNamed('/books'),
                  child: Text('Beam to books location'),
                ),
                ElevatedButton(
                  onPressed: () => context.beamToNamed('/books/2'),
                  child: Text('Beam to forbidden book'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text('Not Authenticated!'),
            ElevatedButton(
              onPressed: () => AuthenticationStateProvider.of(context)
                  .isAuthenticated
                  .value = true,
              child: Text('login'),
            ),
          ],
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
            .map((book) => ListTile(
                  title: Text(book['title']),
                  subtitle: Text(book['author']),
                  onTap: () => context.beamToNamed('/books/${book['id']}'),
                ))
            .toList(),
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  BookDetailsScreen({
    this.bookId,
  }) : book = books.firstWhere((book) => book['id'] == bookId);

  final String bookId;
  final Map<String, String> book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book['title']),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => context.beamToNamed(
                '/books/$bookId/genres',
                data: {'book': book},
              ),
              child: Text('See genres'),
            ),
            ElevatedButton(
              onPressed: () => context.beamToNamed(
                '/books/$bookId/buy',
                data: {'book': book},
              ),
              child: Text('Buy'),
            ),
          ],
        ),
      ),
    );
  }
}

// LOCATIONS
class HomeLocation extends BeamLocation {
  HomeLocation(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => ['/'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('home'),
          child: HomeScreen(),
        ),
      ];
}

class LoginLocation extends BeamLocation {
  LoginLocation(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => ['/login'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('login'),
          child: LoginScreen(),
        ),
      ];
}

class BooksLocation extends BeamLocation {
  BooksLocation(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => ['/books/:bookId'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        ...HomeLocation(state).pagesBuilder(context, state),
        if (state.uri.pathSegments.contains('books'))
          BeamPage(
            key: ValueKey('books'),
            child: BooksScreen(),
          ),
        if (state.pathParameters.containsKey('bookId'))
          BeamPage(
            key: ValueKey('book-${state.pathParameters['bookId']}'),
            child: BookDetailsScreen(
              bookId: state.pathParameters['bookId'],
            ),
          ),
      ];

  final forbiddenPage = BeamPage(
    child: Scaffold(
      body: Center(
        child: Text('Forbidden'),
      ),
    ),
  );

  @override
  List<BeamGuard> get guards => [
        BeamGuard(
          pathBlueprints: ['/books/*'],
          check: (context, location) =>
              location.state.pathParameters['bookId'] != '2',
          showPage: forbiddenPage,
        ),
      ];
}

// AUTHENTICATION STATE
class AuthenticationStateProvider extends InheritedWidget {
  AuthenticationStateProvider({
    Key key,
    @required this.isAuthenticated,
    Widget child,
  }) : super(key: key, child: child);

  final ValueNotifier<bool> isAuthenticated;

  static AuthenticationStateProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthenticationStateProvider>();

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => true;
}

// APP
class MyApp extends StatelessWidget {
  final ValueNotifier<bool> _isAuthenticated = ValueNotifier<bool>(false);

  final authGuard = BeamGuard(
    pathBlueprints: ['/books*'],
    check: (context, location) =>
        AuthenticationStateProvider.of(context).isAuthenticated.value,
    onCheckFailed: (context, location) => print('failed $location'),
    beamTo: (context) => LoginLocation(BeamState.fromUri(Uri.parse('/login'))),
  );
  final notFoundPage = BeamPage(
    child: Scaffold(
      body: Center(
        child: Text('Not found'),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isAuthenticated,
      builder: (context, isAuthenticated, child) {
        return AuthenticationStateProvider(
          isAuthenticated: _isAuthenticated,
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerDelegate: BeamerRouterDelegate(
              locationBuilder: (state) {
                if (state.uri.pathSegments.contains('books')) {
                  return BooksLocation(state);
                }
                if (state.uri.pathSegments.contains('login')) {
                  return LoginLocation(state);
                }
                return HomeLocation(state);
              },
              notFoundPage: notFoundPage,
              guards: [authGuard],
            ),
            routeInformationParser: BeamerRouteInformationParser(),
          ),
        );
      },
    );
  }
}

void main() {
  runApp(MyApp());
}
