import 'package:authentication_bloc/presentation/logged_in_page.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:authentication_bloc/presentation/login_page.dart';

class BeamerLocations extends BeamLocation {
  BeamerLocations(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => [
        '/login',
        '/logged_in_page',
      ];

  @override
  List<BeamPage> pagesBuilder(BuildContext context, BeamState state) {
    return [
      if (state.uri.pathSegments.contains('login'))
        BeamPage(
          key: ValueKey('login'),
          child: LoginPage(),
        ),
      if (state.uri.pathSegments.contains('logged_in_page'))
        BeamPage(
          key: ValueKey('show_selection'),
          child: LoggedInPage(),
        ),
    ];
  }
}
