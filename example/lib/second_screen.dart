import 'package:flutter/material.dart';

class SecondScreen extends StatelessWidget {
  final String text;

  SecondScreen({this.text});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text(this.text),
      ),
    );
  }
}
