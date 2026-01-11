import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:daily_pace/core/services/daily_summary_service.dart';
import 'package:daily_pace/core/services/locale_service.dart';

/// Service for handling local notifications
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final LocaleService _localeService = LocaleService();

  static const int _dailySummaryNotificationId = 1;
  static const String _channelId = 'daily_summary';

  bool _isInitialized = false;

  /// Initialize the notification service
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize locale service first
    await _localeService.initialize();

    // Initialize timezone with device's local timezone
    tzData.initializeTimeZones();
    try {
      final String currentTimeZone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
      debugPrint('Timezone initialized: $currentTimeZone');
    } catch (e) {
      // Fallback to Asia/Seoul for Korean users
      debugPrint('Failed to get timezone, using Asia/Seoul: $e');
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    }

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _isInitialized = true;
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Can be extended to navigate to specific screen
    debugPrint('Notification tapped: ${response.payload}');
  }

  /// Request notification permissions (Android 13+)
  Future<bool> requestPermission() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }

    return true; // iOS handles this during initialization
  }

  /// Check if notification permission is granted (without requesting)
  Future<bool> checkPermission() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.areNotificationsEnabled();
      return granted ?? false;
    }

    return true; // iOS - assume granted if initialized
  }

  /// Check if exact alarm permission is granted (Android 12+)
  /// Required for zonedSchedule with exactAllowWhileIdle
  Future<bool> canScheduleExactAlarms() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final canSchedule = await android.canScheduleExactNotifications();
      return canSchedule ?? false;
    }

    return true; // iOS or unsupported platforms - no exact alarm permission needed
  }

  /// Request exact alarm permission (opens system settings on Android 12+)
  /// Returns true if permission is granted after request
  Future<bool> requestExactAlarmPermission() async {
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      await android.requestExactAlarmsPermission();
      // Check if permission was granted after user returns from settings
      return await canScheduleExactAlarms();
    }

    return true; // iOS or unsupported platforms
  }

  /// Schedule daily summary notification
  /// Automatically falls back to inexact scheduling if exact alarm permission is not granted
  Future<void> scheduleDailySummary({
    required TimeOfDay time,
    required bool enabled,
  }) async {
    // Cancel existing notification first
    await _notifications.cancel(_dailySummaryNotificationId);

    if (!enabled) return;

    // Refresh locale before scheduling
    await _localeService.refresh();

    // Check exact alarm permission and choose schedule mode
    final hasExactAlarmPermission = await canScheduleExactAlarms();
    final scheduleMode = hasExactAlarmPermission
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;

    if (!hasExactAlarmPermission) {
      debugPrint('Exact alarm permission not granted, using inexact scheduling');
    }

    // Calculate next notification time
    final now = DateTime.now();
    var scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);
    debugPrint('Scheduling notification for: $tzScheduledDate (mode: $scheduleMode)');

    // Get localized strings
    final channelName = _localeService.notificationChannelName;
    final channelDesc = _localeService.notificationChannelDesc;
    final pushTitle = _localeService.notificationPushTitle;
    final pushBody = _localeService.notificationPushBody;

    // Notification details
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: const BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule notification to repeat daily
    await _notifications.zonedSchedule(
      _dailySummaryNotificationId,
      pushTitle,
      pushBody,
      tzScheduledDate,
      notificationDetails,
      androidScheduleMode: scheduleMode,
      matchDateTimeComponents: DateTimeComponents.time, // Repeat daily
    );
  }

  /// Show immediate notification (for testing or immediate alerts)
  Future<void> showDailySummaryNow(DailySummary summary) async {
    // Refresh locale before showing
    await _localeService.refresh();

    final channelName = _localeService.notificationChannelName;
    final channelDesc = _localeService.notificationChannelDesc;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: const BigTextStyleInformation(''),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      _dailySummaryNotificationId,
      summary.getNotificationTitle(_localeService),
      summary.getNotificationBody(_localeService),
      notificationDetails,
    );
  }

  /// Cancel all scheduled notifications
  Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
