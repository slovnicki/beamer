# Beamer

[![pub package](https://img.shields.io/pub/v/beamer.svg)](https://pub.dev/packages/beamer)
![tests](https://github.com/slovnicki/beamer/workflows/tests/badge.svg)
[![style](https://dart-lang.github.io/linter/lints/style-pedantic.svg)](https://github.com/google/pedantic)

Handle your application routing, synchronize it with browser URL and more. `Beamer` uses the power of Navigator 2.0 features and implements all the underlying logic for you.

## Table of Contents

- [Key Concepts](#key-concepts)
- [Usage](#usage)
- [Examples](#examples)
    - [Basic](#basic)
    - [Advanced](#advanced)
- [Contributing](#contributing)

## Key Concepts

The key concept of Beamer is a `BeamLocation` which represents a stack of one or more pages. You will be extending `BeamLocation` to define your app's locations to which you can then _beam to_ using

```dart
context.beamTo(MyLocation())
```

You can think of it as _teleporting_ / _beaming_ to another place in your app. Similar to `Navigator.of(context).pushNamed('/my-route')`, but Beamer is not limited to a single page, nor to a push _per se_. You can create an arbitrary stack of pages that gets build when you beam there.

## Usage

In order to use Beamer on your entire app, you must wrap `MaterialApp` with `Beamer` to which you pass your `BeamLocation`s.

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Beamer(
      initialLocation: HomeLocation(),
      beamLocations: [
        HomeLocation(),
        SecondLocation(),
      ],
      app: MaterialApp(),
    );
  }
}
```

An example of above `BeamLocation`s would be:

```dart
class HomeLocation extends BeamLocation {
  @override
  List<Page> get pages => [
        BeamPage(
          identifier: uri,
          page: HomeScreen(),
        ),
      ];

  @override
  String get pathBlueprint => '/';
}

class SecondLocation extends BeamLocation {
  @override
  List<Page> get pages => [
        BeamPage(
          identifier: HomeLocation().pathBlueprint,
          page: HomeScreen(),
        ),
        BeamPage(
          identifier: uri,
          page: SecondScreen(
            name: pathParameters['name'] ?? 'no name',
            text: queryParameters['text'] ?? 'no text',
          ),
        ),
      ];

  @override
  String get pathBlueprint => '/second-screen/:name';
}
```

When defining your `BeamLocation`, you need to implement 2 getters; `pages` and `pathBlueprint`. `pages` represent a stack that will be built by `Navigator` when you beam there, and `pathBlueprint` is there for the Beamer to decide which `BeamLocation` corresponds to an URL coming from browser.

As we can see, `BeamLocation` can take query and path parameters from URI. (the `:` is necessary in `pathBlueprint` if you _might_ get path parameter from browser).

`HomeScreen` and `SecondScreen` are arbitrary `Widgets` that represent your app screens / pages.

`BeamPage` creates `MaterialPageRoute`, but you can extends `BeamPage` and override `createRoute` to make your own implementation instead. The `key` is important for `Navigator` to optimize its rebuilds.

With this setup, now we can use, for example, `context.beamTo(SecondLocation())` to go to a place in our application where the page stack of `[HomeScreen, SecondScreen]` will be built.

## Examples

### URL Sync

See [Example](https://pub.dev/packages/beamer/example) for full application code for this example.

<p align="center">
<img src="https://raw.githubusercontent.com/slovnicki/beamer/master/res/example.gif" alt="example" style="margin-right:16px;margin-left:16px">

### Deep Location

Coming soon...

## Contributing

This package is still in early stages. To see the upcoming features, check the [Issue board](https://github.com/slovnicki/beamer/issues).

If you notice any bugs not present in issues, please file a new issue. If you are willing to fix or enhance things yourself, you are very welcome to make a pull request. Before making a pull request;

- if you wish to solve an existing issue, please let us know in issue comments first
- if you have another enhancement in mind, create an issue for it first so we can discuss your idea
