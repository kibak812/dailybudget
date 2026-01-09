import 'package:daily_pace/features/budget/presentation/providers/current_month_provider.dart';

/// Extension on CurrentMonth to calculate budget period date ranges
/// based on a custom start day (e.g., payday).
extension DateRangeForBudget on CurrentMonth {
  /// Returns the date range for a budget period based on the start day.
  ///
  /// If startDay is 1, returns the standard calendar month range.
  /// Otherwise, returns from previous month's startDay to this month's (startDay-1).
  ///
  /// Example with startDay = 25:
  /// - "January 2024" period = Dec 25, 2023 ~ Jan 24, 2024
  /// - "February 2024" period = Jan 25, 2024 ~ Feb 24, 2024
  (DateTime start, DateTime end) getDateRange(int startDay) {
    if (startDay == 1) {
      // Standard calendar month (existing behavior)
      return (
        DateTime(year, month, 1),
        DateTime(year, month + 1, 0), // Last day of current month
      );
    }

    // Calculate previous month
    final prevMonth = month == 1 ? 12 : month - 1;
    final prevYear = month == 1 ? year - 1 : year;

    // Get effective start day (handle months with fewer days)
    final startDayInPrevMonth = _effectiveDay(prevYear, prevMonth, startDay);
    final endDay = _effectiveDay(year, month, startDay) - 1;

    // Handle edge case where endDay becomes 0 (startDay was 1)
    final DateTime endDate;
    if (endDay < 1) {
      // This shouldn't happen since we handle startDay == 1 above,
      // but just in case
      endDate = DateTime(year, month, 1).subtract(const Duration(days: 1));
    } else {
      endDate = DateTime(year, month, endDay);
    }

    return (
      DateTime(prevYear, prevMonth, startDayInPrevMonth),
      endDate,
    );
  }

  /// Returns the total number of days in the budget period.
  int getDaysInPeriod(int startDay) {
    final (start, end) = getDateRange(startDay);
    return end.difference(start).inDays + 1;
  }

  /// Returns the effective day for a given month.
  /// If the day exceeds the month's days, returns the last day of the month.
  int _effectiveDay(int y, int m, int day) {
    final daysInMonth = DateTime(y, m + 1, 0).day;
    return day > daysInMonth ? daysInMonth : day;
  }
}
