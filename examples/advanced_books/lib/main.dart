import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'package:advanced_books/locations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final notFoundPage = BeamPage(
    child: Scaffold(
      body: Center(
        child: Text('Not found'),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: BeamerRouterDelegate(
        locationBuilder: (state) {
          if (state.pathBlueprintSegments.contains('books')) {
            return BooksLocation(state);
          }
          if (state.pathBlueprintSegments.contains('articles')) {
            return ArticlesLocation(state);
          }
          return HomeLocation(state);
        },
        notFoundPage: notFoundPage,
      ),
      routeInformationParser: BeamerRouteInformationParser(),
    );
  }
}
