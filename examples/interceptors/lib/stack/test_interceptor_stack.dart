import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:interceptors/screens/allow_screen.dart';
import 'package:interceptors/screens/block_screen.dart';

class TestInterceptorStack extends BeamStack<BeamState> {
  @override
  List<Pattern> get pathPatterns => ['/', '/allow', '/block'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final pages = [
      BeamPage(
        key: const ValueKey('intercepter'),
        title: 'Intercepter',
        type: BeamPageType.noTransition,
        child: UnconstrainedBox(
          child: SizedBox(
            width: 250,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.beamToNamed('/allow'),
                      child: const Text('Allow navigating to test'),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.beamToNamed('/block'),
                      child: const Text('Block navigating to test'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      if (state.uri.toString().contains('allow'))
        const BeamPage(
          key: ValueKey('allow'),
          title: 'Allow',
          type: BeamPageType.noTransition,
          child: AllowScreen(),
        ),
      if (state.uri.toString().contains('block'))
        const BeamPage(
          key: ValueKey('block'),
          title: 'Block',
          type: BeamPageType.noTransition,
          child: BlockScreen(),
        ),
    ];

    return pages;
  }
}
