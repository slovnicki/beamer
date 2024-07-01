import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_complex/screens/layout.screen.dart';
import 'package:flutter/widgets.dart';

class LayoutLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/Books', '/Books/*', '/Articles', '/Articles/*'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        const BeamPage(key: ValueKey('layout'), child: LayoutScreen()),
      ];
}
