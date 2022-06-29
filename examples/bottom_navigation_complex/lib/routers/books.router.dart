import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_complex/screens/books.screen.dart';
import 'package:flutter/foundation.dart';

final BeamerDelegate booksRouterDelegate = BeamerDelegate(
  setBrowserTabTitle: false,
  initialPath: '/Books',
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/Books': (context, state, data) => const BeamPage(key: ValueKey('books'), child: Books()),
    },
  ),
);
