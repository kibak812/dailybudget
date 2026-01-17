import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';
import 'package:daily_pace/app/theme/app_colors.dart';
import 'package:daily_pace/features/settings/presentation/providers/notification_settings_provider.dart';

/// Notification Settings Section Widget
/// Allows user to configure daily summary notification in an expandable tile
class NotificationSection extends ConsumerWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    // Count active notifications
    int activeCount = 0;
    if (settings.isDailySummaryEnabled) activeCount++;
    if (settings.isEveningReminderEnabled) activeCount++;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding: EdgeInsets.zero,
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: activeCount > 0
                  ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
                  : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.notifications_outlined,
              size: 20,
              color: activeCount > 0
                  ? Theme.of(context).colorScheme.primary
                  : AppColors.textSecondary,
            ),
          ),
          title: Text(
            context.l10n.notification_title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: activeCount > 0
                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5)
                      : AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  activeCount > 0
                      ? context.l10n.notification_activeCount(activeCount)
                      : context.l10n.notification_off,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: activeCount > 0
                            ? Theme.of(context).colorScheme.primary
                            : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.expand_more),
            ],
          ),
          children: [
            const Divider(height: 1),
            // Daily summary toggle
            _buildToggleTile(
              context: context,
              title: context.l10n.notification_dailySummary,
              subtitle: context.l10n.notification_dailySummaryDesc,
              value: settings.isDailySummaryEnabled,
              onChanged: (value) => _handleToggle(context, notifier, value),
            ),

            // Time picker (only show when enabled)
            if (settings.isDailySummaryEnabled) ...[
              const Divider(height: 1),
              _buildTimeTile(
                context: context,
                title: context.l10n.notification_time,
                time: settings.summaryTime,
                onTap: () => _showTimePicker(context, ref),
              ),
            ],

            // Evening reminder toggle
            const Divider(height: 1),
            _buildToggleTile(
              context: context,
              title: context.l10n.notification_eveningReminder,
              subtitle: context.l10n.notification_eveningReminderDesc,
              value: settings.isEveningReminderEnabled,
              onChanged: (value) => _handleEveningToggle(context, notifier, value),
            ),

            // Evening time picker (only show when enabled)
            if (settings.isEveningReminderEnabled) ...[
              const Divider(height: 1),
              _buildTimeTile(
                context: context,
                title: context.l10n.notification_eveningTime,
                time: settings.eveningReminderTime,
                onTap: () => _showEveningTimePicker(context, ref),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleToggle(
    BuildContext context,
    NotificationSettingsNotifier notifier,
    bool value,
  ) async {
    final result = await notifier.setDailySummaryEnabled(value);

    if (!context.mounted) return;

    switch (result) {
      case NotificationEnableResult.success:
      case NotificationEnableResult.successWithInexactScheduling:
      case NotificationEnableResult.exactAlarmPermissionDenied:
        // Success - UI toggle confirms the change
        break;
      case NotificationEnableResult.notificationPermissionDenied:
        _showPermissionSnackBar(
          context,
          message: context.l10n.notification_permissionRequired,
          actionLabel: context.l10n.notification_requestAgain,
          onAction: () => notifier.requestPermission(),
        );
        break;
    }
  }

  void _showPermissionSnackBar(
    BuildContext context, {
    required String message,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.amber,
          onPressed: onAction,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildToggleTile({
    required BuildContext context,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: Theme.of(context).colorScheme.primary,
            activeColor: Colors.white,
            inactiveThumbColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeTile({
    required BuildContext context,
    required String title,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    final timeString = _formatTime(context, time);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(
              Icons.access_time_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                timeString,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(BuildContext context, TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? context.l10n.notification_am : context.l10n.notification_pm;
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    return '$period $displayHour:$minute';
  }

  Future<void> _showTimePicker(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    final picked = await showTimePicker(
      context: context,
      initialTime: settings.summaryTime,
      initialEntryMode: TimePickerEntryMode.inputOnly,
      helpText: context.l10n.notification_timeSelect,
      cancelText: context.l10n.common_cancel,
      confirmText: context.l10n.common_confirm,
      hourLabelText: context.l10n.notification_hour,
      minuteLabelText: context.l10n.notification_minute,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hourMinuteTextStyle: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w500,
              ),
              dayPeriodTextStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              helpTextStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false,
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      await notifier.setSummaryTime(picked);
    }
  }

  Future<void> _handleEveningToggle(
    BuildContext context,
    NotificationSettingsNotifier notifier,
    bool value,
  ) async {
    final result = await notifier.setEveningReminderEnabled(value);

    if (!context.mounted) return;

    switch (result) {
      case NotificationEnableResult.success:
      case NotificationEnableResult.successWithInexactScheduling:
      case NotificationEnableResult.exactAlarmPermissionDenied:
        // Success - UI toggle confirms the change
        break;
      case NotificationEnableResult.notificationPermissionDenied:
        _showPermissionSnackBar(
          context,
          message: context.l10n.notification_permissionRequired,
          actionLabel: context.l10n.notification_requestAgain,
          onAction: () => notifier.requestPermission(),
        );
        break;
    }
  }

  Future<void> _showEveningTimePicker(BuildContext context, WidgetRef ref) async {
    final settings = ref.read(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    final picked = await showTimePicker(
      context: context,
      initialTime: settings.eveningReminderTime,
      initialEntryMode: TimePickerEntryMode.inputOnly,
      helpText: context.l10n.notification_eveningTimeSelect,
      cancelText: context.l10n.common_cancel,
      confirmText: context.l10n.common_confirm,
      hourLabelText: context.l10n.notification_hour,
      minuteLabelText: context.l10n.notification_minute,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              hourMinuteTextStyle: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w500,
              ),
              dayPeriodTextStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              helpTextStyle: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(
              alwaysUse24HourFormat: false,
            ),
            child: child!,
          ),
        );
      },
    );

    if (picked != null) {
      await notifier.setEveningReminderTime(picked);
    }
  }
}
