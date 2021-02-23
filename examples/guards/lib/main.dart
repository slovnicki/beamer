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
                  onPressed: () =>
                      context.beamTo(BooksLocation(pathBlueprint: '/books')),
                  child: Text('Beam to books location'),
                ),
                ElevatedButton(
                  onPressed: () => context.beamTo(
                    BooksLocation(
                      pathBlueprint: '/books/:bookId',
                      pathParameters: {'bookId': '2'},
                    ),
                  ),
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
                  onTap: () => Beamer.of(context).updateCurrentLocation(
                    pathBlueprint: '/books/:bookId',
                    pathParameters: {'bookId': book['id']},
                  ),
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
              onPressed: () => Beamer.of(context).updateCurrentLocation(
                pathBlueprint: '/books/:bookId/genres',
                data: {'book': book},
              ),
              child: Text('See genres'),
            ),
            ElevatedButton(
              onPressed: () => Beamer.of(context).updateCurrentLocation(
                pathBlueprint: '/books/:bookId/buy',
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
  @override
  List<String> get pathBlueprints => ['/'];

  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('home'),
          child: HomeScreen(),
        ),
      ];
}

class LoginLocation extends BeamLocation {
  LoginLocation() : super(pathBlueprint: '/login');

  @override
  List<String> get pathBlueprints => ['/login'];

  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('login'),
          child: LoginScreen(),
        ),
      ];
}

class BooksLocation extends BeamLocation {
  BooksLocation({
    String pathBlueprint,
    Map<String, String> pathParameters,
    Map<String, String> queryParameters,
    Map<String, dynamic> data,
  }) : super(
          pathBlueprint: pathBlueprint,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          data: data,
        );

  @override
  List<String> get pathBlueprints => ['/books/:bookId'];

  @override
  List<BeamPage> get pages => [
        ...HomeLocation().pages,
        if (pathSegments.contains('books'))
          BeamPage(
            key: ValueKey('books'),
            child: BooksScreen(),
          ),
        if (pathParameters.containsKey('bookId'))
          BeamPage(
            key: ValueKey('book-${pathParameters['bookId']}'),
            child: BookDetailsScreen(
              bookId: pathParameters['bookId'],
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
              location.pathParameters['bookId'] != '2',
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

  final BeamLocation initialLocation = HomeLocation();
  final List<BeamLocation> beamLocations = [
    HomeLocation(),
    BooksLocation(),
  ];
  final authGuard = BeamGuard(
    pathBlueprints: ['/books*'],
    check: (context, location) =>
        AuthenticationStateProvider.of(context).isAuthenticated.value,
    beamTo: (context) => LoginLocation(),
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
              initialLocation: initialLocation,
              notFoundPage: notFoundPage,
              guards: [authGuard],
            ),
            routeInformationParser: BeamerRouteInformationParser(
              beamLocations: beamLocations,
            ),
          ),
        );
      },
    );
  }
}

void main() {
  runApp(MyApp());
}
