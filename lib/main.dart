import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/app/theme/app_theme.dart';
import 'package:daily_pace/app/router/app_router.dart';

void main() {
  runApp(
    const ProviderScope(
      child: DailyPaceApp(),
    ),
  );
}

/// DailyBudget - Smart Budget Tracker with SMS Auto-parsing
class DailyPaceApp extends StatelessWidget {
  const DailyPaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DailyBudget',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
