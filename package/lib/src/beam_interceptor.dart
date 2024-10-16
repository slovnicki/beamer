import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

class BeamInterceptor {
  /// Creates a [BeamInterceptor] with defined properties.
  ///
  /// [name] and [intercept] must not be null.
  const BeamInterceptor({
    this.enabled = true,
    required this.name,
    required this.intercept,
  });

  /// A name of the interceptor.
  ///
  /// It is used to compare interceptors.
  final String name;

  /// Whether the interceptor is enabled.
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
