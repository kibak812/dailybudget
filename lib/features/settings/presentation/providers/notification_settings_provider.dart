import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_pace/core/services/notification_service.dart';

/// Result of enabling notifications
enum NotificationEnableResult {
  success,
  successWithInexactScheduling, // Enabled but exact alarm permission denied (will use inexact)
  notificationPermissionDenied,
  exactAlarmPermissionDenied,
}

/// Model for notification settings
class NotificationSettings {
  final bool isDailySummaryEnabled;
  final TimeOfDay summaryTime;

  const NotificationSettings({
    required this.isDailySummaryEnabled,
    required this.summaryTime,
  });

  NotificationSettings copyWith({
    bool? isDailySummaryEnabled,
    TimeOfDay? summaryTime,
  }) {
    return NotificationSettings(
      isDailySummaryEnabled: isDailySummaryEnabled ?? this.isDailySummaryEnabled,
      summaryTime: summaryTime ?? this.summaryTime,
    );
  }

  /// Default settings
  static const NotificationSettings defaults = NotificationSettings(
    isDailySummaryEnabled: true,
    summaryTime: TimeOfDay(hour: 7, minute: 0), // 07:00 AM
  );
}

/// Provider for notification settings
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  (ref) => NotificationSettingsNotifier(),
);

/// Notifier for managing notification settings
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  static const String _keyDailySummaryEnabled = 'notification_daily_summary_enabled';
  static const String _keySummaryTimeHour = 'notification_summary_time_hour';
  static const String _keySummaryTimeMinute = 'notification_summary_time_minute';
  static const String _keyPermissionRequested = 'notification_permission_requested';

  final NotificationService _notificationService = NotificationService();

  NotificationSettingsNotifier() : super(NotificationSettings.defaults) {
    _initialize();
  }

  /// Initialize settings and notification service
  Future<void> _initialize() async {
    await _notificationService.initialize();
    await _loadSettings();
    await _checkFirstLaunchPermission();
    await _scheduleNotification();
  }

  /// Check and request permission on first launch
  Future<void> _checkFirstLaunchPermission() async {
    final prefs = await SharedPreferences.getInstance();
    final hasRequestedPermission = prefs.getBool(_keyPermissionRequested) ?? false;

    if (!hasRequestedPermission) {
      // First launch: request permission
      final granted = await _notificationService.requestPermission();
      await prefs.setBool(_keyPermissionRequested, true);

      if (!granted && state.isDailySummaryEnabled) {
        // Permission denied: turn off notifications
        await _setDailySummaryEnabledInternal(false);
      }
    }
  }

  /// Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final isDailySummaryEnabled = prefs.getBool(_keyDailySummaryEnabled) ?? true;
    final hour = prefs.getInt(_keySummaryTimeHour) ?? 7;
    final minute = prefs.getInt(_keySummaryTimeMinute) ?? 0;

    state = NotificationSettings(
      isDailySummaryEnabled: isDailySummaryEnabled,
      summaryTime: TimeOfDay(hour: hour, minute: minute),
    );
  }

  /// Schedule notification based on current settings
  Future<void> _scheduleNotification() async {
    await _notificationService.scheduleDailySummary(
      time: state.summaryTime,
      enabled: state.isDailySummaryEnabled,
    );
  }

  /// Toggle daily summary notification
  /// Returns result indicating success or which permission was denied
  Future<NotificationEnableResult> setDailySummaryEnabled(bool enabled) async {
    if (enabled) {
      // Step 1: Check and request basic notification permission
      final hasNotificationPermission = await _notificationService.checkPermission();
      if (!hasNotificationPermission) {
        final granted = await _notificationService.requestPermission();
        if (!granted) {
          return NotificationEnableResult.notificationPermissionDenied;
        }
      }

      // Step 2: Check exact alarm permission (Android 12+)
      // If not granted, still enable with inexact scheduling
      final hasExactAlarmPermission = await _notificationService.canScheduleExactAlarms();

      await _setDailySummaryEnabledInternal(enabled);

      if (!hasExactAlarmPermission) {
        // Notification is scheduled with inexact mode - warn user
        return NotificationEnableResult.successWithInexactScheduling;
      }

      return NotificationEnableResult.success;
    }

    await _setDailySummaryEnabledInternal(enabled);
    return NotificationEnableResult.success;
  }

  /// Internal method to set enabled state without permission check
  Future<void> _setDailySummaryEnabledInternal(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDailySummaryEnabled, enabled);
    state = state.copyWith(isDailySummaryEnabled: enabled);
    await _scheduleNotification();
  }

  /// Set summary notification time
  Future<void> setSummaryTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keySummaryTimeHour, time.hour);
    await prefs.setInt(_keySummaryTimeMinute, time.minute);
    state = state.copyWith(summaryTime: time);
    await _scheduleNotification();
  }

  /// Request notification permission
  Future<bool> requestPermission() async {
    return await _notificationService.requestPermission();
  }
}
