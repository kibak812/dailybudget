import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:daily_pace/l10n/generated/app_localizations.dart';
import 'package:daily_pace/app/theme/app_theme.dart';
import 'package:daily_pace/app/router/app_router.dart';
import 'package:daily_pace/core/providers/date_provider.dart';
import 'package:daily_pace/core/services/ad_service.dart';
import 'package:daily_pace/features/daily_budget/presentation/widgets/yesterday_summary_card.dart';
import 'package:daily_pace/features/settings/presentation/providers/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // AdMob SDK 초기화 (비동기 - 앱 시작을 차단하지 않음)
  AdService().initialize();

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
      // Re-check if notification time has passed (for yesterday summary card)
      ref.invalidate(shouldShowYesterdaySummaryProvider);
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
      locale: ref.watch(languageProvider),
      supportedLocales: const [
        Locale('en'),
        Locale('ko'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
