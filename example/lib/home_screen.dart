import 'package:flutter/material.dart';
import 'package:beamer/beamer.dart';

import 'beamer_location.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RaisedButton(
              onPressed: () => Beamer.of(context).beamTo(FirstLocation()),
              child: Text('go to first location'),
            ),
            SizedBox(height: 16.0),
            RaisedButton(
              onPressed: () => Beamer.of(context).beamTo(SecondLocation()),
              child: Text('go to second location'),
            ),
          ],
        ),
      ),
    );
  }
}
