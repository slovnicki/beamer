# 0.15.0

- **BREAKING:** "top-level state", the one in `BeamerDelegate` is now `RouteInformation` instead of `BeamState`
    - `BeamerDelegate.state` doesn't exist anymore and is replaced with `BeamerDelegate.configuration` which is `RouteInformation` and not `BeamState`
    - `locationBuilder` now works with `RouteInformation` and `BeamConfiguration` instead of `BeamState`
    - `super()` constructor on `BeamLocation` now takes optional `RouteInformation` instead of `BeamState`
    - in order to continue using custom `BeamLocation`s with `BeamState` state, generic type has to be specified; `class MyBeamLocation extends BeamLocation<BeamState>`
- **BREAKING:** `pathBlueprints` is renamed to `pathPatterns`
    - `BeamLocation.pathPatterns` is `List<Pattern>`
    - `BeamState.pathBlueprintSegments` renamed to `BeamState.pathPatternSegments`
    - `BeamGuard.pathBlueprints` renamed to `BeamGuard.pathPatterns`
- **BREAKING:** `SimpleLocationBuilder` is renamed to `RoutesLocationBuilder`
    - also the `SimpleBeamLocation` is renamed to `RoutesBeamLocation`
- **BREAKING:** `beamStateHistory` and `beamLocationHistory` have been replaced with `beamingHistory` that is a `List<BeamLocation>` and each `BeamLocation` has `history` that is `List<HistoryElement>` where `HistoryElement` holds `state` and `BeamParameters`.
- **BREAKING:** `BeamerDelegate.listener` has been renamed to `BeamerDelegate.appliedRouteListener`.
- **BREAKING:** The property `pageRouteBuilder` in `BeamPage` is replaced with a new property `routeBuilder` which works with any `RouteBuilder` not just `PageRouteBuilder`.
- **BREAKING:** `BeamGuard` `beamTo` receives the origin and target `BeamLocation`s alongside `BuildContext`.
- **BREAKING:** `BeamGuard` `beamToNamed` is now a function that receives the origin and target `BeamLocation`s and return a `String`.
- **Add:** [guard_riverpod example](https://github.com/slovnicki/beamer/tree/master/examples/guard_riverpod)
- **Add:** [firebase_core example](https://github.com/slovnicki/beamer/tree/master/examples/firebase_core)
- **Add:** [firebase_auth example](https://github.com/slovnicki/beamer/tree/master/examples/firebase_auth)
- **Add:** [change_notifier_custom_state example](https://github.com/slovnicki/beamer/tree/master/examples/change_notifier_custom_state)
- **Add:** `BeamerBackButtonDispatcher.alwaysBeamBack` to make Android back button always go to previous route, even if it can `pop`.
- **Add:** `BeamPage.routePop` that can be used for `onPopPage` instead of default `pathsegmentPop`
- **Add:** `BeamerDelegate.buildListener`, which is called after the pages are built.
- **Add:** `fullScreenDialog` property to `BeamPage`
- **Add:** [flutter_lints](https://pub.dev/packages/flutter_lints)
- **Add:** a [presentation](https://github.com/slovnicki/beamer/blob/master/resources/navigator-2.0-and-beamer.pdf) resource about beamer
- **Fix:** clearing history range when using `popToNamed`
- **Fix:** passing `BeamPage.title` to `CupertinoPageRoute`s

# 0.14.1

- **Add:** `updateParent` (default `true`) to `BeamerDelegate`
- **Fix:** ignoring query on initial path

# 0.14.0

- **BREAKING:** `routes` in `SimpleLocationBuilder` now also bring the `state`
- **Add:** support for `RegExp` in `pathBlueprints` (in both `BeamGuard`s and `BeamLocation`s)
- **Add:** updating nested `Beamer`s on parent navigation
- **Add:** `onBack` to `BeamerbackButtonDispatcher`
- **Add:** `navigator` getter to `BeamerDelegate`
- **Add:** `beamStateHistory` and `BeamLocationHistory` to `context` extension methods
- **Add:** `data` parameter to `beamBack`
- **Change:** `BeamPage.pageRouteBuilder` return type to be a superclass
- **Fix:** removing last `BeamState` from history on default `pop`
- **Fix:** `BeamGuard` behavior on query parameters
- **Fix:** ignoring trailing `/` in URIs
- **Fix:** keeping `data` as long as possible when beaming
- Improved Android back button behavior
- Improved bottom navigation examples
- Improved README

# 0.13.3

- **Add:** [authentication_riverpod](https://github.com/slovnicki/beamer/tree/master/examples/authentication_riverpod) example
- **Add:** "Tips and Common Issues" to README
- **Fix:** Drawer pop
- **Fix:** `beamBackOnPop:true` while beaming
- Make `beamStateHistory` and `beamLocationHistory` public

# 0.13.2

- **Add:** `BeamerDelegate.notFoundRedirectNamed`
- **Add:** public static `BeamPage.defaultOnPopPage`
- **Fix:** top-level guard updating URL
- Improved guards example
- Improved README Quick Start

# 0.13.1

- **Fix:** correctly updating delegate after applying guards

# 0.13.0

- **BREAKING:** renamed `BeamerRouterDelegate` to `BeamerDelegate`
- **BREAKING:** renamed `BeamerRouteInformationParser` to `BeamerParser`
- **BREAKING:** renamed `pagesBuilder` to `buildPages`
- **BREAKING:** renamed `Beamer.of(context).currentLocation` to `Beamer.of(context).currentBeamLocation`
- **Add:** `BeamPage.popToNamed` and `BeamPage.onPopPage` for fine control of popping
- **Add:** `BeamPage.title` for setting the browser tab title
- **Add:** `SimpleLocationBuilder` can now mix `BeamPage`s and `Widget`s
- **Add:** `BeamerParser.onParse` for intercepting the parsed state on app load
- **Add:** encoding the `data` into browser history
- **Add:** blocking capability to `BeamGuard`s
- **Add:** slide and scale transitions to `BeamPageType`
- **Add:** optional `transitionDelegate` for beaming
- **Fix:** cascade guarding
- **Fix:** delegate listener not being called always
- All examples improved and migrated to null-safety
- Improved documentation

# 0.12.4

- **Add** `Beamer.setPathUrlStrategy()` for removing `#` from URL
- **Add** persistent auth state on browser refresh in [authentication_bloc example](https://github.com/slovnicki/beamer/tree/master/examples/authentication_bloc)
- **Fix** detection of `NotFound` when using `SimpleLocationBuilder`
- **Fix** updating route on guard actions
- **Fix** not pushing `BeamState` in history if it's on top
- **Fix** taking `currentLocation` on setting initial path

# 0.12.3

- **Add** [authentication_bloc example](https://github.com/slovnicki/beamer/tree/master/examples/authentication_bloc)
- **Fix** `SimpleBeamLocation` ignoring query
- **Fix** updating delegate state on location state change

# 0.12.2

- **Add** `listener` attribute to `BeamerRouterDelegate`
- **Add** `root` attribute to `BeamerRouterDelegate` and `{bool root = false}` attribute to `Beamer.of`
- **Add** `canHandle(Uri uri)` method to `BeamLocation`
- **Fix** Updating parent on nested navigation
- **Fix** README typos

# 0.12.1

- **Fix** updating browser history

# 0.12.0

- **BREAKING**: There's no `RootRouterDelegate` any more. Just rename it to `BeamerRouterDelegate`. If you were using its `homeBuilder`, use `SimpleLocationBuilder` and  then `routes: {'/': (context) => HomeScreen()}`
- **BREAKING**: Behavior of `beamBack()` was changed to go to previous `BeamState`, not `BeamLocation`. If this is not what you want, use `popBeamLocation()` that has the same behavior as old `beamback()`
- **Fix**: Important [bug](https://github.com/slovnicki/beamer/issues/183) while using multiple sibling `Beamer`s

# 0.11.4

- **Fix** `currentLocation` without listener after guard beam

# 0.11.3

- **Add** `beamBackTransitionDelegate` to `BeamerRouterDelegate`
- **Add** `transition_delegates.dart` with some useful transition delegates
- **Tweak** deep_location example to show this more clearly

# 0.11.2

- **Fix** lost `navigationNotifier` on rebuilds with nested `Beamer`s

# 0.11.1

- **Fix** possibly null `_currentLocation`

# 0.11.0+1

- add missing ToC titles

# 0.11.0

- migrated to null safety
- **BREAKING:** `Beamer` now takes `routerDelegate`, not `beamLocations` directly
- **BREAKING:** `BeamerRouterDelegate.beamLocations` is now `locationBuilder`
- **BREAKING:** `pagesBuilder` now also brings `state`
- **Add** `beamToNamed` to `BeamGuard`
- **Add** various `LocationBuilder`s
- **Add** `transitionDelegate` to `BeamLocation` and `BeamerRouterDelegate`
- **Add** `type` and `pageRouteBuilder` to `BeamPage`, for transition control
- **Add** `initialPath` to `BeamerRouterDelegate`
- **Add** `popTo`/`popToNamed` options for beaming
- **Add** `onPopPage` to `BeamLocation`


# 0.10.5

- **Remove** `NavigationNotifier.currentLocation` (not needed)

# 0.10.4

- **Add** `BeamGuard.beamToNamed`

# 0.10.3

- **Fix** Unexpected null value exception; [issue 144](https://github.com/slovnicki/beamer/issues/144)

# 0.10.2

- **Fix** non-existent state if not set explicitly
- (slight) **Change** to a signature of `BeamLocation.createState`, but hopefully no one has used it yet to be affected :)

# 0.10.1

- **Fix** creation of a custom `BeamState`
- **Add** tests and doc comments for `BeamState`

# 0.10.0

- **BREAKING** Removed most attributes from `BeamLocation` and put them into `BeamLocation.state`
- **BREAKING** Changed `BeamLocation` constructor to take only `state`.
- **Add** `RootRouterDelegate` for nested navigation
- **Add** `BeamState` for more declarative experience

See [migration details](https://pub.dev/packages/beamer#from-09-to-010)


# 0.9.3

- **Add** `replaceCurrent` attribute (default `false`) to beaming function
- **Fix** old information at Guards section in README

# 0.9.2

- **Fix** removing last path segment from possibly unmodifiable List

# 0.9.1

- **Fix** removing the last empty path segment when it's the only one

# 0.9.0+1

- **Fix** formatting

# 0.9.0

- **Add** removing duplicates in `beamHistory` + `BeamerRouterDelegate.removeDuplicateHistory`
- **Add** implicit updates of current location + `BeamerRouterDelegate.preferUpdate`
- **Add** more Beamer extensions to `BuildContext`
- **Remove** the need for `back_button_interceptor` package (not that it's not good, but we realized it can be implemented more naturally)

# 0.8.2

- **Add** optional `notFoundRedirect` to `BeamerRouterDelegate`
- **Fix** parsing URIs in the form `/path/` the same as `/path`

# 0.8.1+1

- **Fix** README ToC links and typos

# 0.8.1

- **Remove** dart:io

# 0.8.0

- **BREAKING:** `BeamLocation.pages` is now `BeamLocation.pagesBuilder`
- **BREAKING:** `BeamerRouterDelegate` now takes `beamLocations` and `BeamerRouteInformationParser` nothing
- **NEW FEATURE:** `beamToNamed`
- **NEW FEATURE:** `canBeamBack` and `beamBackLocation` helpers
- **NEW FEATURE:** `BeamGuard.onCheckFailed`
- **NEW FEATURE:** `stacked` parameter for beaming
- **Add:** [back_button_interceptor](https://pub.dev/packages/back_button_interceptor) package automatic `beamBack` on Android back button
- **Add** more details to README: Key Concepts
- **Add** invite to Discord community for beamer help/discussion/chat

# 0.7.0

- **BREAKING:** `BeamerRouterDelegate.notFoundPage` is now `BeamPage` instead of `Widget`
- **BREAKING:** `BeamGuard.showPage` is now `BeamPage` instead of `Widget`
- **NEW FEATURE:** `beamBack` now goes back through `beamHistory`
- **NEW FEATURE:** `beamTo` can take an optional `beamBackOnPop` boolean
- **NEW FEATURE:** `BeamLocation.builder` can be used to provide something to the entire location
- **NEW EXAMPLE:** location_builder
- **NEW EXAMPLE:** animated_rail
- tweaks and improvements to the documentation

# 0.6.4+1

- **Add** logo image

# 0.6.4

- **Fix** static analysis (Pana 0.14.10, Flutter 1.22.6, Dart 2.10.5) problem by not using `maybeOf`

# 0.6.3

- **Add** `name` attribute to `BeamPage`
- **Fix** `BeamerRouterDelegate` not notifying listeners on `setNewRoutePath`

# 0.6.2

- **Add** `navigatorObservers` attribute to `BeamerRouterDelegate`

# 0.6.1

- **Add** `guardNonMatching` attribute to `BeamGuard`

# 0.6.0+1

- **Fix** some mistakes in README

# 0.6.0

- **NEW FEATURE:** Guards
- **NEW FEATURE:** Beamer as a Widget (see Bottom Navigation example)
- **Add** `examples/` for every gif in README
- **Add** state to `Beamer`

# 0.5.0

- **BREAKING:** `*App.router` constructor needs to be used
- **BREAKING:** `String pathBlueprint` is now `List<String> pathBlueprints`
- **BREAKING:** `BeamLocation.withParameters` constructor is removed and all parameters are handled with 1 constructor. See example if you need `super`.
- **BREAKING:** `BeamPage`'s `page` renamed to `child`
- **NEW FEATURE:** `BeamLocation` can support multiple and arbitrary long path blueprints
- **NEW FEATURE:** `notFoundPage`
- **Add** more complex books example
- **Add** more doc comments
- **Remove** the need for `routerDelegate` to take locations

# 0.4.1+1

- **Add** some more badges

# 0.4.1

- **Update** example not to access state (books) from `BeamLocation`

# 0.4.0

- **BREAKING:** `BeamLocation.pages` must be `List<BeamPage>` instead of `List<Page>`
- **Add** `keepPathParametersOnPop` to `BeamPage`
- **Fix** `_currentPages` to `BeamLocation` parsing when page stack is beyond URI path parameter
- **Update** README
- **Cleanup**

# 0.3.0

- **Add** `Beamer.of(context)` for convenience
- **Add** recreation of "official" books example
- **Update** README
- **Cleanup**

# 0.2.0

- **BREAKING:** Beamer must be placed in a `Widget` tree
- **BREAKING:** beaming is now only possible with extension methods on `BuildContext`
- **BREAKING:** `BeamPage.identifier` replaced with `BeamPage.key`
- **Remove** `BeamLocation.popLocation`
- **Add** "backwards parse" of URI
- **Format** pedantically
- **Update** README with new practices and deep location example

# 0.1.2

- **Add** dartdoc and tests

# 0.1.1

- **Remove** widgets from export barrel

# 0.1.0+1

- **Add** more to pub description

# 0.1.0

- Initial release