import 'package:beamer_website/presentation/core/code_snippet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class MarkdownScreen extends StatelessWidget {
  const MarkdownScreen({Key? key, required this.mdAsset}) : super(key: key);

  final String mdAsset;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: rootBundle.loadString(mdAsset),
      builder: (_, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (snapshot.hasData) {
          return Markdown(
            data: snapshot.data as String,
            selectable: true,
            builders: {'code': CodeElementBuilder()},
            onTapLink: (_, href, ___) {
              if (href != null) launch(href);
            },
          );
        }
        return const Center(child: Text('Loading...'));
      },
    );
  }
}
