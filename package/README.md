<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/resources/logo.png">
</p>

<p align="center">
<a href="https://pub.dev/packages/beamer"><img src="https://img.shields.io/pub/v/beamer.svg" alt="pub"></a>
<a href="https://codecov.io/gh/slovnicki/beamer">
<img src="https://codecov.io/gh/slovnicki/beamer/branch/master/graph/badge.svg?token=TO09CQU09C"/>
</a>
<a href="https://github.com/Solido/awesome-flutter">
<img alt="Awesome Flutter" src="https://img.shields.io/badge/Awesome-Flutter-blue.svg?longCache=true&style=flat-square" />
</a>
</p>

<p align="center">
<a href="https://github.com/slovnicki/beamer/commits/master"><img alt="GitHub commit activity" src="https://img.shields.io/github/commit-activity/m/slovnicki/beamer?label=commits"></a>
<a href="https://pub.dev/packages/beamer"><img alt="GitHub Repo stars" src="https://img.shields.io/github/stars/slovnicki/beamer"></a>
<a href="https://github.com/slovnicki/beamer/blob/master/.github/workflows/test.yml"><img alt="GitHub forks" src="https://img.shields.io/github/forks/slovnicki/beamer"></a>
</p>

<p align="center">
<a href="https://github.com/slovnicki/beamer/issues?q=is%3Aissue+is%3Aclosed"><img src="https://img.shields.io/github/issues-closed-raw/slovnicki/beamer" alt="GitHub closed issues"></a>
<a href="https://github.com/slovnicki/beamer/pulls"><img alt="GitHub closed pull requests" src="https://img.shields.io/github/issues-pr-closed-raw/slovnicki/beamer"></a>
</p>

<p align="center">
<a href="https://github.com/slovnicki/beamer/graphs/contributors"><img alt="GitHub contributors" src="https://img.shields.io/github/contributors/slovnicki/beamer"></a>
<a href="https://discord.gg/8hDJ7tP5Mz"><img src="https://img.shields.io/discord/815722893878099978" alt="Discord"></a>
</p>

<p align="center">
<a href="https://www.buymeacoffee.com/slovnicki" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="30px" width= "108px"></a>
</p>

Handle your application routing, synchronize it with browser URL and more. Beamer uses the power of Router and implements all the underlying logic for you.

---

