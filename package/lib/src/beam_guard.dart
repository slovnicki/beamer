import 'package:beamer/src/utils.dart';
import 'package:flutter/widgets.dart';

import 'package:beamer/src/beamer_delegate.dart';
import 'package:beamer/src/beam_location.dart';
import 'package:beamer/src/beam_page.dart';

/// Checks whether current [BeamLocation] is allowed to be beamed to
/// and provides steps to be executed following a failed check.
///
/// [BeamGuard] has an authority to change [BeamerDelegate.beamingHistory].
/// Applying the guard can have various consequences, depending on
/// the configuration of optional properties:
///
/// See more at [apply].
class BeamGuard {
  /// Creates a [BeamGuard] with defined properties.
  ///
  /// [pathPatterns] and [check] must not be null.
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

  /// What check should be performed on a given [BeamLocation],
  /// the one to which beaming has been requested.
  ///
  /// `context` is also injected to fetch data up the tree if necessary.
  final bool Function(BuildContext context, BeamLocation location) check;

  /// Arbitrary closure to execute when [check] fails.
  ///
  /// This will run before and regardless of [beamTo], [beamToNamed].
  final void Function(BuildContext context, BeamLocation location)?
      onCheckFailed;

  /// If guard [check] returns `false`, build a [BeamLocation] to be beamed to.
  ///
  /// `origin` holds the origin [BeamLocation] from where it is being beamed from, `null` if there's no origin,
  /// which may happen if it's the first navigation or the history was cleared.
  /// `target` holds the [BeamLocation] to where we tried to beam to, i.e. the one on which the check failed.
  /// `deepLink` holds the potential deep-link that was set manually via
  /// [BeamerDelegate.setDeepLink] or came from the platforms.
  final BeamLocation Function(
    BuildContext context,
    BeamLocation? origin,
    BeamLocation target,
    String? deepLink,
  )? beamTo;

  /// If guard [check] returns `false`, beam to this URI string.
  ///
  /// `origin` holds the origin [BeamLocation] from where it is being beamed from. `null` if there's no origin,
  /// which may happen if it's the first navigation or the history was cleared.
  /// `target` holds the [BeamLocation] to where we tried to beam to, i.e. the one on which the check failed.
  /// `deepLink` holds the potential deep-link that was set manually via
  /// [BeamerDelegate.setDeepLink] or came from the platforms.
  final String Function(
    BeamLocation? origin,
    BeamLocation target,
    String? deepLink,
  )? beamToNamed;

  /// If guard [check] returns `false`, beam to a [BeamLocation] with just that page.
  ///
  /// This has precendence over [beamTo] and [beamToNamed].
  final BeamPage? showPage;

  /// Whether to [check] all the path blueprints defined in [pathPatterns]
  /// or [check] all the paths that **are not** in [pathPatterns].
  ///
  /// `false` meaning former and `true` meaning latter.
  final bool guardNonMatching;

  /// Whether or not to replace the current [BeamLocation]'s stack of pages.
  final bool replaceCurrentStack;

  /// Whether or not the guard should [check] the [location].
  bool shouldGuard(BeamLocation location) {
    return guardNonMatching ? !_hasMatch(location) : _hasMatch(location);
  }

  /// Applies the guard.
  /// TODO add detailed comments
  bool apply(
    BuildContext context,
    BeamerDelegate delegate,
    BeamLocation origin,
    List<BeamPage> currentPages,
    BeamLocation target,
    String? deepLink,
  ) {
    final checkPassed = check(context, target);
    if (checkPassed) {
      return false;
    }

    onCheckFailed?.call(context, target);

    if (showPage != null) {
      final redirectBeamLocation =
          GuardShowPage(target.state.routeInformation, showPage!);
      if (replaceCurrentStack) {
        delegate.beamToReplacement(redirectBeamLocation);
      } else {
        delegate.beamTo(redirectBeamLocation);
      }
      return true;
    }

    // just block navigation
    // revert the configuration of delegate
    if (beamTo == null && beamToNamed == null) {
      delegate.configuration = origin.state.routeInformation;
      return true;
    }

    if (beamTo != null) {
      final redirectBeamLocation = beamTo!(context, origin, target, deepLink);
      if (redirectBeamLocation.state.routeInformation.location ==
          target.state.routeInformation.location) {
        // just block if this will produce an immediate infinite loop
        return true;
      }
      if (redirectBeamLocation.state.routeInformation.location ==
          origin.state.routeInformation.location) {
        // just block if redirect is the current route
        return true;
      }
      if (replaceCurrentStack) {
        delegate.beamToReplacement(redirectBeamLocation);
      } else {
        delegate.beamTo(redirectBeamLocation);
      }
      if (redirectBeamLocation.state.routeInformation.location == deepLink) {
        delegate.setDeepLink(null);
      }
      return true;
    }

    if (beamToNamed != null) {
      final redirectNamed = beamToNamed!(origin, target, deepLink);
      if (redirectNamed == target.state.routeInformation.location) {
        // just block if this will produce an immediate infinite loop
        return true;
      }
      if (redirectNamed == origin.state.routeInformation.location) {
        // just block if redirect is the current route
        return true;
      }
      if (replaceCurrentStack) {
        delegate.beamToReplacementNamed(redirectNamed);
      } else {
        delegate.beamToNamed(redirectNamed);
      }
      if (redirectNamed == deepLink) {
        delegate.setDeepLink(null);
      }
      return true;
    }

    return false;
  }

  /// Matches [location]'s pathBlueprint to [pathPatterns].
  ///
  /// If asterisk is present, it is enough that the pre-asterisk substring is
  /// contained within location's pathPatterns.
  /// Else, the path (i.e. the pre-query substring) of the location's uri
  /// must be equal to the pathPattern.
  bool _hasMatch(BeamLocation location) {
    for (final pathPattern in pathPatterns) {
      final path =
          Uri.parse(location.state.routeInformation.location ?? '/').path;
      if (pathPattern is String) {
        final asteriskIndex = pathPattern.indexOf('*');
        if (asteriskIndex != -1) {
          if (location.state.routeInformation.location
              .toString()
              .contains(pathPattern.substring(0, asteriskIndex))) {
            return true;
          }
        } else {
          if (pathPattern == path) {
            return true;
          }
        }
      } else {
        final regexp = Utils.tryCastToRegExp(pathPattern);
        return regexp.hasMatch(path);
      }
    }
    return false;
  }
}
