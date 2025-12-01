import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_pace/main.dart';

void main() {
  testWidgets('App starts and displays navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DailyPaceApp());

    // Verify that the app has been created
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
