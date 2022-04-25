import 'package:beamer/beamer.dart';
import 'package:beamer_website/presentation/core/markdown_screen.dart';
import 'package:flutter/widgets.dart';

class NestedNavigationScreen extends MarkdownScreen {
  const NestedNavigationScreen({Key? key})
      : super(key: key, mdAsset: 'assets/markdown/nested_navigation.md');

  static BeamPage page = const BeamPage(
    key: ValueKey('/concepts/nested_navigation'),
    title: 'Nested Navigation - beamer.dev',
    child: NestedNavigationScreen(),
  );
}
