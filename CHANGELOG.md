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
