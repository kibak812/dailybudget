import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider for budget start day setting (1-31)
/// Defaults to 1 (standard calendar month)
final budgetStartDayProvider =
    StateNotifierProvider<BudgetStartDayNotifier, int>((ref) {
  return BudgetStartDayNotifier();
});

/// Notifier for managing budget start day state
class BudgetStartDayNotifier extends StateNotifier<int> {
  /// SharedPreferences key for storing budget start day
  static const String _key = 'budget_start_day';

  BudgetStartDayNotifier() : super(1) {
    _load();
  }

  /// Load start day from SharedPreferences
  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedStartDay = prefs.getInt(_key);
      if (savedStartDay != null && savedStartDay >= 1 && savedStartDay <= 31) {
        state = savedStartDay;
      }
    } catch (e) {
      debugPrint('Error loading budget start day: $e');
    }
  }

  /// Set the budget start day (1-31)
  /// Returns true if successful, false if invalid day
  Future<bool> setStartDay(int day) async {
    if (day < 1 || day > 31) {
      return false;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_key, day);
      state = day;
      return true;
    } catch (e) {
      debugPrint('Error saving budget start day: $e');
      return false;
    }
  }

  /// Reset to default (1st of month)
  Future<void> reset() async {
    await setStartDay(1);
  }
}
