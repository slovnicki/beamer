import 'package:beamer/beamer.dart';
import 'package:flutter/widgets.dart';

/// This works like [PopScope], but with beam-interceptors.
///
/// See [BeamInterceptor] for more information.
///
/// If any of the interceptors return true, the pop will not be invoked.
///
/// This works on Navigator.maybePop as well as all the Beamer.beamTo, Beamer.beamToNamed, Beamer.beamBack... operations.
///
/// ```dart
/// BeamInterceptorPopScope(
///   interceptors: [BeamInterceptor(...), ...],
///   child: Center(
///     child: ElevatedButton(
///       child: const Text('Go back'),
///       onPressed: () => Beamer.of(context).beamToNamed('/'),
///     ),
///   ),
/// );
/// ```
class BeamInterceptorPopScope extends StatefulWidget {
  const BeamInterceptorPopScope({
    required this.child,
    required this.interceptors,
    this.beamerDelegate,
    super.key,
  });

  final Widget child;

  /// The interceptors to check when a maybePop, or beamTo, beamToNamed, beamBack... is triggered.
  final List<BeamInterceptor> interceptors;

  /// The beamerDelegate to apply the interceptors to.
  final BeamerDelegate? beamerDelegate;

  @override
  State<BeamInterceptorPopScope> createState() => _BeamInterceptorPopScopeState();
}

class _BeamInterceptorPopScopeState extends State<BeamInterceptorPopScope> {
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
