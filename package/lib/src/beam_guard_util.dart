import 'package:flutter/material.dart';

import '../beamer.dart';
import 'utils.dart';


/// Matches [location]'s pathBlueprint to [pathPatterns].
///
/// If asterisk is present, it is enough that the pre-asterisk substring is
/// contained within location's pathBlueprint.
/// Else, the path (i.e. the pre-query substring) of the location's uri
/// must be equal to the pathBlueprint.
bool patternsMatch(List<Pattern> pathPatterns,RouteInformation routeInformation) {
  for (final pathBlueprint in pathPatterns) {
    final path =
        Uri.parse(routeInformation.location ?? '/').path;
    if (pathBlueprint is String) {
      final asteriskIndex = pathBlueprint.indexOf('*');
      if (asteriskIndex != -1) {
        if (routeInformation.location
            .toString()
            .contains(pathBlueprint.substring(0, asteriskIndex))) {
          return true;
        }
      } else {
        if (pathBlueprint == path) {
          return true;
        }
      }
    } else {
      final regexp = Utils.tryCastToRegExp(pathBlueprint);
      return regexp.hasMatch(path);
    }
  }
  return false;
}
