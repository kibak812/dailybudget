import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/features/daily_budget/domain/services/daily_budget_service.dart';
import 'package:daily_pace/features/transaction/domain/models/monthly_mosaic_data.dart';
import 'package:daily_pace/features/transaction/domain/models/day_status.dart';
import 'package:daily_pace/core/utils/formatters.dart';

/// Provider for monthly mosaic data
/// Calculates day-by-day status based on spending vs daily budget
final monthlyMosaicProvider = Provider<MonthlyMosaicData>((ref) {
  final currentMonth = ref.watch(currentMonthProvider);
  final budgets = ref.watch(budgetProvider);
  final transactions = ref.watch(transactionProvider);

  // Get budget for current month
  final budget = budgets
      .where(
          (b) => b.year == currentMonth.year && b.month == currentMonth.month)
      .firstOrNull;

  // Filter transactions for current month
  final monthPrefix =
      '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}';
  final monthTransactions =
      transactions.where((t) => t.date.startsWith(monthPrefix)).toList();

  final today = DateTime.now();
  final daysInMonth =
      DailyBudgetService.getDaysInMonth(currentMonth.year, currentMonth.month);

  // Calculate data for each day
  final List<DayData> days = [];
  int perfectCount = 0;
  int safeCount = 0;
  int warningCount = 0;
  int dangerCount = 0;

  for (int day = 1; day <= daysInMonth; day++) {
    final dateStr = Formatters.formatDateISO(
        DateTime(currentMonth.year, currentMonth.month, day));
    final date = DateTime(currentMonth.year, currentMonth.month, day);
    final isToday =
        date.year == today.year && date.month == today.month && date.day == today.day;
    final isFuture = date.isAfter(today);

    // Calculate net spent for this day
    final expenses =
        DailyBudgetService.getSpentForDate(monthTransactions, dateStr);
    final income =
        DailyBudgetService.getIncomeForDate(monthTransactions, dateStr);
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
      final prevDayStr = day > 1
          ? Formatters.formatDateISO(
              DateTime(currentMonth.year, currentMonth.month, day - 1))
          : null;
      final netSpentUntilPrevDay = prevDayStr != null
          ? DailyBudgetService.getNetSpentUntilDate(
              monthTransactions, prevDayStr)
          : 0;
      dailyBudget = DailyBudgetService.calculateDailyBudget(
        budget.amount,
        netSpentUntilPrevDay,
        daysInMonth,
        day,
      );
    } else {
      // Past or current day - calculate daily budget
      final prevDayStr = day > 1
          ? Formatters.formatDateISO(
              DateTime(currentMonth.year, currentMonth.month, day - 1))
          : null;
      final netSpentUntilPrevDay = prevDayStr != null
          ? DailyBudgetService.getNetSpentUntilDate(
              monthTransactions, prevDayStr)
          : 0;

      dailyBudget = DailyBudgetService.calculateDailyBudget(
        budget.amount,
        netSpentUntilPrevDay,
        daysInMonth,
        day,
      );

      // Determine status based on net spent vs daily budget
      if (dailyBudget <= 0) {
        status = DayStatus.noBudget;
      } else if (netSpent <= 0) {
        status = DayStatus.perfect;
        perfectCount++;
      } else if (netSpent <= dailyBudget) {
        status = DayStatus.safe;
        safeCount++;
      } else if (netSpent <= dailyBudget * 1.5) {
        status = DayStatus.warning;
        warningCount++;
      } else {
        status = DayStatus.danger;
        dangerCount++;
      }
    }

    days.add(DayData(
      date: dateStr,
      day: day,
      isToday: isToday,
      isFuture: isFuture,
      netSpent: netSpent,
      dailyBudget: dailyBudget,
      status: status,
    ));
  }

  final summary = MonthlyMosaicSummary(
    perfect: perfectCount,
    safe: safeCount,
    warning: warningCount,
    danger: dangerCount,
    totalDays: daysInMonth,
    hasBudget: budget != null && budget.amount > 0,
  );

  final monthHasData = monthTransactions.isNotEmpty;

  return MonthlyMosaicData(
    days: days,
    summary: summary,
    monthHasData: monthHasData,
  );
});
