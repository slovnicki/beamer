import 'package:beamer/beamer.dart';
import 'package:beamer_website/presentation/introduction/introduction_screen.dart';
import 'package:beamer_website/presentation/core/wip_screen.dart';
import 'package:beamer_website/presentation/quick_start/accessing_screen.dart';
import 'package:beamer_website/presentation/quick_start/beaming_screen.dart';
import 'package:beamer_website/presentation/quick_start/routes_screen.dart';
import 'package:flutter/foundation.dart';

final rootBeamerDelegate = BeamerDelegate(
  initialPath: '/',
  transitionDelegate: const NoAnimationTransitionDelegate(),
  locationBuilder: RoutesLocationBuilder(
    routes: {
      RegExp(r'^(?!(/start.*|/concepts.*|/examples.*)$).*$'): (_, state, ___) =>
          BeamPage(
            key: ValueKey(state.uri),
            title: 'Introduction',
            child: const IntroductionScreen(),
          ),
      '/start/routes': (_, __, ___) => const RoutesScreen(),
      '/start/beaming': (_, __, ___) => const BeamingScreen(),
      '/start/accessing': (_, __, ___) => const AccessingScreen(),
      '/concepts': (_, __, ___) => WIPScreen(),
      '/concepts/*': (_, __, ___) => WIPScreen(),
      '/examples': (_, __, ___) => WIPScreen(),
    },
  ),
);
