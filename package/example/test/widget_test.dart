// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:example/main.dart';

void main() {
  testWidgets('Basics', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    expect(find.text('See books'), findsOneWidget);

    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text(books[0].title), findsOneWidget);
    expect(find.text(books[1].title), findsOneWidget);
    expect(find.text(books[2].title), findsOneWidget);

    await tester.tap(find.text(books[1].title));
    await tester.pumpAndSettle();

    expect(find.text(books[0].title), findsNothing);
    expect(find.text(books[1].title), findsOneWidget);
    expect(find.text(books[2].title), findsNothing);
  });
}
