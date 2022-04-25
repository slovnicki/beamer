# Beam Locations

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

When using a custom `MyState` that can notify its `BeamLocation` when it updates, we can also navigate like this

```dart
onTap: () {
  final state = context.currentBeamLocation.state as MyState;
  state.selectedBookId = 3;
},
```

Note that `Beamer.of(context).beamToNamed('/books/3')` would produce the same result.
