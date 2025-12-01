/// Daily budget data calculated from budget and transactions
class DailyBudgetData {
  /// Daily budget as of today
  final int dailyBudgetNow;

  /// Daily budget as of yesterday
  final int dailyBudgetYesterday;

  /// Difference between today and yesterday's daily budget
  final int diff;

  /// Amount spent today
  final int spentToday;

  /// Remaining budget for today (dailyBudgetNow - spentToday)
  final int remainingToday;

  /// Total spent this month
  final int totalSpent;

  /// Total remaining budget for the month
  final int totalRemaining;

  /// Remaining days in month (including today)
  final int remainingDays;

  DailyBudgetData({
    required this.dailyBudgetNow,
    required this.dailyBudgetYesterday,
    required this.diff,
    required this.spentToday,
    required this.remainingToday,
    required this.totalSpent,
    required this.totalRemaining,
    required this.remainingDays,
  });

  @override
  String toString() => 'DailyBudgetData(now: $dailyBudgetNow, diff: $diff, spent: $spentToday)';
}

/// Single item in daily budget history
class DailyBudgetHistoryItem {
  final int day;
  final int dailyBudget;

  DailyBudgetHistoryItem({
    required this.day,
    required this.dailyBudget,
  });

  @override
  String toString() => 'HistoryItem(day: $day, dailyBudget: $dailyBudget)';
}
