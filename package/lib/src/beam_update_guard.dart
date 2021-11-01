import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:beamer/src/beam_guard_util.dart';
import 'package:flutter/widgets.dart';

/// Checks whether current [RouteInformation] is allowed to be beamed to
/// and provides steps to be executed following a failed check.
class BeamUpdateGuard {
  const BeamUpdateGuard({
    required this.pathPatterns,
    required this.check,
    required this.redirect,
    this.guardNonMatching = false,
  });

  /// A list of path strings or regular expressions (using dart's RegExp class) that are to be guarded.
  ///
  /// For strings:
  /// Asterisk wildcard is supported to denote "anything".
  ///
  /// For example, '/books/*' will match '/books/1', '/books/2/genres', etc.
  /// but will not match '/books'. To match '/books' and everything after it,
  /// use '/books*'.
  ///
  /// See [patternsMatch] for more details.
  ///
  /// For RegExp:
  /// You can use RegExp instances and the delegate will check for a match using [RegExp.hasMatch]
  ///
  /// For example, `RegExp('/books/')` will match '/books/1', '/books/2/genres', etc.
  /// but will not match '/books'. To match '/books' and everything after it,
  /// use `RegExp('/books')`
  final List<Pattern> pathPatterns;

  /// What check should be performed on a given [RouteInformation],
  /// the one to which beaming has been requested.
  ///
  /// [context] is also injected to fetch data up the tree if necessary.
  final bool Function(BeamLocation delegate, RouteInformation routeInformation,
      Object? data) check;

  /// Arbitrary closure to execute when [check] fails.
  final void Function(BeamerDelegate delegate,
      RouteInformation routeInformation, Object? data) redirect;

  /// Whether to [check] all the path blueprints defined in [pathPatterns]
  /// or [check] all the paths that **are not** in [pathPatterns].
  ///
  /// `false` meaning former and `true` meaning latter.
  final bool guardNonMatching;

  /// Matches [location]'s pathBlueprint to [pathPatterns].
  ///
  /// If asterisk is present, it is enough that the pre-asterisk substring is
  /// contained within location's pathBlueprint.
  /// Else, the path (i.e. the pre-query substring) of the location's uri
  /// must be equal to the pathBlueprint.
  bool _hasMatch(RouteInformation routeInformation) =>
      patternsMatch(pathPatterns, routeInformation);

  /// Whether or not the guard should [check] the [location].
  /// [currentLocation] is the current beam location. [routeInformation] and [data] have not yet applied to it.
  /// [routeInformation] is the route info of the new route
  /// [data] is either data that was passed with the new route
  bool shouldGuard(BeamLocation currentLocation,
      RouteInformation routeInformation, Object? data) {
    return guardNonMatching
        ? !_hasMatch(routeInformation)
        : _hasMatch(routeInformation);
  }
}
