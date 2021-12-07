import 'package:animated_rail/animated_rail.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

/// rail item used by the Animated rail as a tab
/// values like [background],[activeColor] and [iconColor]
/// overrides default values in the [AnimatedRailRaw]
class BeamerRailItem extends RailItem {
  /// `required` BeamLocation to use when this [RailItem] is selected
  BeamLocation location;

  BeamerRailItem({
    Widget icon,
    @required this.location,
    String label,
    Color background,
    Color activeColor,
    Color iconColor,
  }) : super(
            icon: icon,
            screen: Container(),
            activeColor: activeColor,
            background: background,
            iconColor: iconColor,
            label: label);
}
