import 'package:beamer/src/utils.dart';
import 'package:flutter/widgets.dart';

import './beam_location.dart';
import './beam_page.dart';

/// Checks whether current [BeamLocation] is allowed to be beamed to
/// and provides steps to be executed following a failed check.
///
/// If neither [beamTo], [beamToNamed] nor [showPage] is specified,
/// the guard will just block navigation, i.e. nothing will happen.
class BeamGuard {
  BeamGuard({
    required this.pathBlueprints,
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
  List<dynamic> pathBlueprints;

  /// What check should be performed on a given [location],
  /// the one to which beaming has been requested.
  ///
  /// [context] is also injected to fetch data up the tree if necessary.
  bool Function(BuildContext context, BeamLocation location) check;

  /// Arbitrary closure to execute when [check] fails.
  ///
  /// This will run before and regardless of [beamTo], [beamToNamed], [showPage].
  void Function(BuildContext context, BeamLocation location)? onCheckFailed;

  /// If guard [check] returns `false`, build a [BeamLocation] to be beamed to.
  ///
  /// [showPage] has precedence over this attribute.
  BeamLocation Function(BuildContext context)? beamTo;

  /// If guard [check] returns `false`, beam to this URI string.
  ///
  /// [showPage] has precedence over this attribute.
  String? beamToNamed;

  /// If guard [check] returns `false`, put this page onto navigation stack.
  ///
  /// This has precedence over [beamTo] and [beamToNamed].
  BeamPage? showPage;

  /// Whether to [check] all the path blueprints defined in [pathBlueprints]
  /// or [check] all the paths that **are not** in [pathBlueprints].
  ///
  /// `false` meaning former and `true` meaning latter.
  bool guardNonMatching;

  /// Whether or not to replace the current [BeamLocation]'s stack of pages.
  final bool replaceCurrentStack;

  /// Matches [location]'s pathBlueprint to [pathBlueprints].
  ///
  /// If asterisk is present, it is enough that the pre-asterisk substring is
  /// contained within location's pathBlueprint.
  /// If the uri has a query, it is enough that the pre-query substring is
  /// equal to the pathBlueprint.
  /// Else, they must be equal.
  bool _hasMatch(BeamLocation location) {
    for (var pathBlueprint in pathBlueprints) {
      if (pathBlueprint is String) {
        final asteriskIndex = pathBlueprint.indexOf('*');
        if (asteriskIndex != -1) {
          if (location.state.uri
              .toString()
              .contains(pathBlueprint.substring(0, asteriskIndex))) {
            return true;
          }
        } else {
          if (pathBlueprint == location.state.uri.path) {
            return true;
          }
        }
      } else {
        final regexp = Utils.tryCastToRegExp(pathBlueprint);
        return regexp.hasMatch(location.state.uri.toString());
      }
    }
    return false;
  }

  /// Whether or not the guard should [check] the [location].
  bool shouldGuard(BeamLocation location) {
    return guardNonMatching ? !_hasMatch(location) : _hasMatch(location);
  }
}
