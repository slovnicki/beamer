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
        child: ElevatedButton(
          onPressed: () => context.beamToNamed('/a/b/c/d'),
          //onPressed: () => context.beamToNamed('/a/b/c/d', beamBackOnPop: true),
          child: Text('Beam deep'),
        ),
      ),
    );
  }
}

class SomeScreen extends StatelessWidget {
  SomeScreen(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
    );
  }
}

class DeepestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('4')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => context.beamBack(),
          child: Text('Beam back'),
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

class DeepLocation extends BeamLocation {
  DeepLocation(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => ['/a/b/c/d'];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) => [
        ...HomeLocation(state).pagesBuilder(context, state),
        if (state.uri.pathSegments.contains('a'))
          BeamPage(
            key: ValueKey('a'),
            child: SomeScreen('1'),
          ),
        if (state.uri.pathSegments.contains('b'))
          BeamPage(
            key: ValueKey('b'),
            child: SomeScreen('2'),
          ),
        if (state.uri.pathSegments.contains('c'))
          BeamPage(
            key: ValueKey('c'),
            child: SomeScreen('3'),
          ),
        if (state.uri.pathSegments.contains('d'))
          BeamPage(
            key: ValueKey('d'),
            child: DeepestScreen(),
          ),
      ];
}

// APP
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: BeamerRouterDelegate(
        locationBuilder: (state) {
          if (state.uri.pathSegments.contains('a')) {
            return DeepLocation(state);
          }
          return HomeLocation(state);
        },
      ),
      routeInformationParser: BeamerRouteInformationParser(),
    );
  }
}

void main() {
  runApp(MyApp());
}
