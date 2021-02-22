import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'package:advanced_books/locations.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final BeamLocation initialLocation = HomeLocation();
  final List<BeamLocation> beamLocations = [
    HomeLocation(),
    BooksLocation(),
    ArticlesLocation(),
  ];
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
        initialLocation: initialLocation,
        notFoundPage: notFoundPage,
      ),
      routeInformationParser: BeamerRouteInformationParser(
        beamLocations: beamLocations,
      ),
    );
  }
}
