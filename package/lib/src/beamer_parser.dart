import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Parses [RouteInformation] into a type that `BeamerDelegate` will understand,
/// which is again [RouteInformation].
class BeamerParser extends RouteInformationParser<RouteInformation> {
  /// Creates a [BeamerParser] with specified properties.
  BeamerParser({this.onParse});

  /// Used to inspect and/or modify the parsed [RouteInformation]
  /// before returning it for `BeamerDelegate` to use.
  final RouteInformation Function(RouteInformation)? onParse;

  @override
  SynchronousFuture<RouteInformation> parseRouteInformation(
          RouteInformation routeInformation) =>
      SynchronousFuture(
        onParse?.call(routeInformation) ?? routeInformation,
      );

  @override
  RouteInformation restoreRouteInformation(RouteInformation configuration) =>
      configuration;
}
