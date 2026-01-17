import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';
import 'package:daily_pace/core/widgets/banner_ad_widget.dart';
import 'package:daily_pace/features/settings/presentation/widgets/budget_settings_section.dart';
import 'package:daily_pace/features/settings/presentation/widgets/recurring_section.dart';
import 'package:daily_pace/features/settings/presentation/widgets/data_management_section.dart';
import 'package:daily_pace/features/settings/presentation/widgets/notification_section.dart';
import 'package:daily_pace/features/settings/presentation/widgets/language_section.dart';
import 'package:daily_pace/features/settings/presentation/widgets/settings_group.dart';

/// Settings page
/// App configuration, preferences, and account settings
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.settings_title),
        ),
        body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Group 1: Budget Management
                  SettingsGroup(
                    title: context.l10n.settings_budgetManagement,
                    children: const [
                      BudgetSettingsSection(),
                      SizedBox(height: 12),
                      RecurringSection(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Group 2: App Preferences
                  SettingsGroup(
                    title: context.l10n.settings_appPreferences,
                    children: const [
                      LanguageSection(),
                      SizedBox(height: 12),
                      NotificationSection(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Group 3: Data Management
                  SettingsGroup(
                    title: context.l10n.settings_dataManagement,
                    children: const [
                      DataManagementSection(),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const SafeArea(
            top: false,
            child: BannerAdWidget(),
          ),
        ],
      ),
      ),
    );
  }
}
