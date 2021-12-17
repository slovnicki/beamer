import 'dart:async';

import 'package:beamer/beamer.dart';
import 'package:beamer/src/beam_guard_util.dart';
import 'package:flutter/widgets.dart';

/// Checks whether a target [BeamLocation] is allowed to be beamed to
/// and provides methods to handle a failed check.
class UpdateGuard {
  const UpdateGuard({
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

  /// When [check] returns `true`, a redirect to [target] will be executed.
  /// When returning `false`, [redirect] is called to determine
  /// a different target
  final bool Function(BeamLocation origin, RouteInformation target,
      Object? data) check;

  /// Arbitrary closure to execute when [check] fails,
  /// can potentialy call [delegate] to redirect to another location
  final void Function(BeamerDelegate delegate,
      RouteInformation target, Object? data) redirect;

  /// Whether to [check] all the path blueprints defined in [pathPatterns]
  /// or [check] all the paths that **are not** in [pathPatterns].
  ///
  /// `false` meaning former and `true` meaning latter.
  final bool guardNonMatching;

  /// Matches [target]'s [location]  to [pathPatterns].
  ///
  /// If asterisk is present, it is enough that the pre-asterisk substring is
  /// contained within location's pathBlueprint.
  /// Else, the path (i.e. the pre-query substring) of the location's uri
  /// must be equal to the pathBlueprint.
  bool _hasMatch(RouteInformation target) =>
      patternsMatch(pathPatterns, target);

  /// Whether or not the guard should [check] the [target].
  /// [origin] is the current beam location. [target] and [data] have not yet applied to it.
  /// [target] is the intended target beam location
  /// [data] is either data that was passed with the new route
  bool shouldGuard(BeamLocation origin,
      RouteInformation target, Object? data) {
    return guardNonMatching
        ? !_hasMatch(target)
        : _hasMatch(target);
  }
}
