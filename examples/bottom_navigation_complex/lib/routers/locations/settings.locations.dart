import 'package:beamer/beamer.dart';
import 'package:bottom_navigation_complex/routers/locations/layout.locations.dart';
import 'package:bottom_navigation_complex/screens/settings.screen.dart';
import 'package:flutter/widgets.dart';

class SettingsLocation extends BeamLocation<BeamState> {
  @override
  List<String> get pathPatterns => ['/Settings'];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) => [
        ...LayoutLocation().buildPages(context, state),
        const BeamPage(key: ValueKey('settings'), child: SettingsScreen()),
      ];
}
