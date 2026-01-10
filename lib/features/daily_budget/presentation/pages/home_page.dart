import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/core/widgets/banner_ad_widget.dart';
import 'package:daily_pace/core/utils/date_range_extension.dart';
import 'package:daily_pace/features/daily_budget/domain/models/daily_budget_data.dart';
import 'package:daily_pace/features/daily_budget/presentation/widgets/today_summary_card.dart';
import 'package:daily_pace/features/daily_budget/presentation/widgets/today_spent_card.dart';
import 'package:daily_pace/features/daily_budget/presentation/widgets/daily_budget_trend_chart.dart';
import 'package:daily_pace/features/daily_budget/presentation/widgets/budget_info_card.dart';
import 'package:daily_pace/features/daily_budget/presentation/widgets/yesterday_summary_card.dart';
import 'package:daily_pace/features/settings/presentation/providers/budget_start_day_provider.dart';
import 'package:daily_pace/app/router/app_router.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/add_transaction_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:daily_pace/app/theme/app_colors.dart';

/// Home page - Daily Budget Overview
/// Displays today's budget, remaining amount, and quick actions
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dailyBudget = ref.watch(dailyBudgetProvider);
    final currentMonth = ref.watch(currentMonthProvider);
    final startDay = ref.watch(budgetStartDayProvider);
    final (periodStart, periodEnd) = currentMonth.getDateRange(startDay);

    return Scaffold(
      appBar: AppBar(
        title: startDay == 1
            ? Text('${currentMonth.year}년 ${currentMonth.month}월')
            : Text(
                '${periodStart.year}.${periodStart.month}.${periodStart.day} ~ ${periodEnd.month}.${periodEnd.day}',
              ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            // Navigate to previous month
            final newMonth = currentMonth.month == 1 ? 12 : currentMonth.month - 1;
            final newYear = currentMonth.month == 1 ? currentMonth.year - 1 : currentMonth.year;
            ref.read(currentMonthProvider.notifier).state = CurrentMonth(
              year: newYear,
              month: newMonth,
            );
          },
          tooltip: '이전 달',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              // Navigate to next month
              final newMonth = currentMonth.month == 12 ? 1 : currentMonth.month + 1;
              final newYear = currentMonth.month == 12 ? currentMonth.year + 1 : currentMonth.year;
              ref.read(currentMonthProvider.notifier).state = CurrentMonth(
                year: newYear,
                month: newMonth,
              );
            },
            tooltip: '다음 달',
          ),
        ],
      ),
      body: _buildContent(context, ref, dailyBudget),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (context) => const AddTransactionSheet(),
          );
        },
        tooltip: '거래 추가',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, DailyBudgetData dailyBudget) {
    // Check if budget is set
    final hasBudget = dailyBudget.dailyBudgetNow > 0 || dailyBudget.totalSpent > 0;

    if (!hasBudget) {
      return _buildEmptyState(context);
    }

    return Column(
      children: [
        // Scrollable content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Yesterday's Summary Card (dismissible)
                const YesterdaySummaryCard(),
                const SizedBox(height: 16),

                // Today's Summary Card
                TodaySummaryCard(budgetData: dailyBudget),
                const SizedBox(height: 16),

                // Today's Spent and Remaining
                TodaySpentCard(budgetData: dailyBudget),
                const SizedBox(height: 16),

                // Daily Budget Trend Chart
                const DailyBudgetTrendChartSyncfusion(),
                const SizedBox(height: 16),

                // Budget Info
                BudgetInfoCard(budgetData: dailyBudget),
                const SizedBox(height: 80), // Extra space for FAB
              ],
            ),
          ),
        ),
        // Fixed Banner Ad at bottom
        const SafeArea(
          top: false,
          child: BannerAdWidget(),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 24),
            Text(
              '예산을 설정해주세요',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              '예산을 설정하면\n일별 사용 가능 금액을 확인할 수 있습니다',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.go(AppRouter.settingsPath);
              },
              icon: const Icon(Icons.add),
              label: const Text('예산 설정하기'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
