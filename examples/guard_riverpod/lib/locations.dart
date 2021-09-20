
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:guard_riverpod/pages.dart';

/// Controls whether we will allow navigations to occur (to `SecondPage`) in our `BeamGuard`.
/// 
/// Starts with `false`.
final navigationToSecondProvider = StateProvider<bool>((ref) => false);

/// Controls navigations to `ThirdPage`, listened in `FirstPage`.
/// 
/// Starts with `false`.
final navigationToThirdProvider = StateProvider<bool>((ref) => false);

const firstRoute = 'first';
const secondRoute = 'second';
const thirdRoute = 'third';

class MyLocation extends BeamLocation<BeamState> {
  @override
  List<Pattern> get pathPatterns => [
    '/$firstRoute',
    '/$firstRoute/$secondRoute',
    '/$firstRoute/$thirdRoute',
  ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      BeamPage(key: ValueKey(firstRoute), child: FirstPage()),
      if (state.uri.pathSegments.contains(secondRoute))
        BeamPage(key: ValueKey(secondRoute), fullScreenDialog: true, child: SecondPage()),
      if (state.uri.pathSegments.contains(thirdRoute))
        BeamPage(key: ValueKey(thirdRoute), fullScreenDialog: true, child: ThirdPage()),
    ];
  }
}