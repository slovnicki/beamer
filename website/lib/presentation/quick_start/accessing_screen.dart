import 'package:beamer_website/presentation/core/paragraph.dart';
import 'package:flutter/material.dart';

import '../core/code_snippet.dart';

class AccessingScreen extends StatelessWidget {
  const AccessingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              ParagraphTitle('Accessing nearest Beamer'),
              ParagraphText(
                "Accessing route attributes in Widgets (for example, bookId for building BookDetailsScreen) can be done with",
              ),
              CodeSnippet(
                code: '''
@override
Widget build(BuildContext context) {
  final beamState = Beamer.of(context).currentBeamLocation.state as BeamState;
  final bookId = beamState.pathParameters['bookId'];
  ...
}
''',
              ),
              SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}
