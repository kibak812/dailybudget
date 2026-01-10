import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:daily_pace/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    // Initialize SharedPreferences mock for tests
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('App starts and displays navigation', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DailyPaceApp());

    // Verify that the app has been created
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
