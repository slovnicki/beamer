import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Converts [RouteInformation] to [Uri] and vice-versa.
class BeamerRouteInformationParser extends RouteInformationParser<Uri> {
  @override
  SynchronousFuture<Uri> parseRouteInformation(
      RouteInformation routeInformation) {
    return SynchronousFuture(Uri.parse(routeInformation.location ?? '/'));
  }

  @override
  RouteInformation restoreRouteInformation(Uri uri) {
    return RouteInformation(location: uri.toString());
  }
}
