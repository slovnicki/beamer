import 'package:beamer/beamer.dart';
import 'package:beamer_website/presentation/concepts/beam_locations_screen.dart';
import 'package:beamer_website/presentation/concepts/guards_screen.dart';
import 'package:beamer_website/presentation/concepts/nested_navigation_screen.dart';
import 'package:beamer_website/presentation/core/wip_screen.dart';
import 'package:beamer_website/presentation/introduction/introduction_screen.dart';
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
            title: 'Introduction - beamer.dev',
            child: const IntroductionScreen(),
          ),
      '/start/routes': (_, __, ___) => const BeamPage(
            key: ValueKey('/start/routes'),
            title: 'Routes - beamer.dev',
            child: RoutesScreen(),
          ),
      '/start/beaming': (_, __, ___) => const BeamPage(
            key: ValueKey('/start/beaming'),
            title: 'Beaming - beamer.dev',
            child: BeamingScreen(),
          ),
      '/start/accessing': (_, __, ___) => const BeamPage(
            key: ValueKey('/start/accessing'),
            title: 'Accessing - beamer.dev',
            child: AccessingScreen(),
          ),
      '/concepts': (_, __, ___) => const BeamPage(
            key: ValueKey('/concepts'),
            title: 'Concepts - beamer.dev',
            child: WIPScreen(),
          ),
      '/concepts/beam-locations': (_, __, ___) => const BeamPage(
            key: ValueKey('/concepts/beam-locations'),
            title: 'Beam Locations - beamer.dev',
            child: BeamLocationsScreen(),
          ),
      '/concepts/guards': (_, __, ___) => GuardsScreen.page,
      '/concepts/nested-navigation': (_, __, ___) =>
          NestedNavigationScreen.page,
      '/examples': (_, __, ___) => const BeamPage(
            key: ValueKey('/examples'),
            title: 'Examples - beamer.dev',
            child: WIPScreen(),
          ),
    },
  ),
);
