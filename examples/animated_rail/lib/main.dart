import 'dart:math';

import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'BeamerAnimatedRail/BeamerAnimatedRail.dart';
import 'BeamerAnimatedRail/BeamerRailItem.dart';

class TestLocation extends BeamLocation {
  TestLocation({
    String pathBlueprint,
  }) : super(pathBlueprint: pathBlueprint);

  @override
  List<String> get pathBlueprints => ['$pathBlueprint/:page'];

  @override
  List<BeamPage> get pages => [
        BeamPage(
          key: ValueKey('$pathBlueprint'),
          child: FirstPage(
            title: '$pathBlueprint',
            pathBlueprint: '$pathBlueprint/:page',
          ),
        ),
        if (pathParameters.containsKey('page'))
          BeamPage(
            key: ValueKey('$pathBlueprint 2'),
            child: _buildTest('$pathBlueprint 2'),
          ),
      ];
}

// DATA
Widget _buildTest(String title) {
  return Container(
    color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
    child: Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          // height: ,
          child: Text(
            title,
            style: TextStyle(fontSize: 40, color: Colors.white),
          ),
        ),
      ),
    ),
  );
}

class FirstPage extends StatelessWidget {
  final String title;
  final String pathBlueprint;
  FirstPage({this.title, this.pathBlueprint});
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Container(
            // height: ,
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 40, color: Colors.white),
                ),
                Container(
                  color: Colors.blue,
                  padding: EdgeInsets.all(5),
                  child: InkWell(
                    onTap: () {
                      Beamer.of(context)
                        ..updateCurrentLocation(
                          pathBlueprint: pathBlueprint,
                          pathParameters: {'page': '2'},
                        );
                    },
                    child: Text(
                      'Second page',
                      style: TextStyle(fontSize: 25, color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// APP
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Beamer with rail Demo',
        home: Scaffold(
          body: Center(
              child: BeamerAnimatedRail(
            activeColor: Colors.purple,
            background: hexToColor('#8B77DD'),
            maxWidth: 275,
            width: 100,
            // direction: TextDirection.rtl,
            items: [
              BeamerRailItem(
                  icon: Icon(Icons.home),
                  label: "Home",
                  location: TestLocation(pathBlueprint: 'Home')),
              BeamerRailItem(
                  icon: Icon(Icons.message_outlined),
                  label: 'Messages',
                  location: TestLocation(pathBlueprint: 'Messages')),
              BeamerRailItem(
                  icon: Icon(Icons.notifications),
                  label: "Notification",
                  location: TestLocation(pathBlueprint: 'Notification')),
              BeamerRailItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                  location: TestLocation(pathBlueprint: 'Profile')),
            ],
          )),
        ));
  }
}

Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

void main() {
  runApp(MyApp());
}
