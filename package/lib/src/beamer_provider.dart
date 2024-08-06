import 'package:beamer/src/beamer_delegate.dart';
import 'package:flutter/widgets.dart';

/// Provides [BeamerDelegate] to the `*App.router` Widget.
///
/// This is useful when using `builder` in the `*App.router` widget.
/// Then, if using Beamer the regular way, `Beamer.of(context)` will not exist.
/// The way to solve it is by using `BeamerProvider` above `*App.router`:
///
/// ```dart
/// final _routerDelegate = BeamerDelegate(...);
///
/// @override
/// Widget build(BuildContext context) {
///   return BeamerProvider(
///     routerDelegate: _routerDelegate
///     child: MaterialApp.router(
///       routerDelegate: _routerDelegate,
///       routeInformationParser: BeamerParser(...),
///       ...
///     )
///   );
/// }
///
/// ```
class BeamerProvider extends InheritedWidget {
  /// Creates a [BeamerProvider] with specified properties.
  ///
  /// [routerDelegate] is required because it is the object to provide down the tree.
  const BeamerProvider({
    Key? key,
    required this.routerDelegate,
    required Widget child,
  }) : super(key: key, child: child);

  /// Responsible for beaming, updating and rebuilding the page stack.
  final BeamerDelegate routerDelegate;

  /// Obtain the nearest [BeamerProvider].
  ///
  /// See [BuildContext.dependOnInheritedWidgetOfExactType].
  static BeamerProvider? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<BeamerProvider>();

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
