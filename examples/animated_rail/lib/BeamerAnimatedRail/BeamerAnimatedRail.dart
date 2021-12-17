import 'dart:ui';

import 'package:beamer/beamer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animated_rail/animated_rail.dart';

import 'BeamerRailItem.dart';

class BeamerAnimatedRail extends StatefulWidget {
  /// the width of the rail when it is opened default to 100
  final double width;

  /// the max width the rai will snap to, active when [exapnd] is equal true
  final double maxWidth;

  /// direction of rail if it is on the right or left
  final TextDirection direction;

  /// the tabs of the rail as a list of object type [RailItem]
  final List<BeamerRailItem> items;

  /// default icon background color if the [RailItem] doesn't have one
  final Color iconBackground;

  /// default active color for text and icon if the [RailItem] doesn't have one
  final Color activeColor;

  /// default inactive icon and text color if the [RailItem] doesn't have one
  final Color iconColor;

  /// current selected Index dont use it unlessa you want to change the tabs programmatically
  final int selectedIndex;

  /// background of the rail
  final Color background;

  /// if true the the rail can exapnd and reach [maxWidth] and the animation for text will take effect default true
  final bool expand;

  /// if true the rail will not move vertically default to false
  final bool isStatic;
  const BeamerAnimatedRail(
      {Key key,
      this.width = 100,
      this.maxWidth = 350,
      this.direction = TextDirection.ltr,
      this.items = const [],
      this.iconBackground = Colors.white,
      this.activeColor,
      this.iconColor,
      this.selectedIndex,
      this.background,
      this.expand = true,
      this.isStatic = false})
      : assert(items.length > 0, 'need at least one item in the list'),
        super(key: key);

  @override
  _BeamerAnimatedRailState createState() => _BeamerAnimatedRailState();
}

class _BeamerAnimatedRailState extends State<BeamerAnimatedRail> {
  // int selectedIndex = 0;
  ValueNotifier<int> selectedIndexNotifier = ValueNotifier(0);
  final _beamerKey = GlobalKey<BeamerState>();
  Beamer _beamer;
  List<BeamLocation> _beamLocations;

  List<int> locationsStack = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() {
    _beamLocations = widget.items.map((e) => e.location).toList();
    locationsStack = [];
    locationsStack.add(selectedIndexNotifier.value);
    _beamer = Beamer(
      key: _beamerKey,
      beamLocations: _beamLocations,
    );
  }

  @override
  void didUpdateWidget(covariant BeamerAnimatedRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedIndex != null) {
      selectedIndexNotifier.value =
          (widget.selectedIndex ?? 0) > (widget.items.length - 1)
              ? 0
              : widget.selectedIndex;
    }
    if (widget.items != oldWidget.items) {
      init();
    }
  }

  void _changeIndex(int index, {bool addToStack = true}) {
    _beamerKey.currentState.routerDelegate.beamTo(_beamLocations[index]);
    print('selectedIndexNotifier ${selectedIndexNotifier.value}');
    selectedIndexNotifier.value = index;
    if (addToStack) {
      locationsStack.add(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        var canPop = await _beamerKey.currentState.routerDelegate.popRoute();
        var popStack = locationsStack.length > 1 || canPop;

        if (!canPop && locationsStack.length > 1) {
          locationsStack.removeAt(locationsStack.length - 1);
          _changeIndex(locationsStack[locationsStack.length - 1],
              addToStack: false);
        }
        return Future.value(!popStack);
      },
      child: Material(
        type: MaterialType.card,
        child: Container(
          child: LayoutBuilder(
            builder: (cx, constraints) {
              return Stack(
                alignment: widget.direction == TextDirection.ltr
                    ? Alignment.centerLeft
                    : Alignment.centerRight,
                children: [
                  _beamer,
                  ValueListenableBuilder<int>(
                    valueListenable: selectedIndexNotifier,
                    builder: (cx, index, _) => AnimatedRailRaw(
                      constraints: constraints,
                      items: widget.items,
                      width: widget.width,
                      activeColor: widget.activeColor,
                      iconColor: widget.iconColor,
                      background: widget.background,
                      direction: widget.direction,
                      maxWidth: widget.maxWidth,
                      selectedIndex: index,
                      iconBackground: widget.iconBackground,
                      onTap: _changeIndex,
                      expand: widget.expand,
                      isStatic: widget.isStatic,
                    ),
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
