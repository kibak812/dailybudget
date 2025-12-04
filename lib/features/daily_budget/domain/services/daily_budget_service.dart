import 'package:daily_pace/features/budget/data/models/budget_model.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/daily_budget/domain/models/daily_budget_data.dart';

/// Service for calculating daily budget data
/// Ported from TypeScript calculations.ts
class DailyBudgetService {
  DailyBudgetService._();

  /// Get number of days in a month
  static int getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  /// Calculate spent amount for a specific date
  static int getSpentForDate(List<TransactionModel> transactions, String date) {
    return transactions
        .where((t) => t.type == TransactionType.expense && t.date == date)
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  /// Calculate total spent until date (inclusive)
  static int getSpentUntilDate(List<TransactionModel> transactions, String date) {
    final targetDate = DateTime.parse(date);
    return transactions
        .where((t) {
          if (t.type != TransactionType.expense) return false;
          final txDate = DateTime.parse(t.date);
          return txDate.isBefore(targetDate) || txDate.isAtSameMomentAs(targetDate);
        })
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  /// Calculate total spent after date (exclusive)
  static int getSpentAfterDate(List<TransactionModel> transactions, String date) {
    final targetDate = DateTime.parse(date);
    return transactions
        .where((t) {
          if (t.type != TransactionType.expense) return false;
          final txDate = DateTime.parse(t.date);
          return txDate.isAfter(targetDate);
        })
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  /// Calculate income amount for a specific date
  static int getIncomeForDate(List<TransactionModel> transactions, String date) {
    return transactions
        .where((t) => t.type == TransactionType.income && t.date == date)
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  /// Calculate total income until date (inclusive)
  static int getIncomeUntilDate(List<TransactionModel> transactions, String date) {
    final targetDate = DateTime.parse(date);
    return transactions
        .where((t) {
          if (t.type != TransactionType.income) return false;
          final txDate = DateTime.parse(t.date);
          return txDate.isBefore(targetDate) || txDate.isAtSameMomentAs(targetDate);
        })
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  /// Calculate net spent until date (expenses - income)
  static int getNetSpentUntilDate(List<TransactionModel> transactions, String date) {
    final totalExpenses = getSpentUntilDate(transactions, date);
    final totalIncome = getIncomeUntilDate(transactions, date);
    return totalExpenses - totalIncome;
  }

  /// Calculate daily budget based on net spending
  /// Formula: floor((remainingBudget) / (remainingDays))
  ///
  /// @param budgetAmount Monthly budget
  /// @param netSpent Net spent so far (expenses - income)
  /// @param daysInMonth Total days in month
  /// @param currentDay Current day (1-31)
  /// @returns Daily budget for today
  static int calculateDailyBudget(
    int budgetAmount,
    int netSpent,
    int daysInMonth,
    int currentDay,
  ) {
    final remainingDays = daysInMonth - currentDay + 1;
    final remainingBudget = budgetAmount - netSpent;

    if (remainingDays <= 0) return 0;

    return (remainingBudget / remainingDays).floor();
  }

  /// Calculate complete daily budget data (main function)
  static DailyBudgetData calculateDailyBudgetData(
    BudgetModel? budget,
    List<TransactionModel> transactions,
    DateTime currentDate,
  ) {
    final year = currentDate.year;
    final month = currentDate.month;
    final day = currentDate.day;

    // Default values when no budget exists
    if (budget == null || budget.year != year || budget.month != month) {
      return DailyBudgetData(
        dailyBudgetNow: 0,
        dailyBudgetYesterday: 0,
        diff: 0,
        spentToday: 0,
        remainingToday: 0,
        totalSpent: 0,
        totalIncome: 0,
        totalRemaining: 0,
        remainingDays: 0,
      );
    }

    final daysInMonth = getDaysInMonth(year, month);
    final todayStr = _formatDate(year, month, day);
    final yesterdayStr = day > 1 ? _formatDate(year, month, day - 1) : null;
    final dayBeforeYesterdayStr = day > 2 ? _formatDate(year, month, day - 2) : null;

    // Total spent and income until today
    final totalSpent = getSpentUntilDate(transactions, todayStr);
    final totalIncome = getIncomeUntilDate(transactions, todayStr);
    final netSpent = getNetSpentUntilDate(transactions, todayStr);
    final netSpentUntilYesterday = yesterdayStr != null
        ? getNetSpentUntilDate(transactions, yesterdayStr)
        : 0;
    final netSpentUntilDayBeforeYesterday = dayBeforeYesterdayStr != null
        ? getNetSpentUntilDate(transactions, dayBeforeYesterdayStr)
        : 0;

    // Spent today
    final spentToday = getSpentForDate(transactions, todayStr);

    // Daily budget as of today (based on spending until yesterday to avoid today's swings)
    final dailyBudgetNow = calculateDailyBudget(
      budget.amount,
      netSpentUntilYesterday,
      daysInMonth,
      day,
    );

    // Daily budget as of yesterday (if day > 1)
    int dailyBudgetYesterday = 0;
    if (yesterdayStr != null) {
      dailyBudgetYesterday = calculateDailyBudget(
        budget.amount,
        netSpentUntilDayBeforeYesterday,
        daysInMonth,
        day - 1,
      );
    }

    // Difference
    final diff = dailyBudgetNow - dailyBudgetYesterday;

    // Remaining budget for today
    final remainingToday = dailyBudgetNow - spentToday;

    // Total remaining budget (based on net spending)
    final totalRemaining = budget.amount - netSpent;

    // Remaining days (including today)
    final remainingDays = daysInMonth - day + 1;

    return DailyBudgetData(
      dailyBudgetNow: dailyBudgetNow,
      dailyBudgetYesterday: dailyBudgetYesterday,
      diff: diff,
      spentToday: spentToday,
      remainingToday: remainingToday,
      totalSpent: totalSpent,
      totalIncome: totalIncome,
      totalRemaining: totalRemaining,
      remainingDays: remainingDays,
    );
  }

  /// Get daily budget history from specified day range
  static List<DailyBudgetHistoryItem> getDailyBudgetHistory(
    BudgetModel? budget,
    List<TransactionModel> transactions,
    DateTime currentDate,
    {int? startDay, int? endDay}
  ) {
    if (budget == null) return [];

    final year = currentDate.year;
    final month = currentDate.month;
    final currentDay = currentDate.day;

    if (budget.year != year || budget.month != month) return [];

    final daysInMonth = getDaysInMonth(year, month);
    final history = <DailyBudgetHistoryItem>[];

    // Use provided start/end days or default to 1 and currentDay
    final start = startDay ?? 1;
    final end = endDay ?? currentDay;

    for (int day = start; day <= end; day++) {
      // Calculate daily budget based on spending until the PREVIOUS day
      // This matches the new logic where today's budget doesn't include today's transactions
      final previousDayStr = day > 1 ? _formatDate(year, month, day - 1) : null;
      final netSpentUntilPreviousDay = previousDayStr != null
          ? getNetSpentUntilDate(transactions, previousDayStr)
          : 0;

      final dailyBudget = calculateDailyBudget(
        budget.amount,
        netSpentUntilPreviousDay,
        daysInMonth,
        day,
      );

      history.add(DailyBudgetHistoryItem(day: day, dailyBudget: dailyBudget));
    }

    return history;
  }

  /// Format date as "YYYY-MM-DD"
  static String _formatDate(int year, int month, int day) {
    return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
  }
}
