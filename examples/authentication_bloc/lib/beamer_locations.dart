import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

import 'presentation/logged_in_page.dart';
import 'presentation/login_page.dart';

class BeamerLocations extends BeamLocation {
  BeamerLocations(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => [
        '/login',
        '/logged_in_page',
      ];

  @override
  List<BeamPage> buildPages(BuildContext context, BeamState state) {
    return [
      if (state.uri.pathSegments.contains('login'))
        BeamPage(
          key: ValueKey('login'),
          title: 'Login',
          child: LoginPage(),
        ),
      if (state.uri.pathSegments.contains('logged_in_page'))
        BeamPage(
          key: ValueKey('show_selection'),
          title: 'Logged In',
          child: LoggedInPage(),
        ),
    ];
  }
}
