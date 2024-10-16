import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

/// This works like [PopScope], but with beam-interceptors.
///
/// See [BeamInterceptor] for more information.
///
/// If any of the interceptors return true, the pop will not be invoked.
///
/// This works on Navigator.pop as well as all the Beamer's beaming functions.
///
/// ```dart
/// BeamInterceptorScope(
///   interceptors: [BeamInterceptor(...), ...],
///   child: Center(
///     child: ElevatedButton(
///       child: const Text('Go back'),
///       onPressed: () => Beamer.of(context).beamToNamed('/'),
///     ),
///   ),
/// );
/// ```
class BeamInterceptorScope extends StatefulWidget {
  const BeamInterceptorScope({
    required this.child,
    required this.interceptors,
    this.beamerDelegate,
    super.key,
  });

  final Widget child;

  /// The interceptors to check upon any beaming or popping.
  final List<BeamInterceptor> interceptors;

  /// The [BeamerDelegate] to apply the interceptors to.
  final BeamerDelegate? beamerDelegate;

  @override
  State<BeamInterceptorScope> createState() => _BeamInterceptorScopeState();
}

class _BeamInterceptorScopeState extends State<BeamInterceptorScope> {
  late BeamerDelegate beamerDelegate;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      beamerDelegate = widget.beamerDelegate ?? Beamer.of(context);

      for (var interceptor in widget.interceptors) {
        beamerDelegate.addInterceptor(interceptor);
      }
    });
  }

  @override
  void dispose() {
    for (var interceptor in widget.interceptors) {
      beamerDelegate.removeInterceptor(interceptor);
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
