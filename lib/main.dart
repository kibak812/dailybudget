import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/app/theme/app_theme.dart';
import 'package:daily_pace/app/router/app_router.dart';
import 'package:daily_pace/core/providers/date_provider.dart';

void main() {
  runApp(
    const ProviderScope(
      child: DailyPaceApp(),
    ),
  );
}

/// DailyBudget - Smart Budget Tracker with SMS Auto-parsing
/// Uses WidgetsBindingObserver to detect app lifecycle changes
/// and automatically refresh data when date changes
class DailyPaceApp extends ConsumerStatefulWidget {
  const DailyPaceApp({super.key});

  @override
  ConsumerState<DailyPaceApp> createState() => _DailyPaceAppState();
}

class _DailyPaceAppState extends ConsumerState<DailyPaceApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // When app resumes from background, check if date has changed
    if (state == AppLifecycleState.resumed) {
      ref.read(currentDateProvider.notifier).checkDateChange();
    }
  }

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
