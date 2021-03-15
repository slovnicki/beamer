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
