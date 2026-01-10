import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/features/settings/presentation/providers/budget_start_day_provider.dart';

/// Model for current month selection
class CurrentMonth {
  final int year;
  final int month;

  CurrentMonth({required this.year, required this.month});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CurrentMonth &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month;

  @override
  int get hashCode => year.hashCode ^ month.hashCode;

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}';
}

/// Calculate the label month for a given date based on start day
/// If date.day < startDay: current calendar month
/// If date.day >= startDay: next calendar month
CurrentMonth getLabelMonthForDate(DateTime date, int startDay) {
  if (startDay == 1 || date.day < startDay) {
    return CurrentMonth(year: date.year, month: date.month);
  } else {
    // date.day >= startDay → next month's label
    final nextMonth = date.month == 12 ? 1 : date.month + 1;
    final nextYear = date.month == 12 ? date.year + 1 : date.year;
    return CurrentMonth(year: nextYear, month: nextMonth);
  }
}

/// Provider that calculates the label month for today based on budget start day
/// This is a computed provider that updates when startDay changes
final todayLabelMonthProvider = Provider<CurrentMonth>((ref) {
  final startDay = ref.watch(budgetStartDayProvider);
  final now = DateTime.now();
  return getLabelMonthForDate(now, startDay);
});

/// StateProvider for managing current selected month/year
/// Used throughout the app to filter data by month
/// Defaults to today's label month based on start day
final currentMonthProvider = StateProvider<CurrentMonth>((ref) {
  // Watch todayLabelMonthProvider for initial value
  // Note: This only affects initial state, not subsequent changes
  final todayLabelMonth = ref.watch(todayLabelMonthProvider);
  return todayLabelMonth;
});
