import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for current date management
/// Automatically updates when date changes (midnight) or app resumes
final currentDateProvider =
    StateNotifierProvider<CurrentDateNotifier, DateTime>((ref) {
  return CurrentDateNotifier();
});

/// Notifier that manages current date state
/// Handles midnight transitions and app lifecycle date checks
class CurrentDateNotifier extends StateNotifier<DateTime> {
  Timer? _midnightTimer;

  CurrentDateNotifier() : super(_today()) {
    _scheduleMidnightUpdate();
  }

  /// Get today's date (normalized to midnight)
  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Check if date has changed and update if needed
  /// Called when app resumes from background
  void checkDateChange() {
    final today = _today();
    if (today.day != state.day ||
        today.month != state.month ||
        today.year != state.year) {
      state = today;
      _scheduleMidnightUpdate();
    }
  }

  /// Schedule timer to update at next midnight
  void _scheduleMidnightUpdate() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final durationUntilMidnight = tomorrow.difference(now);

    // Add 1 second buffer to ensure we're past midnight
    final scheduleDuration = durationUntilMidnight + const Duration(seconds: 1);

    _midnightTimer = Timer(scheduleDuration, () {
      state = _today();
      _scheduleMidnightUpdate();
    });
  }

  /// Force refresh the date (for manual refresh scenarios)
  void refresh() {
    state = _today();
    _scheduleMidnightUpdate();
  }

  @override
  void dispose() {
    _midnightTimer?.cancel();
    super.dispose();
  }
}
