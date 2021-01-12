import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:example/home_screen.dart';
import 'package:example/first_screen.dart';
import 'package:example/second_screen.dart';

class HomeLocation extends BeamLocation {
  @override
  List<Page> get pages => [
        BeamPage(
          identifier: this.uri,
          page: HomeScreen(),
        ),
      ];

  @override
  String get pathBlueprint => '/';
}

class FirstLocation extends BeamLocation {
  @override
  List<Page> get pages => [
        BeamPage(
          identifier: this.uri,
          page: FirstScreen(),
        ),
      ];

  @override
  String get pathBlueprint => '/first-screen';
}

class SecondLocation extends BeamLocation {
  @override
  List<Page> get pages => [
        BeamPage(
          identifier: HomeLocation().pathBlueprint,
          page: HomeScreen(),
        ),
        BeamPage(
          identifier: this.uri,
          page: SecondScreen(
            name: this.pathParameters['name'] ?? 'no name',
            text: this.queryParameters['text'] ?? 'no text',
          ),
        ),
      ];

  @override
  String get pathBlueprint => '/second-screen/:name';

  @override
  BeamLocation get popLocation => HomeLocation();
}
