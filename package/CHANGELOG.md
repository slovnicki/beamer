# 1.5.2

- **Fixed:** Rebuilding of nested `Beamer`s upon deep-links ([#554](https://github.com/slovnicki/beamer/issues/554), [#555](https://github.com/slovnicki/beamer/issues/555), [#46ebf6b](https://github.com/slovnicki/beamer/commit/46ebf6b6db47f4f6b6fc4ca5e30ed7d30e8f5487))

# 1.5.1

- **Fixed:** Lagging `BeamGuard` check when using `BeamerLocationBuilder` ([#532](https://github.com/slovnicki/beamer/issues/532))

# 1.5.0

- **Added:** `onUpdate` method to `BeamLocation` which is called after `initState` and on every `update`. ([#507](https://github.com/slovnicki/beamer/issues/507), [#88c8537](https://github.com/slovnicki/beamer/commit/88c853711c4df4182b1ce0c460179ca5f6e6872c)). See [this example](https://github.com/slovnicki/beamer/tree/master/examples/books_bloc) that demonstrates its possible usage.
- **Added:** `isEqualTo` extension method to `RouteInformation` (intentionally not overriding the equality operator)
- **Fixed:** Possible wrong URL after global rebuild with multiple child Beamers ([#523](https://github.com/slovnicki/beamer/issues/523))
- **Fixed:** Consistency of calls to `BeamLocation.updateState` ([#484](https://github.com/slovnicki/beamer/issues/484))
- **Fixed:**  Resetting `popConfiguration` after `popToNamed` parameter has been used in a `beamToNamed` call ([#521](https://github.com/slovnicki/beamer/issues/521))

### Documentation

- Added explanation of some specific parameters at [Nested Navigation section](https://github.com/slovnicki/beamer/tree/master/package#nested-navigation) in README ([#514](https://github.com/slovnicki/beamer/issues/514))

### Examples

- Improved [books_blos example](https://github.com/slovnicki/beamer/tree/master/examples/books_bloc) with usage of new `BeamLocation.onUpdate`

### Ecosystem

- Added a [beam_location brick](https://github.com/slovnicki/beamer/tree/master/bricks/beam_location)
- Various improvements on [website](https://github.com/slovnicki/beamer/tree/master/website) ([devj3ns](https://github.com/devj3ns))

# 1.4.1+1

- **Fixed:** formatting of `beamer.dart` file

# 1.4.1

- **Fixed:** Initial guarding browser URL ([#501](https://github.com/slovnicki/beamer/issues/501), [b2a9f0b](https://github.com/slovnicki/beamer/commit/b2a9f0b52b9e462192a4a036415aa38fb803b0fa))
- **Fixed:** Deeper routes matching with asterisk ([cgaisl](https://github.com/cgaisl), [#494](https://github.com/slovnicki/beamer/pull/494), [#502](https://github.com/slovnicki/beamer/pull/502))
- **Fixed:** Nested navigation crash with guards ([svsk417](https://github.com/svsk417), [#490](https://github.com/slovnicki/beamer/pull/490))
- **Fixed:** Breaking out of `popToNamed` loop ([Goddchen](https://github.com/Goddchen), [#500](https://github.com/slovnicki/beamer/pull/500))

### Documentation

- Added [website](https://github.com/slovnicki/beamer/tree/master/website) app; a starting point for extensive, self-explanatory Beamer documentation at [beamer.dev](https://beamer.dev/)
- Fixed typos and added doc comment for accessing root Beamer ([gazialankus](https://github.com/gazialankus))

# 1.4.0+1

### Documentation

- Various README improvements and tweaks

# 1.4.0

- **Added:** Relative beaming, i.e. being able to call `beamToNamed('path')` instead of `beamToNamed('/my/path')` if we're already at `/my`. **Important note:** This will affect **all** beaming that is not using the leading `/`, i.e. it will treat it as relative and append it to current path.
- **Added:** New `BeamPageType`s; `slideRightTransition`, `slideLeftTransition` and `slideTopTransition` ([Shiba-Kar](https://github.com/Shiba-Kar), [#477](https://github.com/slovnicki/beamer/pull/477))
- **Improved:** Interactions between nested and sibling Beamers by having children automatically take priority and more carefully handle locally not found cases
- **Fixed:** Unnecessary update of `ChangeNotifier` custom state ([jmysliv](https://github.com/jmysliv), [#475](https://github.com/slovnicki/beamer/pull/475))
- **Fixed::** Target `BeamLocation` initialization during `beamBack`
- **Fixed:** Insufficiently detailed automatic `BeamPage.key` in some `RoutesLocationBuilder.routes` usage of `*`

### Examples

- Added a new example: [multiple_beamers](https://github.com/slovnicki/beamer/tree/master/examples/multiple_beamers)
- Improved and simplified [bottom_navigation_multiple_beamers](https://github.com/slovnicki/beamer/tree/master/examples/bottom_navigation_multiple_beamers) example
- Fixed updating Beamer in [authentication_riverpod](https://github.com/slovnicki/beamer/tree/master/examples/authentication_riverpod) example

# 1.3.0

- **Added:** `strictPathPatterns` to `BeamLocation` which will do only exact matches of URI and path pattern ([5810c9c](https://github.com/slovnicki/beamer/commit/5810c9ca7d821fd7fb85a6ad1c4a482abe86d728))
- **Added:** `updateListenable` to `BeamerDelegate` which will trigger `update` when it notifies ([f0ccfd7](https://github.com/slovnicki/beamer/commit/f0ccfd7eafb4ab08e1b4767a20410846d8b030fd))
- **Added:** Support for replacing the browser history entry when using `beamToReplacement*` or specifying `replaceRouteInformation: true`
- **Added:** Support for setting `opaque` property on `BeamPage` ([ggirotto](https://github.com/ggirotto), [#446](https://github.com/slovnicki/beamer/pull/446))
- **Added:** `initializeFromParent` property to `BeamerDelegate` to overcome the limitation of `updateFromParent` and give finer control over parent interaction ([340b474](https://github.com/slovnicki/beamer/commit/340b47407995df4a14fd296c35950183bbbc6d70))
- **Fixed:** Browser back/forward buttons behavior, i.e. browser history
- **Fixed:** Initialization of target `BeamLocation` when beaming back ([#463](https://github.com/slovnicki/beamer/issues/463))
- **Updated:** Return values for `beamBack` and `popBeamLocation` context extensions ([marcguilera](https://github.com/marcguilera), [#461](https://github.com/slovnicki/beamer/pull/461), [1045ab3](https://github.com/slovnicki/beamer/commit/1045ab350bcc73d06703496d2d85b33428e650b8))
- **Updated:** The entire guarding flow (thanks [mat100payette](https://github.com/mat100payette) for important feedback and contribution)

### Examples

- Fixed some edge cases in [advanced_books example](https://github.com/slovnicki/beamer/tree/master/examples/advanced_books) ([jpangburn](https://github.com/jpangburn), [#451](https://github.com/slovnicki/beamer/pull/451))
- Updated [authentication_bloc example](https://github.com/slovnicki/beamer/tree/master/examples/authentication_bloc) guard usage ([df194e8](https://github.com/slovnicki/beamer/commit/df194e877d05506e2931531e10b3d11f5b3bad56))

# 1.2.0

- **Fixed:** Using the `initialPath` instead of parent's path on nested `BeamerDelegate` during initialization from parent when the `updateFromParent` is set to `false` ([samdogg7](https://github.com/samdogg7))

### Documentation

- Added a section about Page Keys to README ([Goddchen](https://github.com/Goddchen))
- Added a sentence about browser's back button to README
- Fixed and improved grammar in doc comments ([ggirotto](https://github.com/ggirotto))

### Examples

- Fixed analyzer warnings ([Goddchen](https://github.com/Goddchen))
- Updated [authentication_bloc example](https://github.com/slovnicki/beamer/tree/master/examples/authentication_bloc) to bloc v8 ([Lorenzohidalgo](https://github.com/Lorenzohidalgo))

# 1.1.0

Most of this release is [matuella](https://github.com/matuella)'s directly and indirectly contributions. Many thanks!

- **Add:** a link to [Medium article](https://medium.com/flutter-community/beamer-v1-0-0-is-out-whats-new-and-how-to-migrate-b251b3758e3c) for "Migrating" section in README
- **Add:** lint rules `prefer_single_quotes`, `always_use_package_imports`, `omit_local_variable_types`, `prefer_final_locals` and `comment_references`.
- **Fix:** disposing histories on `beamBack` ([#417](https://github.com/slovnicki/beamer/issues/417))
- **Fix:** updating history when setting `state` manually ([#420](https://github.com/slovnicki/beamer/issues/420))
- **Deprecate:** unused `BeamerDelegate.preferUpdate`
- **Improve:** tests setup (Thanks [cedvdb](https://github.com/cedvdb))

# 1.0.0

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
  - `routes` values now additionally receive `data`
- **BREAKING:** `beamStateHistory` and `beamLocationHistory` have been replaced with `beamingHistory` that is a `List<BeamLocation>` and each `BeamLocation` has `history` that is `List<HistoryElement>` where `HistoryElement` holds `RouteInformation` and `BeamParameters`.
  - `clearBeamStateHistory` and `clearBeamLocationHistory` have been removed.
- **BREAKING:** `BeamerDelegate.listener` has been renamed to `BeamerDelegate.routeListener`.
- **BREAKING:** The property `pageRouteBuilder` in `BeamPage` is replaced with a new property `routeBuilder` which works with any `RouteBuilder` not just `PageRouteBuilder`.
- **BREAKING:** `BeamGuard` `beamTo` receives the origin and target `BeamLocation`s alongside `BuildContext`.
  - `replaceCurrent` was removed in favor of `beamToReplacement`.
- **BREAKING:** `BeamGuard` `beamToNamed` is now a function that receives the origin and target `BeamLocation`s and returns a `String`.
  - `replaceCurrent` was removed in favor of `beamToNamedReplacement`.
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
