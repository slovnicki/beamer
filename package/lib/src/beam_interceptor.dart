import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

/// IDK LOL
class BeamInterceptor {
  /// Creates a [BeamInterceptor] with defined properties.
  ///
  /// [pathPatterns] and [intercept] must not be null.
  const BeamInterceptor({
    this.enabled = true,
    required this.name,
    required this.intercept,
  });

  final String name;

  final bool enabled;

  /// The interceptor function.
  ///
  /// Returns `true` if the interceptor should be applied and `false` otherwise.
  ///
  /// The interceptor can be disabled by setting [enabled] to `false`.
  ///
  /// The targetBeamStack is the [BeamStack] that is beeing pushed or popped to. (destination)
  final bool Function(
    BuildContext context,
    BeamerDelegate delegate,
    List<BeamPage> currentPages,
    BeamStack origin,
    BeamStack target,
    String? deepLink,
  ) intercept;

  @override
  bool operator ==(other) {
    if (other is! BeamInterceptor) {
      return false;
    }
    return name == other.name;
  }

  @override
  int get hashCode => name.hashCode;
}
