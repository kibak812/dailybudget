import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_pace/app/theme/app_colors.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/core/services/daily_summary_service.dart';
import 'package:daily_pace/features/daily_budget/domain/services/daily_budget_service.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/features/transaction/domain/models/day_status.dart';

/// Key for storing last dismissed date in SharedPreferences
const String _kLastDismissedDate = 'yesterday_summary_last_dismissed';

/// Provider to check if summary card should be visible
/// Returns true only if:
/// 1. Current time is after notification time
/// 2. User hasn't dismissed today's card for current notification time
final shouldShowYesterdaySummaryProvider = FutureProvider<bool>((ref) async {
  final today = ref.watch(currentDateProvider);
  final notificationSettings = ref.watch(notificationSettingsProvider);

  // Check if current time is after notification time
  final now = DateTime.now();
  final notificationTime = notificationSettings.summaryTime;
  final notificationDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    notificationTime.hour,
    notificationTime.minute,
  );

  if (now.isBefore(notificationDateTime)) {
    return false;
  }

  // Check if already dismissed for this date + notification time combination
  final prefs = await SharedPreferences.getInstance();
  final lastDismissed = prefs.getString(_kLastDismissedDate);
  final todayStr = Formatters.formatDateISO(today);
  final timeStr = '${notificationTime.hour.toString().padLeft(2, '0')}:${notificationTime.minute.toString().padLeft(2, '0')}';
  final dismissKey = '${todayStr}_$timeStr';

  if (lastDismissed == dismissKey) {
    return false;
  }

  return true;
});

/// Provider for yesterday's summary data
final yesterdaySummaryProvider = Provider<YesterdaySummary?>((ref) {
  final currentMonth = ref.watch(currentMonthProvider);
  final today = ref.watch(currentDateProvider);
  final budgets = ref.watch(budgetProvider);
  final transactions = ref.watch(transactionProvider);

  // Only show if today is not the 1st of the month
  if (today.day == 1) return null;

  // Check if we're viewing current month
  final isCurrentMonth =
      today.year == currentMonth.year && today.month == currentMonth.month;
  if (!isCurrentMonth) return null;

  // Get budget for current month
  final budget = budgets
      .where(
          (b) => b.year == currentMonth.year && b.month == currentMonth.month)
      .firstOrNull;
  if (budget == null || budget.amount <= 0) return null;

  // Calculate yesterday's data
  final yesterday = today.subtract(const Duration(days: 1));
  final yesterdayStr = Formatters.formatDateISO(yesterday);

  // Filter transactions for current month
  final monthPrefix = Formatters.formatYearMonth(currentMonth.year, currentMonth.month);
  final monthTransactions =
      transactions.where((t) => t.date.startsWith(monthPrefix)).toList();

  // Get yesterday's spending
  final yesterdayExpenses =
      DailyBudgetService.getSpentForDate(monthTransactions, yesterdayStr);
  final yesterdayIncome =
      DailyBudgetService.getIncomeForDate(monthTransactions, yesterdayStr);
  final yesterdayNetSpent = yesterdayExpenses - yesterdayIncome;

  // Calculate yesterday's budget (based on day before yesterday)
  final daysInMonth =
      DailyBudgetService.getDaysInMonth(currentMonth.year, currentMonth.month);
  final dayBeforeYesterdayStr = yesterday.day > 1
      ? Formatters.formatDateISO(yesterday.subtract(const Duration(days: 1)))
      : null;
  final netSpentUntilDayBeforeYesterday = dayBeforeYesterdayStr != null
      ? DailyBudgetService.getNetSpentUntilDate(
          monthTransactions, dayBeforeYesterdayStr)
      : 0;

  final yesterdayBudget = DailyBudgetService.calculateDailyBudget(
    budget.amount,
    netSpentUntilDayBeforeYesterday,
    daysInMonth,
    yesterday.day,
  );

  // Determine status using centralized calculation
  final status = DailySummaryService.calculateStatus(yesterdayBudget, yesterdayNetSpent);

  return YesterdaySummary(
    budget: yesterdayBudget,
    spent: yesterdayNetSpent,
    status: status,
    date: yesterday,
  );
});

/// Yesterday summary data model
class YesterdaySummary {
  final int budget;
  final int spent;
  final DayStatus status;
  final DateTime date;

  const YesterdaySummary({
    required this.budget,
    required this.spent,
    required this.status,
    required this.date,
  });

  /// 절약률: 예산 대비 얼마나 절약했는지 (적게 쓸수록 높음)
  /// 100% = 전혀 안 씀, 0% = 예산만큼 씀, 초과 시에도 0%
  int get savingsPercentage {
    if (budget <= 0) return 0;
    final savings = 1 - (spent / budget);
    return (savings.clamp(0.0, 1.0) * 100).round();
  }

  /// Delegates to DayStatus.message
  String get encouragementMessage => status.message;

  /// Delegates to DayStatus.cardColor
  Color get statusColor => status.cardColor;

  /// Delegates to DayStatus.icon
  IconData get statusIcon => status.icon;
}

/// Yesterday summary card widget
class YesterdaySummaryCard extends ConsumerStatefulWidget {
  const YesterdaySummaryCard({super.key});

  @override
  ConsumerState<YesterdaySummaryCard> createState() =>
      _YesterdaySummaryCardState();
}

class _YesterdaySummaryCardState extends ConsumerState<YesterdaySummaryCard> {
  bool _isDismissed = false;

  Future<void> _dismissCard() async {
    final today = ref.read(currentDateProvider);
    final notificationSettings = ref.read(notificationSettingsProvider);
    final notificationTime = notificationSettings.summaryTime;

    // Save dismissed key (date + notification time) to SharedPreferences
    final todayStr = Formatters.formatDateISO(today);
    final timeStr = '${notificationTime.hour.toString().padLeft(2, '0')}:${notificationTime.minute.toString().padLeft(2, '0')}';
    final dismissKey = '${todayStr}_$timeStr';

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastDismissedDate, dismissKey);

    setState(() => _isDismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();

    final summary = ref.watch(yesterdaySummaryProvider);
    if (summary == null) return const SizedBox.shrink();

    // Check if should show based on time and dismiss status
    final shouldShowAsync = ref.watch(shouldShowYesterdaySummaryProvider);

    return shouldShowAsync.when(
      data: (shouldShow) {
        if (!shouldShow) return const SizedBox.shrink();
        return _buildCard(context, summary);
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildCard(BuildContext context, YesterdaySummary summary) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            summary.statusColor.withValues(alpha: 0.1),
            summary.statusColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: summary.statusColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with dismiss button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(
              children: [
                Icon(
                  summary.statusIcon,
                  color: summary.statusColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${summary.date.month}월 ${summary.date.day}일 결산',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: summary.statusColor,
                        ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    size: 18,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: _dismissCard,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 32,
                  ),
                ),
              ],
            ),
          ),

          // Encouragement message
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Text(
              summary.encouragementMessage,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),

          // Budget and spending info
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    '예산',
                    Formatters.formatCurrency(summary.budget),
                    AppColors.textSecondary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.border,
                ),
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    '지출',
                    Formatters.formatCurrency(summary.spent),
                    summary.spent > summary.budget
                        ? AppColors.danger
                        : AppColors.textPrimary,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.border,
                ),
                Expanded(
                  child: _buildInfoColumn(
                    context,
                    '절약률',
                    '${summary.savingsPercentage}%',
                    summary.statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor,
              ),
        ),
      ],
    );
  }
}
