import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              onPressed: () => context.beamTo(FirstLocation()),
              child: Text('go to first location'),
            ),
            SizedBox(height: 16.0),
            RaisedButton(
              onPressed: () => context.beamTo(SecondLocation()),
              child: Text('go to second location'),
            ),
          ],
        ),
      ),
    );
  }
}

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Screen'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () => context.beamTo(SecondLocation()),
          child: Text('go to second location'),
        ),
      ),
    );
  }
}

class SecondScreen extends StatelessWidget {
  final String name;
  final String text;

  SecondScreen({
    this.name,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Second Screen'),
      ),
      body: Center(
        child: Text(name + ', ' + text),
      ),
    );
  }
}

// LOCATIONS
class HomeLocation extends BeamLocation {
  @override
  List<Page> get pages => [
        BeamPage(
          key: ValueKey(uri),
          page: HomeScreen(),
        ),
      ];

  @override
  String get pathBlueprint => '/';
}

class FirstLocation extends BeamLocation {
  @override
  List<Page> get pages => [
        BeamPage(
          key: ValueKey(uri),
          page: FirstScreen(),
        ),
      ];

  @override
  String get pathBlueprint => '/first-screen';
}

class SecondLocation extends BeamLocation {
  @override
  List<Page> get pages => [
        BeamPage(
          key: ValueKey(HomeLocation().pathBlueprint),
          page: HomeScreen(),
        ),
        BeamPage(
          key: ValueKey(uri),
          page: SecondScreen(
            name: pathParameters['name'] ?? 'no name',
            text: queryParameters['text'] ?? 'no text',
          ),
        ),
      ];

  @override
  String get pathBlueprint => '/second-screen/:name';
}

// APP
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Beamer(
      initialLocation: HomeLocation(),
      beamLocations: [
        HomeLocation(),
        FirstLocation(),
        SecondLocation(),
      ],
      app: MaterialApp(),
    );
  }
}

void main() {
  runApp(MyApp());
}
