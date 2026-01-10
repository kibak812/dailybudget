import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/features/budget/presentation/providers/budget_provider.dart';
import 'package:daily_pace/features/budget/presentation/providers/current_month_provider.dart';
import 'package:daily_pace/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:daily_pace/features/daily_budget/domain/services/daily_budget_service.dart';
import 'package:daily_pace/features/daily_budget/domain/models/daily_budget_data.dart';
import 'package:daily_pace/features/settings/presentation/providers/budget_start_day_provider.dart';
import 'package:daily_pace/core/providers/date_provider.dart';
import 'package:daily_pace/core/utils/date_range_extension.dart';

/// Get effective date for budget calculations based on selected month and period
/// - Current period: returns today's date (clamped to period bounds)
/// - Past period: returns last day of that period
/// - Future period: returns first day of that period
DateTime _getEffectiveDateForPeriod(
  DateTime periodStart,
  DateTime periodEnd,
  DateTime today,
) {
  if (today.isBefore(periodStart)) {
    // Future period: use first day
    return periodStart;
  } else if (today.isAfter(periodEnd)) {
    // Past period: use last day
    return periodEnd;
  } else {
    // Current period: use today
    return today;
  }
}


/// Provider for calculating daily budget data
/// This is a computed provider that depends on:
/// - budgetProvider: for the monthly budget
/// - transactionProvider: for all transactions
/// - currentMonthProvider: for the selected month/year
/// - budgetStartDayProvider: for the custom start day
/// - currentDateProvider: for auto-refresh when date changes
///
/// Returns DailyBudgetData with all calculated values
final dailyBudgetProvider = Provider<DailyBudgetData>((ref) {
  // Watch all dependencies - provider will recalculate when any of these change
  final budgets = ref.watch(budgetProvider);
  final transactions = ref.watch(transactionProvider);
  final currentMonth = ref.watch(currentMonthProvider);
  final startDay = ref.watch(budgetStartDayProvider);
  // Watch currentDateProvider to auto-refresh on date change
  final today = ref.watch(currentDateProvider);

  // Get budget for current month (label month)
  final budget = budgets.where((b) =>
    b.year == currentMonth.year && b.month == currentMonth.month
  ).firstOrNull;

  // Calculate period date range based on start day
  final (periodStart, periodEnd) = currentMonth.getDateRange(startDay);

  // Filter transactions for the period
  final periodTransactions = DailyBudgetService.filterTransactionsForPeriod(
    transactions,
    periodStart,
    periodEnd,
  );

  // Get effective date for calculations
  final currentDate = _getEffectiveDateForPeriod(periodStart, periodEnd, today);

  // Use period-aware calculation
  return DailyBudgetService.calculateDailyBudgetDataForPeriod(
    budget,
    periodTransactions,
    currentDate,
    periodStart,
    periodEnd,
  );
});

/// Provider for daily budget history with period filter
/// Parameter: ChartPeriod to determine the date range
/// Returns a list of DailyBudgetHistoryItem for the selected period
final dailyBudgetHistoryProvider = Provider.family<List<DailyBudgetHistoryItem>, ChartPeriod>(
  (ref, period) {
    final budgets = ref.watch(budgetProvider);
    final transactions = ref.watch(transactionProvider);
    final currentMonth = ref.watch(currentMonthProvider);
    final startDay = ref.watch(budgetStartDayProvider);
    // Watch currentDateProvider to auto-refresh on date change
    final today = ref.watch(currentDateProvider);

    // Get budget for current month (label month)
    final budget = budgets.where((b) =>
      b.year == currentMonth.year && b.month == currentMonth.month
    ).firstOrNull;

    // Calculate period date range based on start day
    final (periodStart, periodEnd) = currentMonth.getDateRange(startDay);

    // Filter transactions for the period
    final periodTransactions = DailyBudgetService.filterTransactionsForPeriod(
      transactions,
      periodStart,
      periodEnd,
    );

    // Get effective date for calculations
    final currentDate = _getEffectiveDateForPeriod(periodStart, periodEnd, today);
    final currentDayIndex = currentDate.difference(periodStart).inDays + 1;

    // Calculate start index based on chart period
    // Use existing getStartDay method on ChartPeriod enum
    final startDayIndex = period.getStartDay(currentDayIndex);

    // Calculate history using the period-aware service
    // History items now have day = dayIndex (1-based period index)
    final history = DailyBudgetService.getDailyBudgetHistoryForPeriod(
      budget,
      periodTransactions,
      currentDate,
      periodStart,
      periodEnd,
    );

    // Filter based on the chart period range (item.day is now dayIndex)
    return history.where((item) => item.day >= startDayIndex).toList();
  },
);
