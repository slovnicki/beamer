import 'package:beamer/beamer.dart';
import 'package:beamer/src/beam_state.dart';
import 'package:flutter/widgets.dart';

/// Configuration for a navigatable application region.
///
/// Extend this class to define your locations to which you can then `beamTo`.
abstract class BeamLocation<T extends BeamState> extends ChangeNotifier {
  BeamLocation({
    T state,
  }) : _state = state;

  T _state;

  /// A state of this location.
  ///
  /// Upon beaming, it will be populated by all necessary attributes.
  /// See [BeamState].
  T get state => _state;
  set state(T state) {
    _state = state..configure();
    notifyListeners();
  }

  /// How to create state.
  ///
  /// Override this if you have your custom state class extending [BeamState].
  T createState(
    List<String> pathBlueprintSegments,
    Map<String, String> pathParameters,
    Map<String, String> queryParameters,
    Map<String, dynamic> data,
  ) =>
      BeamState(
        pathBlueprintSegments: pathBlueprintSegments,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        data: data,
      ) as T;

  /// Update a state via callback receiving the current state.
  ///
  /// Useful with [BeamState.copyWith].
  void update(T Function(T) copy) => state = copy(_state);

  /// Gives the ability to wrap the `navigator`.
  ///
  /// Mostly useful for providing something to the entire location,
  /// i.e. to all of the [pages].
  ///
  /// For example:
  ///
  /// ```dart
  /// @override
  /// Widget builder(BuildContext context, Widget navigator) {
  ///   return MyProvider<MyObject>(
  ///     create: (context) => MyObject(),
  ///     child: navigator,
  ///   );
  /// }
  /// ```
  Widget builder(BuildContext context, Widget navigator) => navigator;

  /// Represents the "form" of URI paths supported by this [BeamLocation].
  ///
  /// Optional path segments are denoted with ':xxx' and consequently
  /// `{'xxx': <real>}` will be put to [pathParameters] by
  /// [BeamerRouteInformationParser] upon receiving the real path from browser.
  ///
  /// Optional path segments can be used as a mean to pass data regardless of
  /// whether there is a browser.
  ///
  /// For example: '/books/:id'.
  List<String> get pathBlueprints;

  /// Creates and returns the list of pages to be built by the [Navigator]
  /// when this [BeamLocation] is beamed to or internally inferred.
  ///
  /// `context` can be useful while building the pages.
  /// It will also contain anything injected via [builder].
  List<BeamPage> pagesBuilder(BuildContext context);

  /// Guards that will be executing [check] when this gets beamed to.
  ///
  /// Checks will be executed in order; chain of responsibility pattern.
  /// When some guard returns `false`, location will not be accepted
  /// and stack of pages will be updated as is configured in [BeamGuard].
  ///
  /// Override this in your subclasses, if needed.
  List<BeamGuard> get guards => const <BeamGuard>[];

  /// Will be executed before [pages] are drawn onto screen.
  void Function() executeBefore;

  /// Recreates the [uri] for this [BeamLocation]
  /// considering current value of [pathParameters] and [queryParameters].
  ///
  /// Calls [executeBefore] if defined.
  void prepare() {
    //_makePath();
    //_makeQuery();
    executeBefore?.call();
  }
}

/// Default location to choose if requested URI doesn't parse to any location.
class NotFound extends BeamLocation {
  NotFound({String path})
      : super(
          state: BeamState(
            pathBlueprintSegments: Uri.parse(path).pathSegments,
          ),
        );

  @override
  List<BeamPage> pagesBuilder(BuildContext context) => [];

  @override
  List<String> get pathBlueprints => [''];
}
