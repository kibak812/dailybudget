import 'package:daily_pace/features/transaction/domain/models/day_status.dart';

/// Data for a single day in the monthly mosaic
class DayData {
  /// Date in YYYY-MM-DD format
  final String date;

  /// Day number (1-31)
  final int day;

  /// Whether this is today
  final bool isToday;

  /// Whether this is a future day
  final bool isFuture;

  /// Net spent for this day (expenses - income)
  /// Negative value means net income
  final int netSpent;

  /// Daily budget calculated for this day
  /// Null if no budget exists
  final int? dailyBudget;

  /// Status of this day
  final DayStatus status;

  DayData({
    required this.date,
    required this.day,
    required this.isToday,
    required this.isFuture,
    required this.netSpent,
    this.dailyBudget,
    required this.status,
  });
}

/// Summary data for the monthly mosaic
class MonthlyMosaicSummary {
  /// Number of perfect days
  final int perfect;

  /// Number of safe days
  final int safe;

  /// Number of warning days
  final int warning;

  /// Number of danger days
  final int danger;

  /// Total days in month
  final int totalDays;

  /// Whether budget exists for this month
  final bool hasBudget;

  MonthlyMosaicSummary({
    required this.perfect,
    required this.safe,
    required this.warning,
    required this.danger,
    required this.totalDays,
    required this.hasBudget,
  });

  /// Number of overspent days (warning + danger)
  int get overspent => warning + danger;
}

/// Complete monthly mosaic data
class MonthlyMosaicData {
  /// List of day data for the month
  final List<DayData> days;

  /// Summary statistics
  final MonthlyMosaicSummary summary;

  /// Whether this month has any transaction data
  final bool monthHasData;

  MonthlyMosaicData({
    required this.days,
    required this.summary,
    required this.monthHasData,
  });
}
