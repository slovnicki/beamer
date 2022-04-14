import 'package:flutter/material.dart';

abstract class Paragraph extends StatelessWidget {
  const Paragraph(this.text, {Key? key}) : super(key: key);

  final String text;
  TextStyle? getTextStyle(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        text,
        style: getTextStyle(context),
      ),
    );
  }
}

class ParagraphTitle extends Paragraph {
  const ParagraphTitle(String text, {Key? key}) : super(text, key: key);

  @override
  TextStyle? getTextStyle(BuildContext context) => Theme.of(context)
      .textTheme
      .headline5!
      .copyWith(fontWeight: FontWeight.bold);
}

class ParagraphText extends Paragraph {
  const ParagraphText(String text, {Key? key}) : super(text, key: key);

  @override
  TextStyle? getTextStyle(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.copyWith(fontSize: 16.0);
}
