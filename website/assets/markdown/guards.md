# Guards

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
