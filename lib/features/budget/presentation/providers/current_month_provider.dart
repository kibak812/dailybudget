import 'package:flutter_riverpod/flutter_riverpod.dart';

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

/// StateProvider for managing current selected month/year
/// Used throughout the app to filter data by month
/// Defaults to the current month
final currentMonthProvider = StateProvider<CurrentMonth>((ref) {
  final now = DateTime.now();
  return CurrentMonth(year: now.year, month: now.month);
});
