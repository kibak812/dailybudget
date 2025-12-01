import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:daily_pace/features/daily_budget/presentation/pages/home_page.dart';
import 'package:daily_pace/features/transaction/presentation/pages/transactions_page.dart';
import 'package:daily_pace/features/statistics/presentation/pages/statistics_page.dart';
import 'package:daily_pace/features/settings/presentation/pages/settings_page.dart';

/// GoRouter configuration for Daily Pace app
/// Uses StatefulShellRoute for bottom navigation with 4 main tabs
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');

  /// Route paths
  static const String homePath = '/home';
  static const String transactionsPath = '/transactions';
  static const String statisticsPath = '/statistics';
  static const String settingsPath = '/settings';

  /// Create the GoRouter instance
  static GoRouter get router => GoRouter(
        navigatorKey: _rootNavigatorKey,
        initialLocation: homePath,
        debugLogDiagnostics: true,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) {
              return ScaffoldWithNavBar(navigationShell: navigationShell);
            },
            branches: [
              // Home Branch
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: homePath,
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: HomePage(),
                    ),
                  ),
                ],
              ),
              // Transactions Branch
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: transactionsPath,
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: TransactionsPage(),
                    ),
                  ),
                ],
              ),
              // Statistics Branch
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: statisticsPath,
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: StatisticsPage(),
                    ),
                  ),
                ],
              ),
              // Settings Branch
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: settingsPath,
                    pageBuilder: (context, state) => const NoTransitionPage(
                      child: SettingsPage(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      );
}

/// Scaffold with bottom navigation bar
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: '홈',
          ),
          NavigationDestination(
            icon: Icon(Icons.list_alt_outlined),
            selectedIcon: Icon(Icons.list_alt),
            label: '거래내역',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: '통계',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '설정',
          ),
        ],
      ),
    );
  }
}
