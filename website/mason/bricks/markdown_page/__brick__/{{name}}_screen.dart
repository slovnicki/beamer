import 'package:flutter/widgets.dart';
import 'package:beamer/beamer.dart';
import 'package:beamer_website/presentation/core/markdown_screen.dart';

class {{#pascalCase}}{{name}}{{/pascalCase}}Screen extends MarkdownScreen {
  const {{#pascalCase}}{{name}}{{/pascalCase}}Screen({Key? key})
      : super(key: key, mdAsset: 'assets/markdown/{{name}}.md');

   static BeamPage page = const BeamPage(
    key: ValueKey('{{name}}'),
    title: '{{#titleCase}}{{name}}{{/titleCase}} - beamer.dev',
    child: {{#pascalCase}}{{name}}{{/pascalCase}}Screen(),
  );
}
