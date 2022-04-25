import 'package:flutter/widgets.dart';
import 'package:beamer/beamer.dart';
import 'package:beamer_website/presentation/core/markdown_screen.dart';

class GuardsScreen extends MarkdownScreen {
  const GuardsScreen({Key? key})
      : super(key: key, mdAsset: 'assets/markdown/guards.md');

  static BeamPage page = const BeamPage(
    key: ValueKey('guards'),
    title: 'Guards - beamer.dev',
    child: GuardsScreen(),
  );
}