- [Quick Start](#quick-start)
  - [Beaming](#beaming)
  - [Beaming Back](#beaming-back)
  - [Accessing nearest Beamer](#accessing-nearest-beamer)
- [Key Concepts](#key-concepts)
  - [BeamLocation](#beamlocation)
  - [BeamState](#beamstate)
- [Usage](#usage)
  - [With a List of BeamLocations](#with-a-list-of-beamlocations)
  - [With a Map of Routes](#with-a-map-of-routes)
  - [Guards](#guards)
  - [Nested Navigation](#nested-navigation)
  - [General Notes](#general-notes)
  - [Tips and Common Issues](#tips-and-common-issues)
- [Examples](#examples)
  - [Location Builders](#location-builders)
  - [Advanced Books](#advanced-books)
  - [Deep Location](#deep-location)
  - [Provider](#provider)
  - [Guards](#guards)
  - [Authentication Bloc](#authentication-bloc)
  - [Bottom Navigation](#bottom-navigation)
  - [Bottom Navigation Multiple Beamers](#bottom-navigation-multiple-beamers)
  - [Nested Navigation](#nested-navigation-1)
  - [Integration with Navigation UI Packages](#integration-with-navigation-ui-packages)
- [Migrating](#migrating)
  - [From 0.14 to 0.15](#from-014-to-015)
  - [From 0.13 to 0.14](#from-013-to-014)
  - [From 0.12 to 0.13](#from-012-to-013)
  - [From 0.11 to 0.12](#from-011-to-012)
  - [From 0.10 to 0.11](#from-010-to-011)
  - [From 0.9 to 0.10](#from-09-to-010)
  - [From 0.7 to 0.8](#from-07-to-08)
  - [From 0.4 to 0.5](#from-04-to-05)
- [Help and Chat](#help-and-chat)
- [Contributing](#contributing)

# Quick Start

The simplest setup is achieved by using the `RoutesLocationBuilder` which yields the least amount of code for a functioning application:

```dart
class MyApp extends StatelessWidget {
  final routerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        // Return either Widgets or BeamPages if more customization is needed
        '/': (context, state) => HomeScreen(),
        '/books': (context, state) => BooksScreen(),
        '/books/:bookId': (context, state) {
          // Take the parameter of interest from BeamState
          final bookId = state.pathParameters['bookId']!;
          // Return a Widget or wrap it in a BeamPage for more flexibility
          return BeamPage(
            key: ValueKey('book-$bookId'),
            title: 'A Book #$bookId',
            popToNamed: '/',
            type: BeamPageType.scaleTransition,
            child: BookDetailsScreen(bookId),
          );
        }
      },
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationParser: BeamerParser(),
      routerDelegate: routerDelegate,
    );
  }
}
```

`RoutesLocationBuilder` will create a single `BeamLocation` called `RoutesBeamLocation` which will pick and sort `routes` based on their paths, putt them into `Navigator` and rebuild the page stack.

## Beaming

Navigation is done by "beaming". One can think of it as teleporting (_beaming_) to another place in your app. Similar to `Navigator.of(context).pushReplacementNamed('/my-route')`, but Beamer is not limited to a single page, nor to a push per se. `BeamLocation`s hold an arbitrary stack of pages that get built when you beam there. Using Beamer can feel like using many of `Navigator`'s `push/pop` methods at once.

```dart
Beamer.of(context).beamToNamed('/books/2');

// or with an extension method on `BuildContext
context.beamToNamed('/books/2');

// or with some additional data
context.beamToNamed(
  '/book/2',
  data: {'note': 'this is my favorite book'},
);
```

## Beaming Back

Navigating to previous page in a page stack is done via `Navigator.of(context).pop()`. This is what the default `AppBar`'s `BackButton` will call. If you beamed to the current page stack from some _different_ page stack, then consider `beamBack` to return to your previous configuration.

All navigation history is kept in `beamingHistory`. Therefore, there is an ability to beam back to a previous entry in `beamingHistory`. For example, after spending some time on `/books` and `/books/3`, say you beam to `/articles`. From there, you can get back to your previous location as it were when you left, i.e. `/books/3`.

```dart
context.beamBack();
```

Beamer can integrate Android's back button to do `beamBack` if possible when all the pages from current `BeamLocation` have been popped. This is achieved by setting a back button dispatcher in `MaterialApp.router`.

```dart
backButtonDispatcher: BeamerBackButtonDispatcher(delegate: routerDelegate)
```

## Accessing nearest Beamer

Accessing route attributes in `Widget`s (for example, `bookId` for building `BookDetailsScreen`) can be done with

```dart
final beamState = Beamer.of(context).currentBeamLocation.state as BeamState;
final bookId = beamState.pathParameters['bookId'];
```

---
---

For those who wish to have a full control over building a page stack, we now introduce some key concepts; `BeamLocation` and `BeamState`.

# Key Concepts

At the highest level, `Beamer` is a wrapper for `Router` and uses its own implementations for `RouterDelegate` and `RouteInformationParser`. The goal of beamer is to separate the responsibility of building a page stack for `Navigator.pages` into multiple classes with custom "states", instead of one global state.

For example, we would like to handle all the profile related page stacks such as

- `[ ProfilePage ]`,
- `[ ProfilePage, FriendsPage]`,
- `[ ProfilePage, FriendsPage, FriendPage ]`,
- `[ ProfilePage, SettingsPage ]`,
- ...

with some "ProfileHandler" that knows which "state" corresponds to which page stack and updates this state as the page stack changes. Then similarly, we would like to have a "ShopHandler" for all the possible stacks of shop related pages such as

- `[ ShopPage ]`,
- `[ ShopPage, CategoriesPage ]`,
- `[ ShopPage, CategoriesPage, ItemsPage ]`,
- `[ ShopPage, CategoriesPage, ItemsPage, ItemPage ]`,
- `[ ShopPage, ItemsPage, ItemPage ]`,
- `[ ShopPage, CartPage ]`,
- ...

These "Handlers" are called `BeamLocation`s.

`BeamLocation`s cannot work by themselves. When the `RouteInformation` comes into the app through deep-link, or as initial, there must be a decision which `BeamLocation` will further handle this `RouteInformation` and build pages for the `Navigator`. This is the job of `BeamerDelegate.locationBuilder` that will take the `RouteInformation` and give it to appropriate `BeamLocation` which will create and save its own `state` from it to use it to build pages.

## BeamLocation

The most important construct in Beamer is a `BeamLocation` which represents a stack of one or more pages.  
`BeamLocation` has **3 important roles**:

- know which URIs it can handle: `pathPatterns`
- know how to build a stack of pages: `buildPages`
- keep a `state` that provides a link between the first 2

`BeamLocation` is an abstract class which needs to be extended. The purpose of having multiple `BeamLocation`s is to architecturally separate unrelated "places" in an application.

For example, `BooksLocation` can handle all the pages related to books and `ArticlesLocation` everything related to articles. In the light of this scoping, `BeamLocation` also has a `builder` for wrapping an entire stack of its pages with some `Provider` so the similar data can be shared between similar pages.

This is an example of `BeamLocation`:

```dart
class BooksLocation extends BeamLocation<BeamState> {
  BooksLocation(BeamState state) : super(state);

  @override
  List<Pattern> get pathPatterns => ['/books/:bookId'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        BeamPage(
          key: ValueKey('home'),
          child: HomeScreen(),
        ),
        if (state.uri.pathSegments.contains('books'))
          BeamPage(
            key: ValueKey('books'),
            child: BooksScreen(),
          ),
        if (state.pathParameters.containsKey('bookId'))
          BeamPage(
            key: ValueKey('book-${state.pathParameters['bookId']}'),
            child: BookDetailsScreen(
              bookId: state.pathParameters['bookId'],
            ),
          ),
      ];
}
```

## BeamState

This is the pre-made `state` that one can use for custom `BeamLocation`s. Its role is to keep various URI attributes such as `pathPatternSegments` (the segments of chosen path pattern, as each `BeamLocation` supports many of those), `pathParameters`, `queryParameters` and arbitrary key-value `data`. Those attributes are important while building pages and for `BeamState` to create an `uri` that will be consumed by the browser.

Besides purely imperative navigation via e.g. `beamToNamed('/books/3')`, this also provides a method to have declarative navigation by changing the `state` of `BeamLocation`. For example:

```dart
Beamer.of(context).currentBeamLocation.update(
  (state) => state.copyWith(
    pathPatternSegments: ['books', ':bookId'],
    pathParameters: {'bookId': '3'},
  ),
),
```

### Customizing the state (advanced)

Any class can be a state for `BeamLocation`s, for example even a `ChangeNotifier`. The only requirement is that a state for `BeamLocation` mixes with `RouteInformationSerializable` that will enforce the implementation of `fromRouteInformation` and `toRouteInformation`.

Custom state:

```dart
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
```

Custom `BeamLocation` using the above state:

```dart
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
```

Somewhere in the app:
```dart
onTap: () {
  final state = context.currentBeamLocation.state as BooksState;
  state.selectedBookId = int.parse(book['id']!);
},
```

# Usage

To use the full-featured Beamer in your app, you must (as per [official documentation](https://api.flutter.dev/flutter/widgets/Router-class.html)) construct your `*App` widget with `.router` constructor to which (along with all your regular `*App` attributes) you provide

- `routeInformationParser` that parses an incoming URI.
- `routerDelegate` that controls (re)building of `Navigator`

Here you use the Beamer implementation of those - `BeamerParser` and `BeamerDelegate`, to which you pass your `LocationBuilder`.  

In the simplest form, `LocationBuilder` is just a function which takes the current `BeamState` and returns a custom `BeamLocation` based on the URI or other state properties.

```dart
class MyApp extends StatelessWidget {
  final routerDelegate = BeamerDelegate(
    locationBuilder: (routeInformation, _) {
      if (routeInformation.location!.contains('books')) {
        return BooksLocation(routeInformation);
      }
      return HomeLocation(routeInformation);
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerDelegate: routerDelegate,
      routeInformationParser: BeamerParser(),
      backButtonDispatcher:
          BeamerBackButtonDispatcher(delegate: routerDelegate),
    );
  }
}
```

There are also two other options available, if you don't want to define a custom `locationBuilder` function.

## With a List of BeamLocations

You can use the `BeamerLocationBuilder` with a list of `BeamLocation`s. This builder will automatically select the correct location, based on the `pathPatterns` of each `BeamLocation`. In this case, define your `BeamerDelegate` like this:

```dart
final routerDelegate = BeamerDelegate(
  locationBuilder: BeamerLocationBuilder(
    beamLocations: [
      HomeLocation(),
      BooksLocation(),
    ],
  ),
);
```

## With a Map of Routes

You can use the `RoutesLocationBuilder` with a map of routes, as mentioned in [Quick Start](#quick-start). This completely removes the need for custom `BeamLocation`s, but also gives you the least amount of customizability. Still, wildcards and path parameters in your paths are supported as with all the other options.

```dart
final routerDelegate = BeamerDelegate(
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/': (context, state) => HomeScreen(),
      '/books': (context, state) => BooksScreen(),
      '/books/:bookId': (context, state) =>
        BookDetailsScreen(
          bookId: state.pathParameters['bookId']
        ),
    },
  ),
);
```

## Guards

To guard specific routes, e.g. from un-authenticated users, global `BeamGuard`s can be set up via `BeamerDelegate.guards` attribute. A most common example would be the `BeamGuard` that guards any route that **is not** `/login` and redirects to `/login` if the user is not authenticated:

```dart
BeamGuard(
  pathBlueprints: ['/login'],
  guardNonMatching: true,
  check: (context, location) => context.isUserAuthenticated(),
  beamToNamed: '/login',
)
```

Note the usage of `guardNonMatching` in this example. This is important because guards (there can be many of them, each guarding different aspects) will run in recursion on the output of previously applied guard until a "safe" route is reached. A common mistake is to setup a guard with `pathBlueprints: ['*']` to guard everything, but everything also includes `/login` (which should be a "safe" route) and this leads to an infinite loop:

- check `/login`
- user not authenticated
- beam to `/login`
- check `/login`
- user not authenticated
- beam to `/login`
- ...

Of course, `guardNonMatching` needs not to be used always. Sometimes we wish to guard just a few routes that can be specified. Here is an example of a guard that has the same role as above, implemented with `guardNonMatching: false` (default):

```dart
BeamGuard(
  pathBlueprints: ['/profile/*', '/orders/*'],
  check: (context, location) => context.isUserAuthenticated(),
  beamToNamed: '/login',
)
```

## Nested Navigation

When nested navigation is needed, you can just put `Beamer` anywhere in the Widget tree where this navigation will take place. There is no limit on how many `Beamer`s an app can have. Common use case is a bottom navigation bar ([see example](#bottom-navigation)), something like this:

```dart
class MyApp extends StatelessWidget {
  final routerDelegate = BeamerDelegate(
    initialPath: '/books',
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/*': (context, state) {
          final beamerKey = GlobalKey<BeamerState>();

          return Scaffold(
            body: Beamer(
              key: beamerKey,
              routerDelegate: BeamerDelegate(
                locationBuilder: BeamerLocationBuilder(
                  beamLocations: [
                    BooksLocation(),
                    ArticlesLocation(),
                  ],
                ),
              ),
            ),
            bottomNavigationBar: BottomNavigationBarWidget(
              beamerKey: beamerKey,
            ),
          );
        }
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

## General Notes

- When extending `BeamLocation`, two methods need to be implemented: `pathPatterns` and `buildPages`.
  - `buildPages` returns a stack of pages that will be built by `Navigator` when you beam there, and `pathPatterns` is there for Beamer to decide which `BeamLocation` corresponds to which URI.
  - `BeamLocation` keeps query and path parameters from URI in its `BeamState`. The `:` is necessary in `pathPatterns` if you _might_ get path parameter from browser.

- `BeamPage`'s child is an arbitrary `Widget` that represents your app screen / page.
  - `key` is important for `Navigator` to optimize rebuilds. This should be a unique value for "page state".
  - `BeamPage` creates `MaterialPageRoute` by default, but other transitions can be chosen by setting `BeamPage.type` to one of available `BeamPageType`.

**NOTE** that "Navigator 1.0" can be used alongside Beamer. You can easily `push` pages with `Navigator.of(context)`, but those will not be contributing to the URI. This is often needed when some info/helper page needs to be shown that doesn't influence the browser's URL. And of course, when using Beamer on mobile, this is a non-issue as there is no URL.

## Tips and Common Issues

- removing the `#` from URL can be done by calling `Beamer.setPathUrlStrategy()` before `runApp()`.
- `BeamPage.title` is used for setting the browser tab title by default and can be opt-out by setting `BeamerDelegate.setBrowserTabTitle` to `false`.
- [Losing state on hot reload](https://github.com/slovnicki/beamer/issues/193)

# Examples

Check out all examples [here](https://github.com/slovnicki/beamer/tree/master/examples).

## Location Builders

Here is a recreation of the example app from [this article](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade) where you can learn a lot about Navigator 2.0. 
It contains three different options of building the locations. The full code is available [here](https://github.com/slovnicki/beamer/tree/master/examples/location_builders).

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/examples/location_builders/example-location-builders.gif" alt="example-location-builders">

## Advanced Books

For a step further, we add more flows to demonstrate the power of Beamer. The full code is available [here](https://github.com/slovnicki/beamer/tree/master/examples/advanced_books).

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/examples/advanced_books/example-advanced-books.gif" alt="example-advanced-books">

## Deep Location

You can instantly beam to a location in your app that has many pages stacked (deep linking) and then pop them one by one or simply `beamBack` to where you came from. The full code is available [here](https://github.com/slovnicki/beamer/tree/master/examples/deep_location). Note that `beamBackOnPop` parameter of `beamToNamed` might be useful here to override `AppBar`'s `pop` with `beamBack`.

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/examples/deep_location/example-deep-location.gif" alt="example-deep-location">

```dart
ElevatedButton(
    onPressed: () => context.beamToNamed('/a/b/c/d'),
    //onPressed: () => context.beamToNamed('/a/b/c/d', beamBackOnPop: true),
    child: Text('Beam deep'),
),
```

## Provider

You can override `BeamLocation.builder` to provide some data to the entire location, i.e. to all the `pages`. The full code is available [here](https://github.com/slovnicki/beamer/tree/master/examples/provider).

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/examples/provider/example-provider.gif" alt="example-provider">

```dart
// In your location implementation
@override
Widget builder(BuildContext context, Navigator navigator) {
  return MyProvider<MyObject>(
    create: (context) => MyObject(),
    child: navigator,
  );
}
```

## Guards

You can define global guards (for example, authentication guard) or location guards that keep a specific location safe. The full code is available [here](https://github.com/slovnicki/beamer/tree/master/examples/guards).

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/examples/guards/example-guards.gif" alt="example-guards">

- Global Guards

```dart
BeamerDelegate(
  guards: [
    // Guard /books and /books/* by beaming to /login if the user is unauthenticated:
    BeamGuard(
      pathBlueprints: ['/books', '/books/*'],
      check: (context, location) => context.isAuthenticated,
      beamToNamed: '/login',
    ),
  ],
  ...
),
```

- Location (local) Guards

```dart
// in your location implementation
@override
List<BeamGuard> get guards => [
  // Show forbiddenPage if the user tries to enter books/2:
  BeamGuard(
    pathBlueprints: ['/books/2'],
    check: (context, location) => false,
    showPage: forbiddenPage,
  ),
];
```

## Authentication Bloc

Here is an example on how to use `BeamGuard`s for an authentication flow. It uses [flutter_bloc](https://pub.dev/packages/flutter_bloc) for state management. The code is available [here](https://github.com/slovnicki/beamer/tree/master/examples/authentication_bloc).

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/examples/authentication_bloc/example-authentication-bloc.gif" alt="example-authentication-bloc">

## Bottom Navigation

An examples of putting `Beamer` into the Widget tree is when using a bottom navigation bar. The code is available [here](https://github.com/slovnicki/beamer/tree/master/examples/bottom_navigation).

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/examples/bottom_navigation/example-bottom-navigation.gif" alt="example-bottom-navigation">

## Bottom Navigation Multiple Beamers

The code for the bottom navigation example app with multiple beamers is available [here](https://github.com/slovnicki/beamer/tree/master/examples/bottom_navigation_multiple_beamers)

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/examples/bottom_navigation_multiple_beamers/example-bottom-navigation-multiple-beamers.gif" alt="example-bottom-navigation-multiple-beamers">

## Nested Navigation

**NOTE:** In all nested `Beamer`s, full paths must be specified when defining `BeamLocation`s and beaming. (support for relative paths is in progress)

The code for the nested navigation example app is available [here](https://github.com/slovnicki/beamer/tree/master/examples/nested_navigation)

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/examples/nested_navigation/example-nested-navigation.gif" alt="example-nested-navigation">

## Integration with Navigation UI Packages

- [Animated Rail Example](https://github.com/slovnicki/beamer/tree/master/examples/animated_rail), with [animated_rail](https://pub.dev/packages/animated_rail) package.
- ... (Contributions are very welcome! Add your suggestion [here](https://github.com/slovnicki/beamer/issues/79) or make a PR.)

<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/examples/animated_rail/example-animated-rail.gif" alt="example-animated-rail" width="240">

# Migrating

## From 0.14 to 0.15

(TBA)

See [CHANGELOG](https://github.com/slovnicki/beamer/blob/master/package/CHANGELOG.md).

## From 0.13 to 0.14

Instead of

```dart
locationBuilder: SimpleLocationBuilder(
  routes: {
    '/': (context) => MyWidget(),
    '/another': (context) {
      final state = context.currentBeamLocation.state;
      return AnotherThatNeedsState(state);
    }
  }
)
```

now we have

```dart
locationBuilder: SimpleLocationBuilder(
  routes: {
    '/': (context, state) => MyWidget(),
    '/another': (context, state) => AnotherThatNeedsState(state)
  }
)
```

## From 0.12 to 0.13

- rename `BeamerRouterDelegate` to `BeamerDelegate`
- rename `BeamerRouteInformationParser` to `BeamerParser`
- rename `pagesBuilder` to `buildPages`
- rename `Beamer.of(context).currentLocation` to `Beamer.of(context).currentBeamLocation`

## From 0.11 to 0.12

- There's no `RootRouterDelegate` anymore. Just rename it to `BeamerDelegate`. If you were using its `homeBuilder`, use `SimpleLocationBuilder` and  then `routes: {'/': (context) => HomeScreen()}`.
- Behavior of `beamBack` was changed to go to previous `BeamState`, not `BeamLocation`. If this is not what you want, use `popBeamLocation()` that has the same behavior as old `beamback`.

## From 0.10 to 0.11

- `BeamerDelegate.beamLocations` is now `locationBuilder`. See `BeamerLocationBuilder` for easiest migration.
- `Beamer` now takes `BeamerDelegate`, not `BeamLocations` directly
- `buildPages` now also brings `state`

## From 0.9 to 0.10

- `BeamLocation` constructor now takes only `BeamState state`. (there's no need to define special constructors and call `super` if you use `beamToNamed`)
- most of the attributes that were in `BeamLocation` are now in `BeamLocation.state`. When accessing them through `BeamLocation`:
  - `pathParameters` is now `state.pathParameters`
  - `queryParameters` is now `state.queryParameters`
  - `data` is now `state.data`
  - `pathSegments` is now `state.pathBlueprintSegments`
  - `uri` is now `state.uri`

## From 0.7 to 0.8

- rename `pages` to `buildPages` in `BeamLocation`s
- pass `beamLocations` to `BeamerDelegate` instead of `BeamerParser`. See [Usage](#usage)
## From 0.4 to 0.5

- instead of wrapping `MaterialApp` with `Beamer`, use `*App.router()`
- `String BeamLocation.pathBlueprint` is now `List<String> BeamLocation.pathBlueprints`
- `BeamLocation.withParameters` constructor is removed and all parameters are handled with 1 constructor. See example if you need `super`.
- `BeamPage.page` is now called `BeamPage.child`

# Help and Chat

For any problems, questions, suggestions, fun,... join us at Discord <a href="https://discord.gg/8hDJ7tP5Mz"><img src="https://img.shields.io/discord/815722893878099978" alt="Discord"></a>

# Contributing

This package is still in early stages. To see the upcoming features, check the [Issue board](https://github.com/slovnicki/beamer/issues).

If you notice any bugs not present in issues, please file a new issue. If you are willing to fix or enhance things yourself, you are very welcome to make a pull request. Before making a pull request:

- if you wish to solve an existing issue, please let us know in issue comments first.
- if you have another enhancement in mind, create an issue for it first, so we can discuss your idea.

Also, you can <a href="https://www.buymeacoffee.com/slovnicki" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="20px" width= "72px"></a> to speed up the development.
