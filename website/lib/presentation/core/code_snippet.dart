import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/androidstudio.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:google_fonts/google_fonts.dart';

class CodeSnippet extends StatelessWidget {
  const CodeSnippet({
    Key? key,
    required this.code,
    this.hasCopy = false,
  }) : super(key: key);

  final String code;
  final bool hasCopy;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          HighlightView(
            code,
            language: 'dart',
            theme: androidstudioTheme,
            padding: const EdgeInsets.all(16.0),
            textStyle: GoogleFonts.robotoMono(),
          ),
          if (hasCopy)
            Positioned(
              top: 8.0,
              right: 8.0,
              child: Tooltip(
                message: 'Copy to clipboard',
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Copied to clipboard',
                            textAlign: TextAlign.center,
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                  },
                  child: const Icon(
                    Icons.copy_all_rounded,
                    color: Colors.white,
                    size: 28.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    final isMultiline = element.textContent.split('\n').length > 1;
    return isMultiline
        ? CodeSnippet(
            code: element.textContent,
          )
        : Text(
            element.textContent,
            style: GoogleFonts.robotoMono().copyWith(
              fontWeight: FontWeight.bold,
            ),
          );
  }
}
