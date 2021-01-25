# Beamer

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
<a href="https://www.buymeacoffee.com/slovnicki" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="30px" width= "108px"></a>
</p>

Handle your application routing, synchronize it with browser URL and more. `Beamer` uses the power of Navigator 2.0 features and implements all the underlying logic for you.

## Table of Contents

- [Key Concepts](#key-concepts)
- [Examples](#examples)
    - [Books](#books)
    - [Deep Location](#deep-location)
    - [Sibling Routers](#sibling-routers) (WIP)
    - [Nested Routers](#nested-routers) (WIP)
- [Usage](#usage)
  - [Using Beamer Around Entire App](#using-beamer-around-entire-app)
  - [Using Beamer Deeper in Widget Tree](#using-beamer-deeper-in-widget-tree) (WIP)
  - [General Notes](#general-notes)
- [Contributing](#contributing)

## Key Concepts

The key concept of Beamer is a `BeamLocation` which represents a stack of one or more pages. You will be extending `BeamLocation` to define your app's locations to which you can then _beam to_ using

```dart
Beamer.of(context).beamTo(MyLocation())
```

or

```dart
context.beamTo(MyLocation())
```

You can think of it as _teleporting_ / _beaming_ to another place in your app. Similar to `Navigator.of(context).pushReplacementNamed('/my-route')`, but Beamer is not limited to a single page, nor to a push _per se_. You can create an arbitrary stack of pages that gets build when you beam there. Using Beamer _can_ feel like using many of `Navigator`'s `push/pop` methods at once.

## Examples

### Books

This is a recreation of books example from [this article](https://medium.com/flutter/learning-flutters-new-navigation-and-routing-system-7c9068155ade) where you can learn a lot about Navigator 2.0. See [Example](https://pub.dev/packages/beamer/example) for full application code of this example.

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/res/example-books.gif" alt="example-url-sync" style="margin-right:16px;margin-left:16px">

### Deep Location

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/res/example-deep-location.gif" alt="example-deep-location" width="420" style="margin-right:16px;margin-left:16px">

### Sibling Routers

Coming soon...

### Nested Routers

Coming soon...

## Usage

### Using Beamer Around Entire App

In order to use Beamer on your entire app, you must wrap `MaterialApp` with `Beamer` to which you pass your `BeamLocation`s. Optionally, if you're using Beamer in Flutter web, you may pass `notFoundPage` which will be shown when URI coming from browser is not among the ones you defined in your `BeamLocation`s.

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Beamer(
      initialLocation: HomeLocation(),
      beamLocations: [
        HomeLocation(),
        BooksLocation(),
      ],
      notFoundPage: Scaffold(body: Center(child: Text('Not found'))),
      app: MaterialApp(),
    );
  }
}
```

An example of above book example's `BeamLocation`s would be:

```dart
class HomeLocation extends BeamLocation {
  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('home'),
          page: HomeScreen(),
        ),
      ];

  @override
  String get pathBlueprint => '/';
}

class BooksLocation extends BeamLocation {
  BooksLocation() : super();

  BooksLocation.withParameters({
    Map<String, String> path,
    Map<String, String> query,
  }) : super.withParameters(path: path, query: query);

  @override
  List<BeamPage> get pages => [
        ...HomeLocation().pages,
        BeamPage(
          key: ValueKey('books-${queryParameters['title'] ?? ''}'),
          page: BooksScreen(
            titleQuery: queryParameters['title'] ?? '',
          ),
        ),
        if (pathParameters.containsKey('id'))
          BeamPage(
            key: ValueKey('book-${pathParameters['id']}'),
            page: BookDetailsScreen(
              bookId: pathParameters['id'],
            ),
          ),
      ];

  @override
  String get pathBlueprint => '/books/:id';
}
```

### Using Beamer Deeper in Widget Tree

Coming soon...

### General Notes

When defining your `BeamLocation`, you need to implement 2 getters; `pages` and `pathBlueprint`. `pages` represent a stack that will be built by `Navigator` when you beam there, and `pathBlueprint` is there for the Beamer to decide which `BeamLocation` corresponds to an URL coming from browser.

As we can see, `BeamLocation` can take query and path parameters from URI. (the `:` is necessary in `pathBlueprint` if you _might_ get path parameter from browser).

`HomeScreen`, `BooksScreen` and `BookDetailsScreen` are arbitrary `Widgets` that represent your app screens / pages.

`BeamPage` creates `MaterialPageRoute`, but you can extends `BeamPage` and override `createRoute` to make your own implementation instead. The `key` is important for `Navigator` to optimize its rebuilds.

## Contributing

This package is still in early stages. To see the upcoming features, check the [Issue board](https://github.com/slovnicki/beamer/issues).

If you notice any bugs not present in issues, please file a new issue. If you are willing to fix or enhance things yourself, you are very welcome to make a pull request. Before making a pull request;

- if you wish to solve an existing issue, please let us know in issue comments first
- if you have another enhancement in mind, create an issue for it first so we can discuss your idea

Also, you can <a href="https://www.buymeacoffee.com/slovnicki" target="_blank"><img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me A Coffee" height="20px" width= "72px"></a> to speed up the development.

