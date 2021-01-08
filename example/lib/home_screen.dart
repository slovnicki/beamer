import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'beamer_location.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text('first screen'),
          RaisedButton(
            onPressed: () => Beamer.of(context).beamTo(FirstLocation()),
            child: Text('go to first screen'),
          ),
          RaisedButton(
            onPressed: () => Beamer.of(context).beamTo(SecondLocation()),
            child: Text('go to second screen'),
          ),
        ],
      ),
    );
  }
}
