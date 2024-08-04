import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class IntercepterStackToBlock extends BeamStack<BeamState> {
  @override
  List<Pattern> get pathPatterns => ['/block-this-route'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final pages = [
      BeamPage(
        key: const ValueKey('block-this-route'),
        title: 'block-this-route',
        type: BeamPageType.noTransition,
        child: UnconstrainedBox(
          child: SizedBox(
            width: 500,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Super secret page', style: Theme.of(context).textTheme.titleLarge),
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: SizedBox(
                    height: 50,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (context.canBeamBack) {
                          context.beamBack();
                        } else if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          context.beamToNamed('/');
                        }
                      },
                      child: const Text('Go back'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ];

    return pages;
  }
}
