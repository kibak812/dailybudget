import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/app/theme/app_colors.dart';
import 'package:daily_pace/features/settings/presentation/providers/notification_settings_provider.dart';

/// Notification Settings Section Widget
/// Allows user to configure daily summary notification
class NotificationSection extends ConsumerWidget {
  const NotificationSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '알림 설정',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        const SizedBox(height: 12),

        // Settings card
        Container(
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
          child: Column(
            children: [
              // Daily summary toggle
              _buildToggleTile(
                context: context,
                title: '하루 결산 알림',
                subtitle: '매일 설정한 시간에 어제의 지출 결산을 알려드려요',
                value: settings.isDailySummaryEnabled,
                onChanged: (value) => _handleToggle(context, notifier, value),
              ),

              // Time picker (only show when enabled)
              if (settings.isDailySummaryEnabled) ...[
                const Divider(height: 1),
                _buildTimeTile(
                  context: context,
                  title: '알림 시간',
                  time: settings.summaryTime,
                  onTap: () => _showTimePicker(context, ref),
                ),
              ],
            ],
          ),
        ),
      ],
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
        // 성공 - 토스트 없이 UI 토글로 확인 가능
        break;
      case NotificationEnableResult.notificationPermissionDenied:
        _showPermissionSnackBar(
          context,
          message: '알림 권한이 필요합니다. 설정에서 권한을 허용해주세요.',
          actionLabel: '다시 요청',
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
    final timeString = _formatTime(time);

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

  String _formatTime(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = hour < 12 ? '오전' : '오후';
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
      helpText: '알림 시간 선택',
      cancelText: '취소',
      confirmText: '확인',
      hourLabelText: '시',
      minuteLabelText: '분',
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
}
