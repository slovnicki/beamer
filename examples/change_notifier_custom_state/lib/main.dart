import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

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
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Screen'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            final state = context.currentBeamLocation.state as BooksState;
            state.isBooksListOn = true;
          },
          child: const Text('See books'),
        ),
      ),
    );
  }
}

class BooksScreen extends StatelessWidget {
  const BooksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
      ),
      body: ListView(
        children: books
            .map(
              (book) => ListTile(
                title: Text(book['title']!),
                subtitle: Text(book['author']!),
                onTap: () {
                  final state = context.currentBeamLocation.state as BooksState;
                  state.selectedBookId = int.parse(book['id']!);
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({Key? key, required this.bookDetails})
      : super(key: key);

  final Map<String, String> bookDetails;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(bookDetails['title']!),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text('Author: ${bookDetails['author']!}'),
      ),
    );
  }
}

// CUSTOM BEAM STATE
class BooksState extends ChangeNotifier with RouteInformationSerializable {
  BooksState([
    bool isBooksListOn = false,
    int? selectedBookId,
  ])  : _isBooksListOn = isBooksListOn,
        _selectedBookId = selectedBookId;

  bool _isBooksListOn;
  bool get isBooksListOn => _isBooksListOn;
  set isBooksListOn(bool isOn) {
    _isBooksListOn = isOn;
    notifyListeners();
  }

  int? _selectedBookId;
  int? get selectedBookId => _selectedBookId;
  set selectedBookId(int? id) {
    _selectedBookId = id;
    notifyListeners();
  }

  @override
  BooksState fromRouteInformation(RouteInformation routeInformation) {
    final uri = Uri.parse(routeInformation.location ?? '/');
    if (uri.pathSegments.isNotEmpty) {
      _isBooksListOn = true;
      if (uri.pathSegments.length > 1) {
        _selectedBookId = int.parse(uri.pathSegments[1]);
      }
    }
    return this;
  }

  @override
  RouteInformation toRouteInformation() {
    String uriString = '';
    if (_isBooksListOn) {
      uriString += '/books';
    }
    if (_selectedBookId != null) {
      uriString += '/$_selectedBookId';
    }
    return RouteInformation(location: uriString.isEmpty ? '/' : uriString);
  }
}

// BEAM LOCATION
class BooksLocation extends BeamLocation<BooksState> {
  BooksLocation(RouteInformation routeInformation) : super(routeInformation);

  @override
  createState(RouteInformation routeInformation) =>
      BooksState().fromRouteInformation(routeInformation);

  @override
  List<Pattern> get pathPatterns => ['/books/:bookId'];

  @override
  List<BeamPage> buildPages(BuildContext context, BooksState state) => [
        const BeamPage(
          key: ValueKey('home'),
          child: HomeScreen(),
        ),
        if (state.isBooksListOn)
          BeamPage(
            key: ValueKey('books'),
            child: BooksScreen(),
            onPopPage: (context, delegate, state, page) {
              (state as BooksState).isBooksListOn = false;
              return true;
            },
          ),
        if (state.selectedBookId != null)
          BeamPage(
            key: ValueKey('book-${state.selectedBookId}'),
            child: BookDetailsScreen(
              bookDetails: books.firstWhere(
                (book) => int.parse(book['id']!) == state.selectedBookId,
              ),
            ),
            onPopPage: (context, delegate, state, page) {
              (state as BooksState).selectedBookId = null;
              return true;
            },
          ),
      ];
}

// APP
class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  final routerDelegate = BeamerDelegate(
    locationBuilder: (routeInformation, _) => BooksLocation(routeInformation),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: routerDelegate,
      routeInformationParser: BeamerParser(),
      backButtonDispatcher:
          BeamerBackButtonDispatcher(delegate: routerDelegate),
    );
  }
}

void main() => runApp(MyApp());
