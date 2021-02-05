import 'package:flutter/widgets.dart';

import './beam_location.dart';

/// A guard for [BeamLocation]s.
///
/// Responsible for checking whether current location is allowed to be drawn
/// on screen and providing steps to be executed following a failed check.
class BeamGuard {
  BeamGuard({
    @required this.pathBlueprints,
    @required this.check,
    this.beamTo,
    this.forbidden,
  }) : assert(beamTo != null || forbidden != null);

  /// A list of path strings that are to be guarded.
  ///
  /// Asterisk wildcard is supported to denote "anything".
  ///
  /// For example, '/books/*' will match '/books/1', '/books/2/genres', etc.
  /// but will not match '/books'. To match '/books' and everything after it,
  /// use '/books*'.
  ///
  /// See [hasMatch] for more details.
  List<String> pathBlueprints;

  /// What check should guard perform on a given [location], the one that is
  /// being tried beaming to.
  ///
  /// [context] is also injected to fetch data up the tree if necessary.
  bool Function(BuildContext context, BeamLocation location) check;

  /// If guard [check] returns false, build a location to be beamed to.
  ///
  /// This has precedence over [forbidden].
  BeamLocation Function(BuildContext context) beamTo;

  /// If guard [check] returns false, draw this widget onto screen.
  ///
  /// When using this property over [beamTo], the location that was stopped
  /// by this guard will stay ready to be rebuilt if [forbidden] screen changes
  /// the conditions necessary to pass guard and rebuilds the tree.
  Widget forbidden;

  /// Matches [location]'s pathBlueprint to [pathBlueprints].
  ///
  /// If asterisk is present, it is enough that the pre-asterisk substring is
  /// contained within location's pathBlueprint.
  /// Else, they must be equal.
  bool hasMatch(BeamLocation location) {
    for (var pathBlueprint in pathBlueprints) {
      final asteriskIndex = pathBlueprint.indexOf('*');
      if (asteriskIndex != -1) {
        if (location.pathBlueprint
            .contains(pathBlueprint.substring(0, asteriskIndex))) {
          return true;
        }
      } else {
        if (pathBlueprint == location.pathBlueprint) {
          return true;
        }
      }
    }
    return false;
  }
}
