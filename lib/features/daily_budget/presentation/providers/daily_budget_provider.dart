import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/features/budget/presentation/providers/budget_provider.dart';
import 'package:daily_pace/features/budget/presentation/providers/current_month_provider.dart';
import 'package:daily_pace/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
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

/// Filter transactions within the period date range
List<TransactionModel> _filterTransactionsForPeriod(
  List<TransactionModel> transactions,
  DateTime periodStart,
  DateTime periodEnd,
) {
  return transactions.where((t) {
    final txDate = DateTime.parse(t.date);
    return !txDate.isBefore(periodStart) && !txDate.isAfter(periodEnd);
  }).toList();
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
  final periodTransactions = _filterTransactionsForPeriod(
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
    final periodTransactions = _filterTransactionsForPeriod(
      transactions,
      periodStart,
      periodEnd,
    );

    // Get effective date for calculations
    final currentDate = _getEffectiveDateForPeriod(periodStart, periodEnd, today);
    final daysInPeriod = periodEnd.difference(periodStart).inDays + 1;
    final currentDayIndex = currentDate.difference(periodStart).inDays + 1;

    // Calculate start index based on chart period
    final startDayIndex = period.getStartDayIndex(currentDayIndex, daysInPeriod);

    // Calculate history using the period-aware service
    return DailyBudgetService.getDailyBudgetHistoryForPeriod(
      budget,
      periodTransactions,
      currentDate,
      periodStart,
      periodEnd,
    ).where((item) {
      // Filter based on the chart period range
      final itemDate = periodStart.add(Duration(days: _findDayIndex(item.day, periodStart, currentDate) - 1));
      final itemDayIndex = itemDate.difference(periodStart).inDays + 1;
      return itemDayIndex >= startDayIndex && itemDayIndex <= currentDayIndex;
    }).toList();
  },
);

/// Helper to find the day index within the period for a given day number
int _findDayIndex(int dayNumber, DateTime periodStart, DateTime currentDate) {
  // Iterate through the period to find the matching day
  var date = periodStart;
  var index = 1;
  while (!date.isAfter(currentDate)) {
    if (date.day == dayNumber) {
      return index;
    }
    date = date.add(const Duration(days: 1));
    index++;
  }
  return index;
}

/// Extension on ChartPeriod for period-based calculations
extension ChartPeriodPeriodExtension on ChartPeriod {
  /// Get start day index for chart period within a custom period
  int getStartDayIndex(int currentDayIndex, int daysInPeriod) {
    switch (this) {
      case ChartPeriod.week:
        return (currentDayIndex - 6).clamp(1, currentDayIndex);
      case ChartPeriod.twoWeeks:
        return (currentDayIndex - 13).clamp(1, currentDayIndex);
      case ChartPeriod.month:
        return 1;
    }
  }
}
