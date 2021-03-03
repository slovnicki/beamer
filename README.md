<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/logo.png">
</p>

<p align="center">
<a href="https://pub.dev/packages/beamer"><img src="https://img.shields.io/pub/v/beamer.svg" alt="pub"></a>
<a href="https://github.com/slovnicki/beamer/blob/master/.github/workflows/test.yml"><img src="https://github.com/slovnicki/beamer/workflows/tests/badge.svg" alt="test"></a>
<a href="https://github.com/google/pedantic"><img src="https://dart-lang.github.io/linter/lints/style-pedantic.svg" alt="style"></a>
</p>

<p align="center">
<a href="https://github.com/slovnicki/beamer/commits/master"><img src="https://img.shields.io/github/commit-activity/m/slovnicki/beamer" alt="GitHub commit activity"></a>
<a href="https://github.com/slovnicki/beamer/issues"><img src="https://img.shields.io/github/issues-raw/slovnicki/beamer" alt="GitHub open issues"></a>
<a href="https://github.com/slovnicki/beamer/issues?q=is%3Aissue+is%3Aclosed"><img src="https://img.shields.io/github/issues-closed-raw/slovnicki/beamer" alt="GitHub closed issues"></a>
<a href="https://github.com/slovnicki/beamer/blob/master/LICENSE"><img src="https://img.shields.io/github/license/slovnicki/beamer" alt="Licence"></a>
</p>

<p align="center">
<a href="https://discord.gg/8hDJ7tP5Mz"><img src="https://img.shields.io/discord/815722893878099978" alt="Discord"></a>
</p>

<p align="center">
<a href="https://www.buymeacoffee.com/slovnicki" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="30px" width= "108px"></a>
</p>

Handle your application routing, synchronize it with browser URL and more. Beamer uses the power of Navigator 2.0 API and implements all the underlying logic for you.

---

