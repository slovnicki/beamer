import 'package:authentication_riverpod/views/home_page.dart';
import 'package:authentication_riverpod/views/login_page.dart';
import 'package:beamer/beamer.dart';
import 'package:flutter/src/widgets/framework.dart';

class BeamerLocations extends BeamLocation {
  BeamerLocations(BeamState state) : super(state);

  @override
  List<String> get pathBlueprints => [
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
