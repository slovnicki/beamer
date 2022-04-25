# Nested Navigation

When nested navigation (i.e. nested `Navigator`) is needed, one can just put `Beamer` anywhere in the Widget tree where this nested navigation will take place. There is no limit on how many `Beamer`s an app can have. Common use case is a bottom navigation, where the `BottomNavigationBar` should not be affected by navigation transitions, i.e. all the navigation is happening above it, inside another `Beamer`. In the snippet below, we also use a `key` on `Beamer` so that a `BottomNavigationBar` can manipulate just the navigation within that `Beamer`. We have a lot of examples for nested navigation:

- [Bottom Navigation](https://github.com/slovnicki/beamer/tree/master/examples/bottom_navigation)
- [Bottom Navigation 2](https://github.com/slovnicki/beamer/tree/master/examples/bottom_navigation_2)
- [Bottom Navigation with multiple Beamers](https://github.com/slovnicki/beamer/tree/master/examples/bottom_navigation_multiple_beamers)
- [Nested Navigation drawers](https://github.com/slovnicki/beamer/tree/master/examples/nested_navigation)
- [Sibling Beamers](https://github.com/slovnicki/beamer/tree/master/examples/multiple_beamers)

```dart
class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final _beamerKey = GlobalKey<BeamerState>();
  final _routerDelegate = BeamerDelegate(
    locationBuilder: BeamerLocationBuilder(
      beamLocations: [
        BooksLocation(),
        ArticlesLocation(),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Beamer(
        key: _beamerKey,
        routerDelegate: _routerDelegate,
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        beamerKey: _beamerKey,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  final routerDelegate = BeamerDelegate(
    initialPath: '/books',
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '*': (context, state, data) => HomeScreen(),
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: routerDelegate,
      routeInformationParser: BeamerParser(),
    );
  }
}
```