- [Key Concepts](#key-concepts)
  - [Beaming](#beaming)
  - [Updating](#updating)
  - [Beaming Back](#beaming-back)
- [Examples](#examples)
    - [Books](#books)
    - [Advanced Books](#advanced-books)
    - [Deep Location](#deep-location)
    - [Location Builder](#location-builder)
    - [Guards](#guards)
    - [Beamer Widget](#beamer-widget)
    - [Integration with Navigation UI Packages](#integration-with-navigation-ui-packages)
- [Usage](#usage)
  - [On Entire App](#on-entire-app)
  - [As a Widget](#as-a-widget)
  - [General Notes](#general-notes)
- [Migrating](#migrating)
  - [From 0.7 to 0.8](#from-0.7-to-0.8)
  - [From 0.4 to 0.5](#from-0.4-to-0.5)
- [Help and Chat](#help-and-chat)
- [Contributing](#contributing)

# Key Concepts

The key concept of Beamer is a `BeamLocation` which represents a stack of one or more pages whose ordering and rebuild you control within `pagesBuilder`.

## Beaming

You will be extending `BeamLocation` to define your app's locations to which you can then _beam to_ using

```dart
Beamer.of(context).beamTo(MyLocation());

// or with an extension on BuildContext
context.beamTo(MyLocation());
```

or _beam to_ a specific configuration of some location;

```dart
context.beamToNamed('/books/2');

// or more explicitly
context.beamTo(
  BooksLocation(
    pathBlueprint: '/books/:bookId',
    pathParameters: {'bookId': '2'},
  ),
);
```

You can think of it as _teleporting_ (_beaming_) to another place in your app. Similar to `Navigator.of(context).pushReplacementNamed('/my-route')`, but Beamer is not limited to a single page, nor to a push _per se_. You can define an arbitrary stack of pages that gets build when you beam there. Using Beamer can feel like using many of `Navigator`'s `push/pop` methods at once.

You can carry an arbitrary key/value data in a location. This can be accessed from every page and updated as you travel through a location.

```dart
context.beamToNamed(
  '/book/2',
  data: {'note': 'this is my favorite book'},
);
```

## Updating

Once at a `BeamLocation`, it is preferable to update the current location instead of beaming if you plan to stay at same location. For example, for going from `/books` to `/books/3` (which are both handled by `BooksLocation`);

```dart
context.updateCurrentLocation(
  pathParameters: {'bookId': '3'},
  data: {'note': 'this is not my favorite book'},
);
```

If unsure what is your current location; `Beamer.of(context).currentLocation`.

## Beaming Back

All `BeamLocation`s act as a kind of sub-routers and keep their state. Therefore, there is an ability to _beam back_ to the previous location. For example, after spending some time on `/books` and `/books/3`, say you beam to `/articles` which is handled by another `BeamLocation` (e.g. `ArticlesLocation`). From there, you can get back to your previous location as it were when you left, i.e. `/books/3`;

```dart
context.beamBack();
```

You can check whether you can beam back with `Beamer.of(context).canBeamBack` or even inspect the location you'll be beaming back to: `Beamer.of(context).beamBackLocation`.

---

**Note** that "Navigator 1.0" can be used alongside Beamer. You can easily `push` or `pop` pages with `Navigator.of(context)`, but those will not be contributing to the URI. This is often needed when some info/helper page needs to be shown that doesn't influence the browser's URL. And of course, when using Beamer on mobile, this is a non-issue as there is no URL.

# Examples

## Books

Here is a recreation of books example from [this article](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade) where you can learn a lot about Navigator 2.0. See [Example](https://pub.dev/packages/beamer/example) for full application code of this example.

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/res/example-books.gif" alt="example-books" width="520">

## Advanced Books

For a step further, we add more flows to demonstrate the power of Beamer. The full code is available [here](https://github.com/slovnicki/beamer_examples/tree/master/advanced_books).

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer_examples/master/advanced_books/example-advanced-books.gif" alt="example-advanced-books" width="520">

## Deep Location

You can instantly beam to a location in your app that has many pages stacked (deep linking) and then pop them one by one or simply `beamBack` to where you came from. The full code is available [here](https://github.com/slovnicki/beamer_examples/tree/master/deep_location). Note that `beamBackOnPop` parameter of `beamTo` might be useful here to override `AppBar`'s `pop` with `beamBack`.

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer_examples/master/deep_location/example-deep-location.gif" alt="example-deep-location" width="260">

```dart
ElevatedButton(
  onPressed: () => context.beamTo(DeepLocation('/a/b/c/d')),
  // onPressed: () => context.beamTo(DeepLocation('/a/b/c/d'), beamBackOnPop: true),
  child: Text('Beam deep'),
),
```

## Location Builder

You can override `BeamLocation.builder` to provide some data to the entire location, i.e. to all of the `pages`. The full code is available [here](https://github.com/slovnicki/beamer_examples/tree/master/location_builder).

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer_examples/master/location_builder/example-location-builder.gif" alt="example-location-builder"  width="260">

```dart
// in your location implementation
@override
Widget builder(BuildContext context, Navigator navigator) {
  return MyProvider<MyObject>(
    create: (context) => MyObject(),
    child: navigator,
  );
}
```

## Guards

You can define global guards (for example, authentication guard) or location guards that keep a specific location safe. The full code is available [here](https://github.com/slovnicki/beamer_examples/tree/master/guards).

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer_examples/master/guards/example-guards.gif" alt="example-guards"  width="520">

- Global Guards

```dart
BeamerRouterDelegate(
  initialLocation: initialLocation,
  guards: [
    BeamGuard(
      pathBlueprints: ['/books*'],
      check: (context, location) => AuthenticationStateProvider.of(context).isAuthenticated.value,
      beamTo: (context) => LoginLocation(),
    ),
  ],
),
```

- Location (local) Guards

```dart
// in your location implementation
@override
List<BeamGuard> get guards => [
  BeamGuard(
    pathBlueprints: ['/books/*'],
    check: (context, location) => location.pathParameters['bookId'] != '2',
    showPage: forbiddenPage,
  ),
];
```

## Beamer Widget

An example of putting `Beamer`(s) into the Widget tree. _This is not yet fully functional for web usage_; setting the URL from browser doesn't update the state properly. It should work when [nested routers issue](https://github.com/slovnicki/beamer/issues/4) is settled.

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer_examples/master/bottom_navigation/example-bottom-navigation-mobile.gif" alt="example-bottom-navigation-mobile" width="240" style="margin-right: 32px">
<img src="https://raw.githubusercontent.com/slovnicki/beamer_examples/master/bottom_navigation_multiple_beamers/example-bottom-navigation-multiple-beamers.gif" alt="example-bottom-navigation-multiple-beamers" width="240">

- [Bottom navigation example](https://github.com/slovnicki/beamer_examples/tree/master/bottom_navigation)
```dart
class MyApp extends StatelessWidget {
  final _beamerKey = GlobalKey<BeamerState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Beamer(
          key: _beamerKey,
          beamLocations: _beamLocations,
        ),
        bottomNavigationBar: BottomNavigationBarWidget(
          beamerKey: _beamerKey,
        ),
      ),
    );
  }
}
```

- [Bottom navigation example with multiple Beamers](https://github.com/slovnicki/beamer_examples/tree/master/bottom_navigation_multiple_beamers)
```dart
class MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: [
            Beamer(
              beamLocations: [ArticlesLocation()],
            ),
            Container(
              color: Colors.blueAccent,
              padding: const EdgeInsets.all(32.0),
              child: Beamer(
                beamLocations: [BooksLocation()],
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          items: [
            BottomNavigationBarItem(label: 'A', icon: Icon(Icons.article)),
            BottomNavigationBarItem(label: 'B', icon: Icon(Icons.book)),
          ],
          onTap: (index) => setState(() => _currentIndex = index),
        ),
      ),
    );
  }
}
```

---
## Integration with Navigation UI Packages

- [Animated Rail Example](https://github.com/slovnicki/beamer_examples/tree/master/animated_rail), with [animated_rail](https://pub.dev/packages/animated_rail) package.
- ... (contributions are very welcome; add your suggestion [here](https://github.com/slovnicki/beamer/issues/79) or make a PR [here](https://github.com/slovnicki/beamer_examples))

<img src="https://raw.githubusercontent.com/slovnicki/beamer_examples/master/animated_rail/example-animated-rail.gif" alt="example-animated-rail" width="240">

---
# Usage
## On Entire App

In order to use Beamer on your entire app, you must (as per [official documentation](https://api.flutter.dev/flutter/widgets/Router-class.html)) construct your `*App` widget with `.router` constructor to which (along with all your regular `*App` attributes) you provide

- `routerDelegate` that controls (re)building of `Navigator` pages and
- `routeInformationParser` that decides which URI corresponds to which `Router` state/configuration, in our case - `BeamLocation`.

Here you use the Beamer implementation of those - `BeamerRouterDelegate` and `BeamerRouteInformationParser`, to which you pass your `BeamLocation`s.

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: BeamerRouterDelegate(
        beamLocations: [
          HomeLocation(),
          BooksLocation(),
        ],
      ),
      routeInformationParser: BeamerRouteInformationParser(),
      ...
    );
  }
}
```

## As a Widget

_(not yet fully functional on web, regarding URL parsing)_

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Beamer(
          beamLocations: [
            HomeLocation(),
            BooksLocation(),
          ],
        ),
        ...
      ),
    );
  }
}
```

## General Notes

- When extending `BeamLocation`, two methods need to be implemented; `pathBlueprints` and `pagesBuilder`.
  - `pagesBuilder` returns a stack of pages that will be built by `Navigator` when you beam there, and `pathBlueprints` is there for Beamer to decide which `BeamLocation` corresponds to an URL coming from browser.
  - `BeamLocation` takes query and path parameters from URI. The `:` is necessary in `pathBlueprints` if you _might_ get path parameter from browser.

- `BeamPage`'s child is an arbitrary `Widgets` that represent your app screen / page.
  - `key` is important for `Navigator` to optimize rebuilds. This should be an unique value for "page state".
  - `BeamPage` creates `MaterialPageRoute`, but you can extends `BeamPage` and override `createRoute` to make your own implementation instead.

# Migrating

## From 0.7 to 0.8

- rename `pages` to `pagesBuilder` in `BeamLocation`s
- pass `beamLocations` to `BeamerRouterDelegate` instead of `BeamerRouteInformationParser`. See [Usage](#usage)
## From 0.4 to 0.5

- instead of wrapping `MaterialApp` with `Beamer`, use `*App.router()`
- `String BeamLocation.pathBlueprint` is now `List<String> BeamLocation.pathBlueprints`
- `BeamLocation.withParameters` constructor is removed and all parameters are handled with 1 constructor. See example if you need `super`.
- `BeamPage.page` is now called `BeamPage.child`

# Help and Chat

For any problems, questions, suggestions, fun,... join us at Discord <a href="https://discord.gg/8hDJ7tP5Mz"><img src="https://img.shields.io/discord/815722893878099978" alt="Discord"></a>

# Contributing

This package is still in early stages. To see the upcoming features, check the [Issue board](https://github.com/slovnicki/beamer/issues).

If you notice any bugs not present in issues, please file a new issue. If you are willing to fix or enhance things yourself, you are very welcome to make a pull request. Before making a pull request;

- if you wish to solve an existing issue, please let us know in issue comments first
- if you have another enhancement in mind, create an issue for it first so we can discuss your idea

Also, you can <a href="https://www.buymeacoffee.com/slovnicki" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="20px" width= "72px"></a> to speed up the development.

