import 'package:beamer/beamer.dart';
import 'package:beamer_website/app.dart';
import 'package:flutter/material.dart';

void main() {
  Beamer.setPathUrlStrategy();
  runApp(const App());
}
