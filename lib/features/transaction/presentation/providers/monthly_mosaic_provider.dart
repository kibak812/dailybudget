import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/core/services/daily_summary_service.dart';
import 'package:daily_pace/core/utils/date_range_extension.dart';
import 'package:daily_pace/features/daily_budget/domain/services/daily_budget_service.dart';
import 'package:daily_pace/features/settings/presentation/providers/budget_start_day_provider.dart';
import 'package:daily_pace/features/transaction/domain/models/monthly_mosaic_data.dart';
import 'package:daily_pace/features/transaction/domain/models/day_status.dart';
import 'package:daily_pace/core/utils/formatters.dart';

/// Provider for monthly mosaic data
/// Calculates day-by-day status based on spending vs daily budget
/// Watches currentDateProvider to auto-refresh when date changes
final monthlyMosaicProvider = Provider<MonthlyMosaicData>((ref) {
  final currentMonth = ref.watch(currentMonthProvider);
  final budgets = ref.watch(budgetProvider);
  final transactions = ref.watch(transactionProvider);
  final startDay = ref.watch(budgetStartDayProvider);
  // Watch currentDateProvider to auto-refresh on date change (midnight/app resume)
  final today = ref.watch(currentDateProvider);

  // Get budget for current month (label month)
  final budget = budgets
      .where(
          (b) => b.year == currentMonth.year && b.month == currentMonth.month)
      .firstOrNull;

  // Calculate period date range based on start day
  final (periodStart, periodEnd) = currentMonth.getDateRange(startDay);
  final daysInPeriod = periodEnd.difference(periodStart).inDays + 1;

  // Filter transactions for the period using shared utility
  final periodTransactions = DailyBudgetService.filterTransactionsForPeriod(
    transactions,
    periodStart,
    periodEnd,
  );

  // Calculate data for each day in the period
  final List<DayData> days = [];
  int perfectCount = 0;
  int safeCount = 0;
  int warningCount = 0;
  int dangerCount = 0;

  var currentDate = periodStart;
  int dayIndex = 1;

  while (!currentDate.isAfter(periodEnd)) {
    final dateStr = Formatters.formatDateISO(currentDate);
    final isToday = currentDate.year == today.year &&
        currentDate.month == today.month &&
        currentDate.day == today.day;
    final isFuture = currentDate.isAfter(today);

    // Calculate net spent for this day
    final expenses =
        DailyBudgetService.getSpentForDate(periodTransactions, dateStr);
    final income =
        DailyBudgetService.getIncomeForDate(periodTransactions, dateStr);
    final netSpent = expenses - income;

    // Calculate daily budget for this day (based on spending until previous day)
    int? dailyBudget;
    DayStatus status;

    if (budget == null || budget.amount <= 0) {
      // No budget or zero budget
      status = DayStatus.noBudget;
      dailyBudget = null;
    } else if (isFuture) {
      // Future day
      status = DayStatus.future;
      // Calculate daily budget for future days too (for display purposes)
      final prevDate = currentDate.subtract(const Duration(days: 1));
      final prevDayStr = prevDate.isBefore(periodStart)
          ? null
          : Formatters.formatDateISO(prevDate);
      final netSpentUntilPrevDay = prevDayStr != null
          ? DailyBudgetService.getNetSpentUntilDate(
              periodTransactions, prevDayStr)
          : 0;
      dailyBudget = DailyBudgetService.calculateDailyBudget(
        budget.amount,
        netSpentUntilPrevDay,
        daysInPeriod,
        dayIndex,
      );
    } else if (!isToday) {
      // Past day only - calculate daily budget and determine status
      final prevDate = currentDate.subtract(const Duration(days: 1));
      final prevDayStr = prevDate.isBefore(periodStart)
          ? null
          : Formatters.formatDateISO(prevDate);
      final netSpentUntilPrevDay = prevDayStr != null
          ? DailyBudgetService.getNetSpentUntilDate(
              periodTransactions, prevDayStr)
          : 0;

      dailyBudget = DailyBudgetService.calculateDailyBudget(
        budget.amount,
        netSpentUntilPrevDay,
        daysInPeriod,
        dayIndex,
      );

      // Determine status using centralized calculation
      status = DailySummaryService.calculateStatus(dailyBudget, netSpent);

      // Update counts for summary
      switch (status) {
        case DayStatus.perfect:
          perfectCount++;
        case DayStatus.safe:
          safeCount++;
        case DayStatus.warning:
          warningCount++;
        case DayStatus.danger:
          dangerCount++;
        default:
          break;
      }
    } else {
      // Today - pending settlement (no color yet, settled at end of day)
      // Calculate daily budget for display purposes
      final prevDate = currentDate.subtract(const Duration(days: 1));
      final prevDayStr = prevDate.isBefore(periodStart)
          ? null
          : Formatters.formatDateISO(prevDate);
      final netSpentUntilPrevDay = prevDayStr != null
          ? DailyBudgetService.getNetSpentUntilDate(
              periodTransactions, prevDayStr)
          : 0;

      dailyBudget = DailyBudgetService.calculateDailyBudget(
        budget.amount,
        netSpentUntilPrevDay,
        daysInPeriod,
        dayIndex,
      );
      // Today gets future status (no color) - will be settled when day ends
      status = DayStatus.future;
    }

    days.add(DayData(
      date: dateStr,
      day: currentDate.day,
      isToday: isToday,
      isFuture: isFuture,
      netSpent: netSpent,
      dailyBudget: dailyBudget,
      status: status,
    ));

    currentDate = currentDate.add(const Duration(days: 1));
    dayIndex++;
  }

  final summary = MonthlyMosaicSummary(
    perfect: perfectCount,
    safe: safeCount,
    warning: warningCount,
    danger: dangerCount,
    totalDays: daysInPeriod,
    hasBudget: budget != null && budget.amount > 0,
  );

  final monthHasData = periodTransactions.isNotEmpty;

  return MonthlyMosaicData(
    days: days,
    summary: summary,
    monthHasData: monthHasData,
  );
});
