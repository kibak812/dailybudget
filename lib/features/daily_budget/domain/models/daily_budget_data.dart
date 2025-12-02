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

  /// Total income this month
  final int totalIncome;

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
    required this.totalIncome,
    required this.totalRemaining,
    required this.remainingDays,
  });

  @override
  String toString() => 'DailyBudgetData(now: $dailyBudgetNow, diff: $diff, spent: $spentToday, income: $totalIncome)';
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

/// Chart period filter options
enum ChartPeriod {
  week,     // 1주 (7일)
  twoWeeks, // 2주 (14일)
  month;    // 1달 (전체)

  String get label {
    switch (this) {
      case ChartPeriod.week:
        return '1주';
      case ChartPeriod.twoWeeks:
        return '2주';
      case ChartPeriod.month:
        return '1달';
    }
  }

  /// Calculate start day based on current day
  int getStartDay(int currentDay) {
    switch (this) {
      case ChartPeriod.week:
        return (currentDay - 6).clamp(1, currentDay);
      case ChartPeriod.twoWeeks:
        return (currentDay - 13).clamp(1, currentDay);
      case ChartPeriod.month:
        return 1;
    }
  }
}
