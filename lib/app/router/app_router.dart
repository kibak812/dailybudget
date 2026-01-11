import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';
import 'package:daily_pace/features/daily_budget/presentation/pages/home_page.dart';
import 'package:daily_pace/features/transaction/presentation/pages/transactions_page.dart';
import 'package:daily_pace/features/statistics/presentation/pages/statistics_page.dart';
import 'package:daily_pace/features/statistics/presentation/pages/category_detail_page.dart';
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
                    routes: [
                      // Child route for category detail
                      GoRoute(
                        path: 'category-detail',
                        pageBuilder: (context, state) {
                          final extra = state.extra as Map<String, dynamic>;
                          return MaterialPage(
                            child: CategoryDetailPage(
                              categoryName: extra['categoryName'] as String,
                              categoryColor: extra['categoryColor'] as Color,
                              year: extra['year'] as int,
                              month: extra['month'] as int,
                            ),
                          );
                        },
                      ),
                    ],
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
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            label: context.l10n.nav_home,
          ),
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list_alt),
            label: context.l10n.nav_transactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart_outlined),
            selectedIcon: const Icon(Icons.bar_chart),
            label: context.l10n.nav_statistics,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: context.l10n.nav_settings,
          ),
        ],
      ),
    );
  }
}
