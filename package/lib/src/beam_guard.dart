import 'package:beamer/src/utils.dart';
import 'package:flutter/widgets.dart';

import 'package:beamer/src/beamer_delegate.dart';
import 'package:beamer/src/beam_stack.dart';
import 'package:beamer/src/beam_page.dart';

/// Checks whether current [BeamStack] is allowed to be beamed to
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

  /// What check should be performed on a given [BeamStack],
  /// the one to which beaming has been requested.
  ///
  /// `context` is also injected to fetch data up the tree if necessary.
  final bool Function(BuildContext context, BeamStack stack) check;

  /// Arbitrary closure to execute when [check] fails.
  ///
  /// This will run before and regardless of [beamTo], [beamToNamed].
  final void Function(BuildContext context, BeamStack stack)? onCheckFailed;

  /// If guard [check] returns `false`, build a [BeamStack] to be beamed to.
  ///
  /// `origin` holds the origin [BeamStack] from where it is being beamed from, `null` if there's no origin,
  /// which may happen if it's the first navigation or the history was cleared.
  /// `target` holds the [BeamStack] to where we tried to beam to, i.e. the one on which the check failed.
  /// `deepLink` holds the potential deep-link that was set manually via
  /// [BeamerDelegate.setDeepLink] or came from the platforms.
  final BeamStack Function(
    BuildContext context,
    BeamStack? origin,
    BeamStack target,
    String? deepLink,
  )? beamTo;

  /// If guard [check] returns `false`, beam to this URI string.
  ///
  /// `origin` holds the origin [BeamStack] from where it is being beamed from. `null` if there's no origin,
  /// which may happen if it's the first navigation or the history was cleared.
  /// `target` holds the [BeamStack] to where we tried to beam to, i.e. the one on which the check failed.
  /// `deepLink` holds the potential deep-link that was set manually via
  /// [BeamerDelegate.setDeepLink] or came from the platforms.
  final String Function(
    BuildContext context,
    BeamStack? origin,
    BeamStack target,
    String? deepLink,
  )? beamToNamed;

  /// If guard [check] returns `false`, beam to a [BeamStack] with just that page.
  ///
  /// This has precendence over [beamTo] and [beamToNamed].
  final BeamPage? showPage;

  /// Whether to [check] all the path blueprints defined in [pathPatterns]
  /// or [check] all the paths that **are not** in [pathPatterns].
  ///
  /// `false` meaning former and `true` meaning latter.
  final bool guardNonMatching;

  /// Whether or not to replace the current [BeamStack]'s stack of pages.
  final bool replaceCurrentStack;

  /// Whether or not the guard should [check] the [stack].
  bool shouldGuard(BeamStack stack) {
    return guardNonMatching ? !_hasMatch(stack) : _hasMatch(stack);
  }

  /// Applies the guard.
  /// TODO add detailed comments
  bool apply(
    BuildContext context,
    BeamerDelegate delegate,
    BeamStack origin,
    List<BeamPage> currentPages,
    BeamStack target,
    String? deepLink,
  ) {
    final checkPassed = check(context, target);
    if (checkPassed) {
      return false;
    }

    onCheckFailed?.call(context, target);

    if (showPage != null) {
      final redirectBeamStack =
          GuardShowPage(target.state.routeInformation, showPage!);
      if (replaceCurrentStack) {
        delegate.beamToReplacement(redirectBeamStack);
      } else {
        delegate.beamTo(redirectBeamStack);
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
      final redirectBeamStack = beamTo!(context, origin, target, deepLink);
      if (redirectBeamStack.state.routeInformation.uri ==
          target.state.routeInformation.uri) {
        // just block if this will produce an immediate infinite loop
        return true;
      }
      if (redirectBeamStack.state.routeInformation.uri ==
          origin.state.routeInformation.uri) {
        // just block if redirect is the current route
        return true;
      }
      if (replaceCurrentStack) {
        delegate.beamToReplacement(redirectBeamStack);
      } else {
        delegate.beamTo(redirectBeamStack);
      }
      if (redirectBeamStack.state.routeInformation.uri.toString() == deepLink) {
        delegate.setDeepLink(null);
      }
      return true;
    }

    if (beamToNamed != null) {
      final redirectNamed = beamToNamed!(context, origin, target, deepLink);
      if (redirectNamed == target.state.routeInformation.uri.toString()) {
        // just block if this will produce an immediate infinite loop
        return true;
      }
      if (redirectNamed == origin.state.routeInformation.uri.toString()) {
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

  /// Matches [stack]'s pathBlueprint to [pathPatterns].
  ///
  /// If asterisk is present, it is enough that the pre-asterisk substring is
  /// contained within stack's pathPatterns.
  /// Else, the path (i.e. the pre-query substring) of the stack's uri
  /// must be equal to the pathPattern.
  bool _hasMatch(BeamStack stack) {
    for (final pathPattern in pathPatterns) {
      final path = stack.state.routeInformation.uri.path;
      if (pathPattern is String) {
        final asteriskIndex = pathPattern.indexOf('*');
        if (asteriskIndex != -1) {
          if (stack.state.routeInformation.uri
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
        final result = regexp.hasMatch(path);

        if (result) {
          return true;
        } else {
          continue;
        }
      }
    }
    return false;
  }
}
