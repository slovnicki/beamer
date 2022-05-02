import 'package:flutter/widgets.dart';
import 'package:beamer/beamer.dart';

class {{name.pascalCase()}}BeamLocation extends BeamLocation<BeamState> {
  @override
  List<Pattern> get pathPatterns => ['/{{name.paramCase()}}'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    final pages = [
      const BeamPage(
        key: ValueKey('home'),
        child: HomeScreen(), // TODO
      ),
      if (state.uri.pathSegments.contains('{{name.paramCase()}}'))
        const BeamPage(
          key: ValueKey('{{name.paramCase()}}'),
          child: {{name.pascalCase()}}Screen(), // TODO
        ),
    ];
    return pages;
  }
}