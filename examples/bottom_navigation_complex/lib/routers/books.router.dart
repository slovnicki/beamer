import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_complex/screens/book_details.screen.dart';
import 'package:bottom_navigation_complex/screens/books.screen.dart';
import 'package:flutter/foundation.dart';

final BeamerDelegate booksRouterDelegate = BeamerDelegate(
  setBrowserTabTitle: false,
  initialPath: '/Books',
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/Books': (context, state, data) => const BeamPage(key: ValueKey('books'), child: Books()),
      '/Books/:bookID': (context, state, data) => BeamPage(
            key: ValueKey('books-${state.pathParameters["bookID"]}'),
            child: BookDetailsScreen(bookID: state.pathParameters["bookID"]!),
          ),
    },
  ),
);
