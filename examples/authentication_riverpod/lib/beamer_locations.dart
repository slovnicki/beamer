import 'package:authentication_riverpod/views/home_page.dart';
import 'package:authentication_riverpod/views/login_page.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';

class BeamerLocations extends BeamLocation<BeamState> {
  BeamerLocations(RouteInformation routeInformation) : super(routeInformation);

  @override
  List<Pattern> get pathPatterns => [
        '/login',
        '/home',
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
      if (state.uri.pathSegments.contains('home'))
        BeamPage(
          key: ValueKey('home'),
          title: 'Home',
          child: HomePage(),
        ),
    ];
  }
}
