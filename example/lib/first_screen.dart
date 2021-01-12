import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:example/beamer_location.dart';

class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('First Screen'),
      ),
      body: Center(
        child: RaisedButton(
          onPressed: () => Beamer.of(context).beamTo(SecondLocation()),
          child: Text('go to second location'),
        ),
      ),
    );
  }
}
