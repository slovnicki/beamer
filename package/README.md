<p align="right">
<a href="https://docs.flutter.dev/development/packages-and-plugins/favorites"><img src="https://raw.githubusercontent.com/slovnicki/beamer/master/resources/flutter_favorite_badge.png" width="80" alt="favorite"></a>
</p>

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

Handle your application routing on all platforms, synchronize it with browser's URL bar and more. Beamer uses the power of [Router](https://api.flutter.dev/flutter/widgets/Router-class.html) and implements all the underlying logic for you.

---

- [Quick Start](#quick-start)
  - [Navigating](#navigating)
  - [Navigating Back](#navigating-back)
    - [Upward (popping a page from stack)](#upward-popping-a-page-from-stack)
    - [Reverse Chronological (beaming to previous state)](#reverse-chronological-beaming-to-previous-state)
    - [Android back button](#android-back-button)
  - [Accessing nearest Beamer](#accessing-nearest-beamer)
  - [Using "Navigator 1.0"](#using-navigator-10)
- [Key Concepts](#key-concepts)
  - [BeamLocation](#beamlocation)
  - [BeamState](#beamstate)
  - [Custom State](#custom-state)
- [Usage](#usage)
  - [With a List of BeamLocations](#with-a-list-of-beamlocations)
  - [With a Map of Routes](#with-a-map-of-routes)
  - [Guards](#guards)
  - [Nested Navigation](#nested-navigation)
  - [General Notes](#general-notes)
  - [Page Keys](#page-keys)
  - [Tips and Common Issues](#tips-and-common-issues)
- [Examples](#examples)
- [Migrating](#migrating)
- [Help and Chat](#help-and-chat)
- [Contributing](#contributing)

# Quick Start

The simplest setup is achieved by using the `RoutesLocationBuilder` which yields the least amount of code. This is a great choice for applications with fewer navigation scenarios or with shallow page stacks, i.e. when pages are rarely stacked on top of each other.

```dart
class MyApp extends StatelessWidget {
  final routerDelegate = BeamerDelegate(
    locationBuilder: RoutesLocationBuilder(
      routes: {
        // Return either Widgets or BeamPages if more customization is needed
        '/': (context, state, data) => HomeScreen(),
        '/books': (context, state, data) => BooksScreen(),
        '/books/:bookId': (context, state, data) {
          // Take the path parameter of interest from BeamState
          final bookId = state.pathParameters['bookId']!;
          // Collect arbitrary data that persists throughout navigation
          final info = (data as MyObject).info;
          // Use BeamPage to define custom behavior
          return BeamPage(
            key: ValueKey('book-$bookId'),
            title: 'A Book #$bookId',
            popToNamed: '/',
            type: BeamPageType.scaleTransition,
            child: BookDetailsScreen(bookId, info),
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

`RoutesLocationBuilder` will pick and sort `routes` based on their paths.  
For example, navigating to `/books/1` will match all 3 entries from `routes` and stack them on top of each other. Navigating to `/books` will match the first 2 entries from `routes`.

The corresponding pages are put into `Navigator.pages` and `BeamerDelegate` (re)builds the `Navigator`, showing the selected stack of pages on the screen.

---

**Why do we have a `locationBuilder` and what is a `BeamLocation`, the output of it?**

`BeamLocation` is an entity which, based on its `state`, decides what pages should go into `Navigator.pages`. `locationBuilder` chooses the appropriate `BeamLocation` that should further handle the incoming `RouteInformation`. This is most commonly achieved by examining `BeamLocation.pathPatterns`.

`RoutesLocationBuilder` returns a special type of `BeamLocation` - `RoutesBeamLocation`, that has opinionated implementation for most common navigation use-cases. If `RoutesLocationBuilder` doesn't provide desired behavior or enough customization, one can extend `BeamLocation` to define and organize the behavior for any number of page stacks that can go into `Navigator.pages`.

Further reading: [BeamLocation](#beamlocation), [BeamState](#beamstate).

## Navigating

Navigation is done by "beaming". One can think of it as teleporting (_beaming_) to another place in your app. Similar to `Navigator.of(context).pushReplacementNamed('/my-route')`, but Beamer is not limited to a single page, nor to a push per se. `BeamLocation`s produce a stack of pages that get built when you beam there. Beaming can feel like using many of `Navigator`'s `push/pop` methods at once.

```dart
// Basic beaming
Beamer.of(context).beamToNamed('/books/2');

// Beaming with an extension method on BuildContext
context.beamToNamed('/books/2');

// Beaming with additional data that persist 
// throughout navigation withing the same BeamLocation
context.beamToNamed('/book/2', data: MyObject());
```

## Navigating Back

There are 2 types of going back, i.e. [reverse navigation](https://material.io/design/navigation/understanding-navigation.html#reverse-navigation); **upward** and **reverse chronological**.

### Upward (popping a page from stack)

Upward navigation is navigating to a previous page in the current page stack. This is better known as "pop" and is done through `Navigator`'s `pop`/`maybePop` methods. The default `AppBar`'s `BackButton` will call this if nothing else is specified.

```dart
Navigator.of(context).maybePop();
```

### Reverse Chronological (beaming to previous state)

Reverse chronological navigation is navigating to wherever we were before. In case of deep-linking (e.g. coming to `/books/2` from `/authors/3` instead of from `/books`), this will not be the same as `pop`. Beamer keeps navigation history in `beamingHistory` so there is an ability to navigate chronologically to a previous entry in `beamingHistory`. This is called "beaming back". Reverse chronological navigation is also what the browser's back button does, although not via `beamBack`, but through its internal mechanics.

```dart
Beamer.of(context).beamBack();
```

### Android back button

Integration of Android's back button with beaming is achieved by setting a `backButtonDispatcher` in `MaterialApp.router`. This dispatcher needs a reference to the same `BeamerDelegate` that is set for `routerDelegate`.

```dart
MaterialApp.router(
  ...
  routerDelegate: beamerDelegate,
  backButtonDispatcher: BeamerBackButtonDispatcher(delegate: beamerDelegate),
)
```

`BeamerBackButtonDispatcher` will try to `pop` first and fallback to `beamBack` if `pop` is not possible. If `beamBack` returns `false` (there is nowhere to beam back to), Android's back button will close the app, possibly opening a previously used app that was responsible for opening this app via deep-link. `BeamerBackButtonDispatcher` can be configured to `alwaysBeamBack` (meaning it won't attempt `pop`) or to not `fallbackToBeamBack` (meaning it won't attempt `beamBack`).

## Accessing nearest Beamer

Accessing route attributes in `Widget`s (for example, `bookId` for building `BookDetailsScreen`) can be done with

```dart
@override
Widget build(BuildContext context) {
  final beamState = Beamer.of(context).currentBeamLocation.state as BeamState;
  final bookId = beamState.pathParameters['bookId'];
  ...
}
```

## Using "Navigator 1.0"

Note that "Navigator 1.0" (i.e. imperative `push`/`pop` and friends) can be used alongside Beamer. We already saw that `Navigator.pop` is used for upward navigation. This tells us that we are using the same `Navigator`, but just with a different API.

Pages pushed with `Navigator.of(context).push` (or any similar action) will not be contributing to `BeamLocation`'s state, meaning the browser's URL will not change. One can update just the URL via `Beamer.of(context).updateRouteInformation(...)`. Of course, when using Beamer on mobile, this is a non-issue as there is no URL to be seen.

In general, every navigation scenario should be implementable declaratively (defining page stacks) instead of imperatively (pushing), but the difficulty to do so may vary.

---

For intermediate and advanced usage, we now introduce some key concepts; `BeamLocation` and `BeamState`.

# Key Concepts

At the highest level, `Beamer` is a wrapper for `Router` and uses its own implementations for `RouterDelegate` and `RouteInformationParser`. The goal of Beamer is to separate the responsibility of building a page stack for `Navigator.pages` into multiple classes with different states, instead of one global state for all page stacks.

For example, we would like to handle all the profile related page stacks such as

- `[ ProfilePage ]`,
- `[ ProfilePage, FriendsPage]`,
- `[ ProfilePage, FriendsPage, FriendDetailsPage ]`,
- `[ ProfilePage, SettingsPage ]`,
- ...

with some "ProfileHandler" that knows which "state" corresponds to which page stack. Then similarly, we would like to have a "ShopHandler" for all the possible stacks of shop related pages such as

- `[ ShopPage ]`,
- `[ ShopPage, CategoriesPage ]`,
- `[ ShopPage, CategoriesPage, ItemsPage ]`,
- `[ ShopPage, CategoriesPage, ItemsPage, ItemDetailsPage ]`,
- `[ ShopPage, ItemsPage, ItemDetailsPage ]`,
- `[ ShopPage, CartPage ]`,
- ...

These "Handlers" are called `BeamLocation`s.

`BeamLocation`s cannot work by themselves. When the `RouteInformation` comes into the app via deep-link, as initial or as a result of beaming, there must be a decision which `BeamLocation` will further handle this `RouteInformation` and build pages for the `Navigator`. This is the job of `BeamerDelegate.locationBuilder` that will take the `RouteInformation` and give it to appropriate `BeamLocation` based on `pathPatterns` it supports. `BeamLocation` will then create and save its own `state` from it to use for building a page stack.

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/resources/flow_diagram.png">
</p>

## BeamLocation

The most important construct in Beamer is a `BeamLocation` which represents a state of a stack of one or more pages.  
`BeamLocation` has **3 important roles**:

- know which URIs it can handle: `pathPatterns`
- know how to build a stack of pages: `buildPages`
- keep a `state` that provides a link between the first 2

`BeamLocation` is an abstract class which needs to be extended. The purpose of having multiple `BeamLocation`s is to architecturally separate unrelated "places" in an application. For example, `BooksLocation` can handle all the pages related to books and `ArticlesLocation` everything related to articles.

This is an example of a `BeamLocation`:

```dart
class BooksLocation extends BeamLocation<BeamState> {
  @override
  List<Pattern> get pathPatterns => ['/books/:bookId'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final pages = [
      const BeamPage(
        key: ValueKey('home'),
        child: HomeScreen(),
      ),
      if (state.uri.pathSegments.contains('books'))
        const BeamPage(
          key: ValueKey('books'),
          child: BooksScreen(),
        ),
    ];
    final String? bookIdParameter = state.pathParameters['bookId'];
    if (bookIdParameter != null) {
      final bookId = int.tryParse(bookIdParameter);
      pages.add(
        BeamPage(
          key: ValueKey('book-$bookIdParameter'),
          title: 'Book #$bookIdParameter',
          child: BookDetailsScreen(bookId: bookId),
        ),
      );
    }
    return pages;
  }
}
```

## BeamState

`BeamState` is a pre-made state that can be used for custom `BeamLocation`s. It keeps various URI attributes such as `pathPatternSegments` (the segments of chosen path pattern, as each `BeamLocation` supports many of those), `pathParameters` and `queryParameters`.

## Custom State

Any class can be used as state for a `BeamLocation`, e.g. `ChangeNotifier`. The only requirement is that a state for `BeamLocation` mixes with `RouteInformationSerializable` that will enforce the implementation of `fromRouteInformation` and `toRouteInformation`.

Full example app can be seen [here](https://github.com/slovnicki/beamer/tree/master/examples/change_notifier_custom_state).

A custom `BooksState`:

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

Then the `BeamLocation` using above state would look something like this. Note that not all these overrides are needed if custom state is not a `ChangeNotifier`.

```dart
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
          child: BookDetailsScreen(bookId: state.selectedBookId),
        ),
      );
    }
    return pages;
  }
}
```

When using this custom `BooksState`, we can navigate fully declaratively via:

```dart
onTap: () {
  final state = context.currentBeamLocation.state as BooksState;
  state.selectedBookId = 3;
},
```

Note that `Beamer.of(context).beamToNamed('/books/3')` would produce the same result.

# Usage

To use Beamer (or any `Router`), one must construct the `*App` widget with `.router` constructor (read more at [Router documentation](https://api.flutter.dev/flutter/widgets/Router-class.html)).
Along with all the regular `*App` attributes, we must also provide

- `routeInformationParser` that parses an incoming URI.
- `routerDelegate` that controls (re)building of `Navigator`

Here we use Beamer's implementation of those - `BeamerParser` and `BeamerDelegate`, to which we pass the desired `LocationBuilder`. In the simplest form, `LocationBuilder` is just a function which takes the current `RouteInformation` (and `BeamParameters` which is not important here) and returns a `BeamLocation` based on the URI or other state properties.

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

There are also two other options available, if we don't want to define a custom `locationBuilder` function.

## With a List of BeamLocations

`BeamerLocationBuilder` can be used with a list of `BeamLocation`s. This builder will automatically select the correct `BeamLocation` based on its `pathPatterns`.

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

We can use the `RoutesLocationBuilder` with a map of routes, as mentioned in [Quick Start](#quick-start). This completely removes the need for custom `BeamLocation`s, but also gives the least amount of customization. Still, wildcards and path parameters are supported as with all the other options.

```dart
final routerDelegate = BeamerDelegate(
  locationBuilder: RoutesLocationBuilder(
    routes: {
      '/': (context, state, data) => HomeScreen(),
      '/books': (context, state, data) => BooksScreen(),
      '/books/:bookId': (context, state, data) =>
        BookDetailsScreen(
          bookId: state.pathParameters['bookId'],
        ),
    },
  ),
);
```

## Guards

To guard specific routes, e.g. from un-authenticated users, global `BeamGuard`s can be set up via `BeamerDelegate.guards` property. A most common example would be the `BeamGuard` that guards any route that **is not** `/login` and redirects to `/login` if the user is not authenticated:

```dart
BeamGuard(
  // on which path patterns (from incoming routes) to perform the check
  pathPatterns: ['/login'],
  // perform the check on all patterns that **don't** have a match in pathPatterns
  guardNonMatching: true,
  // return false to redirect
  check: (context, location) => context.isUserAuthenticated(),
  // where to redirect on a false check
  beamToNamed: (origin, target) => '/login',
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

Of course, `guardNonMatching` needs not to be used. Sometimes we wish to guard just a few routes that can be specified explicitly. Here is an example of a guard that has the same role as above, implemented with `guardNonMatching: false` (default):

```dart
BeamGuard(
  pathBlueprints: ['/profile/*', '/orders/*'],
  check: (context, location) => context.isUserAuthenticated(),
  beamToNamed: (origin, target) => '/login',
)
```

## Nested Navigation

When nested navigation is needed, one can just put `Beamer` anywhere in the Widget tree where this nested navigation will take place. There is no limit on how many `Beamer`s an app can have. Common use case is a bottom navigation bar ([see example](#bottom-navigation)), something like this:

```dart
class MyApp extends StatelessWidget {
  final routerDelegate = BeamerDelegate(
    initialPath: '/books',
    locationBuilder: RoutesLocationBuilder(
      routes: {
        '/*': (context, state, data) {
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
  - `buildPages` returns a stack of pages that will be built by `Navigator` when you beam there, and `pathPatterns` is there for Beamer to decide which `BeamLocation` handles which URI.
  - `BeamLocation` keeps query and path parameters from URI in its `BeamState`. The `:` is necessary in `pathPatterns` if you _might_ get path parameter from browser.

- `BeamPage`'s child is an arbitrary `Widget` that represents your app screen / page.
  - `key` is important for `Navigator` to optimize rebuilds. This needs to be a unique value (e.g. [ValueKey](https://api.flutter.dev/flutter/foundation/ValueKey-class.html)) for "page state". (see [Page Keys](#page-keys))
  - `BeamPage` creates `MaterialPageRoute` by default, but other transitions can be chosen by setting `BeamPage.type` to one of available `BeamPageType`.

## Page Keys

When we beam somewhere, we are putting a new list of pages into `Navigator.pages`. Now the `Navigator` has to decide on the transition between the old list of pages and the new list of pages.

In order to know which pages changed and which pages stayed the same, `Navigator` looks at the pages' `key`s. If the `key`s of 2 pages that are compared are equal (important here: `null` == `null`), `Navigator` treats them as the same page and does not rebuild nor replace that page.

One should always set a `BeamPage.key` (most likely a [ValueKey](https://api.flutter.dev/flutter/foundation/ValueKey-class.html)).  
If `key`s are not set, after beaming somewhere via e.g. `Beamer.of(context).beamToNamed('/somewhere')`, no change will happen in the UI. The _new_ `BeamPage` doesn't build since `Navigator` thinks it is the same as the already displayed one.

## Tips and Common Issues

- removing the `#` from URL can be done by calling `Beamer.setPathUrlStrategy()` before `runApp()`.
- `BeamPage.title` is used for setting the browser tab title by default and can be opt-out by setting `BeamerDelegate.setBrowserTabTitle` to `false`.
- [Losing state on hot reload](https://github.com/slovnicki/beamer/issues/193)

# Examples

**Check out all examples (with gifs) [here](https://github.com/slovnicki/beamer/tree/master/examples).**

- [Location Builders](https://github.com/slovnicki/beamer/tree/master/examples/location_builders): a recreation of the example app from [this article](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade) where you can learn a lot about Navigator 2.0.
This example showcases all 3 options of using `locationBuilder`.

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/examples/location_builders/example-location-builders.gif" alt="example-location-builders">

- [Advanced Books](https://github.com/slovnicki/beamer/tree/master/examples/advanced_books): for a step further, we add more flows to demonstrate the power of Beamer.

- [Deep Location](https://github.com/slovnicki/beamer/tree/master/examples/deep_location): you can instantly beam to a location in your app that has many pages stacked (deep linking) and then pop them one by one or simply `beamBack` to where you came from. Note that `beamBackOnPop` parameter of `beamToNamed` might be useful here to override `AppBar`'s `pop` with `beamBack`.

```dart
ElevatedButton(
    onPressed: () => context.beamToNamed('/a/b/c/d'),
    //onPressed: () => context.beamToNamed('/a/b/c/d', beamBackOnPop: true),
    child: Text('Beam deep'),
),
```

- [Provider](https://github.com/slovnicki/beamer/tree/master/examples/provider): you can override `BeamLocation.builder` to provide some data to the entire location, i.e. to all the `pages`.

```dart
// In your BeamLocation implementation
@override
Widget builder(BuildContext context, Navigator navigator) {
  return MyProvider<MyObject>(
    create: (context) => MyObject(),
    child: navigator,
  );
}
```

- [Guards](https://github.com/slovnicki/beamer/tree/master/examples/guards): you can define global guards (for example, authentication guard) or `BeamLocation.guards` that keep a specific stack safe.

```dart
// Global guards at BeamerDelegate
BeamerDelegate(
  guards: [
    // Guard /books and /books/* by beaming to /login if the user is unauthenticated:
    BeamGuard(
      pathBlueprints: ['/books', '/books/*'],
      check: (context, location) => context.isAuthenticated,
      beamToNamed: (origin, target) => '/login',
    ),
  ],
  ...
),
```

```dart
// Local guards at BeamLocation
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

- [Authentication Bloc](https://github.com/slovnicki/beamer/tree/master/examples/authentication_bloc): an example on how to use `BeamGuard`s for an authentication flow with [flutter_bloc](https://pub.dev/packages/flutter_bloc) for state management.

- [Bottom Navigation](https://github.com/slovnicki/beamer/tree/master/examples/bottom_navigation): an examples of putting `Beamer` into the Widget tree is when using a bottom navigation bar.

- [Bottom Navigation With Multiple Beamers](https://github.com/slovnicki/beamer/tree/master/examples/bottom_navigation_multiple_beamers): having `Beamer` in each tab.

- [Nested Navigation](https://github.com/slovnicki/beamer/tree/master/examples/nested_navigation): nested navigation drawer

**NOTE:** In all nested `Beamer`s, full paths must be specified when defining `BeamLocation`s and beaming.

- [Animated Rail](https://github.com/slovnicki/beamer/tree/master/examples/animated_rail): example with [animated_rail](https://pub.dev/packages/animated_rail) package.

# Migrating

## From 0.14 to 1.0.0

An article explaning changes and providing a migration guide is available [here at Medium](https://medium.com/flutter-community/beamer-v1-0-0-is-out-whats-new-and-how-to-migrate-b251b3758e3c).
Most notable breaking changes:

- If using a `SimpleLocationBuilder`:

Instead of

```dart
locationBuilder: SimpleLocationBuilder(
  routes: {
    '/': (context, state) => MyWidget(),
    '/another': (context, state) => AnotherThatNeedsState(state)
  }
)
```

now we have

```dart
locationBuilder: RoutesLocationBuilder(
  routes: {
    '/': (context, state, data) => MyWidget(),
    '/another': (context, state, data) => AnotherThatNeedsState(state)
  }
)
```

- If using a custom `BeamLocation`:

Instead of

```dart
class BooksLocation extends BeamLocation {
  @override
  List<Pattern> get pathBlueprints => ['/books/:bookId'];

  ...
}
```

now we have

```dart
class BooksLocation extends BeamLocation<BeamState> {
  @override
  List<Pattern> get pathPatterns => ['/books/:bookId'];

  ...
}
```

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

If you notice any bugs not present in [issues](https://github.com/slovnicki/beamer/issues), please file a new issue. If you are willing to fix or enhance things yourself, you are very welcome to make a pull request. Before making a pull request:

- if you wish to solve an existing issue, please let us know in issue comments first.
- if you have another enhancement in mind, create an issue for it first, so we can discuss your idea.

See you at our list of awesome contributors!

1. [devj3ns](https://github.com/devj3ns)
2. [ggirotto](https://github.com/ggirotto)
3. [matuella](https://github.com/matuella)
4. [youssefali424](https://github.com/youssefali424)
5. [schultek](https://github.com/schultek)
6. [hatem-u](https://github.com/hatem-u)
7. [jeduden](https://github.com/jeduden)
8. [omacranger](https://github.com/omacranger)
9. [samdogg7](https://github.com/samdogg7)
10. [Goddchen](https://github.com/Goddchen)
11. [spicybackend](https://github.com/spicybackend)
12. [cedvdb](https://github.com/cedvdb)
13. [gabriel-mocioaca](https://github.com/gabriel-mocioaca)
14. [AdamBuchweitz](https://github.com/AdamBuchweitz)
15. [nikitadol](https://github.com/nikitadol)
16. [ened](https://github.com/ened)
17. [luketg8](https://github.com/luketg8)
18. [Zambrella](https://github.com/Zambrella)
19. [piyushchauhan](https://github.com/piyushchauhan)
20. [marcguilera](https://github.com/marcguilera)
21. [mat100payette](https://github.com/mat100payette)
21. [Lorenzohidalgo](https://github.com/Lorenzohidalgo)
22. [timshadel](https://github.com/timshadel)
23. [definev](https://github.com/definev)
24. [britannio](https://github.com/britannio)
25. [satyajitghana](https://github.com/satyajitghana)
26. [jpangburn](https://github.com/jpangburn)
