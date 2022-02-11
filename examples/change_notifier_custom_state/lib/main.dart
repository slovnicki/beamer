import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

// DATA
class Book {
  const Book(this.id, this.title, this.author);

  final int id;
  final String title;
  final String author;
}

const List<Book> books = [
  Book(1, 'Stranger in a Strange Land', 'Robert A. Heinlein'),
  Book(2, 'Foundation', 'Isaac Asimov'),
  Book(3, 'Fahrenheit 451', 'Ray Bradbury'),
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
                title: Text(book.title),
                subtitle: Text(book.author),
                onTap: () {
                  final state = context.currentBeamLocation.state as BooksState;
                  state.selectedBookId = book.id;
                },
              ),
            )
            .toList(),
      ),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  const BookDetailsScreen({Key? key, required this.book}) : super(key: key);

  final Book? book;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book?.title ?? 'Not Found'),
      ),
      body: book != null
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Author: ${book!.author}'),
            )
          : const SizedBox.shrink(),
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

  void updateWith(bool isBooksListOn, int? selectedBookId) {
    _isBooksListOn = isBooksListOn;
    _selectedBookId = selectedBookId;
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
  BooksState createState(RouteInformation routeInformation) {
    final state = BooksState().fromRouteInformation(routeInformation)
      ..addListener(notifyListeners);
    return state;
  }

  @override
  void initState() {
    super.initState();
    state.addListener(notifyListeners);
  }

  @override
  void updateState(RouteInformation routeInformation) {
    final booksState = BooksState().fromRouteInformation(routeInformation);
    state.updateWith(booksState.isBooksListOn, booksState.selectedBookId);
  }

  @override
  void disposeState() {
    state.removeListener(notifyListeners);
    super.disposeState();
  }

  @override
  List<Pattern> get pathPatterns => ['/books/:bookId'];

  @override
  List<BeamPage> buildPages(BuildContext context, BooksState state) {
    final pages = [
      const BeamPage(
        key: ValueKey('home'),
        child: HomeScreen(),
      ),
      if (state.isBooksListOn)
        const BeamPage(
          key: ValueKey('books'),
          child: BooksScreen(),
        ),
    ];
    if (state.selectedBookId != null) {
      pages.add(
        BeamPage(
          key: ValueKey('book-${state.selectedBookId}'),
          title: 'Book #${state.selectedBookId}',
          child: BookDetailsScreen(book: books[state.selectedBookId!]),
        ),
      );
    }
    return pages;
  }
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
