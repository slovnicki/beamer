import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:interceptors/app/beam_intercept_example_app.dart';
import 'package:interceptors/stack/interceptor_stack_to_block.dart';
import 'package:interceptors/stack/test_interceptor_stack.dart';

final beamerDelegate = BeamerDelegate(
  transitionDelegate: const NoAnimationTransitionDelegate(),
  beamBackTransitionDelegate: const NoAnimationTransitionDelegate(),
  stackBuilder: BeamerStackBuilder(
    beamStacks: [
      TestInterceptorStack(),
      IntercepterStackToBlock(),
    ],
  ),
);

final BeamInterceptor allowNavigatingInterceptor = BeamInterceptor(
  intercept: (context, delegate, currentPages, origin, target, deepLink) => false,
  enabled: true, // this can be false too
  name: 'allow',
);

final BeamInterceptor blockNavigatingInterceptor = BeamInterceptor(
  intercept: (context, delegate, currentPages, origin, target, deepLink) => target is IntercepterStackToBlock,
  enabled: true,
  name: 'block',
);

void main() {
  Beamer.setPathUrlStrategy();
  runApp(
    BeamerProvider(
      routerDelegate: beamerDelegate,
      child: const BeamInterceptExampleApp(),
    ),
  );
}
