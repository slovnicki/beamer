import 'package:beamer/src/utils.dart';
import 'package:flutter/widgets.dart';

import './beam_location.dart';
import './beam_page.dart';
import 'beam_guard_util.dart';

/// Checks whether current [BeamLocation] is allowed to be beamed to
/// and provides steps to be executed following a failed check.
///
/// If neither [beamTo], [beamToNamed] nor [showPage] is specified,
/// the guard will just block navigation, i.e. nothing will happen.
class BeamGuard {
  const BeamGuard({
    required this.pathPatterns,
    required this.check,
    this.onCheckFailed,
    this.beamTo,
    this.beamToNamed,
    this.showPage,
    this.guardNonMatching = false,
    this.replaceCurrentStack = true,
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
  /// See [_hasMatch] for more details.
  ///
  /// For RegExp:
  /// You can use RegExp instances and the delegate will check for a match using [RegExp.hasMatch]
  ///
  /// For example, `RegExp('/books/')` will match '/books/1', '/books/2/genres', etc.
  /// but will not match '/books'. To match '/books' and everything after it,
  /// use `RegExp('/books')`
  final List<Pattern> pathPatterns;

  /// What check should be performed on a given [location],
  /// the one to which beaming has been requested.
  ///
  /// [context] is also injected to fetch data up the tree if necessary.
  final bool Function(BuildContext context, BeamLocation location) check;

  /// Arbitrary closure to execute when [check] fails.
  ///
  /// This will run before and regardless of [beamTo], [beamToNamed], [showPage].
  final void Function(BuildContext context, BeamLocation location)?
      onCheckFailed;

  /// If guard [check] returns `false`, build a [BeamLocation] to be beamed to.
  /// 
  /// [originLocation] holds the origin location from where it is being beamed from. `null` if there's no origin 
  /// location, which may happen if it's the first navigation or the history was cleared.
  /// [targetLocation] holds the location to where we tried to beam to, i.e. the [BeamLocation] on which the check 
  /// failed.
  /// 
  /// [showPage] has precedence over this attribute.
  final BeamLocation Function(BuildContext context, BeamLocation? originLocation, BeamLocation targetLocation)? beamTo;

  /// If guard [check] returns `false`, beam to this URI string.
  /// 
  /// [originLocation] holds the origin location from where it is being beamed from. `null` if there's no origin 
  /// location, which may happen if it's the first navigation or the history was cleared.
  /// [targetLocation] holds the location to where we tried to beam to, i.e. the [BeamLocation] on which the check 
  /// failed.
  /// 
  /// [showPage] has precedence over this attribute.
  final String Function(BeamLocation? originLocation, BeamLocation targetLocation)? beamToNamed;

  /// If guard [check] returns `false`, put this page onto navigation stack.
  ///
  /// This has precedence over [beamTo] and [beamToNamed].
  final BeamPage? showPage;

  /// Whether to [check] all the path blueprints defined in [pathPatterns]
  /// or [check] all the paths that **are not** in [pathPatterns].
  ///
  /// `false` meaning former and `true` meaning latter.
  final bool guardNonMatching;

  /// Whether or not to replace the current [BeamLocation]'s stack of pages.
  final bool replaceCurrentStack;

  /// Matches [location]'s pathBlueprint to [pathPatterns].
  ///
  /// If asterisk is present, it is enough that the pre-asterisk substring is
  /// contained within location's pathBlueprint.
  /// Else, the path (i.e. the pre-query substring) of the location's uri
  /// must be equal to the pathBlueprint.
  bool _hasMatch(BeamLocation location) => patternsMatch(pathPatterns, location.state.routeInformation);

  /// Whether or not the guard should [check] the [location].
  bool shouldGuard(BeamLocation location) {
    return guardNonMatching ? !_hasMatch(location) : _hasMatch(location);
  }
}
