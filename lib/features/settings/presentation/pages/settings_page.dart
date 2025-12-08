import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/features/settings/presentation/widgets/budget_settings_section.dart';
import 'package:daily_pace/features/settings/presentation/widgets/recurring_section.dart';
import 'package:daily_pace/features/settings/presentation/widgets/data_management_section.dart';
import 'package:daily_pace/features/settings/presentation/widgets/notification_section.dart';

/// Settings page
/// App configuration, preferences, and account settings
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Budget Settings Section
            const BudgetSettingsSection(),
            const SizedBox(height: 24),

            // Recurring Transactions Section
            const RecurringSection(),
            const SizedBox(height: 24),

            // Notification Settings Section
            const NotificationSection(),
            const SizedBox(height: 24),

            // Data Management Section
            const DataManagementSection(),
            const SizedBox(height: 100), // Extra space at bottom
          ],
        ),
      ),
    );
  }
}
