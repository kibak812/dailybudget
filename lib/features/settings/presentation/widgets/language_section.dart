import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';
import 'package:daily_pace/app/theme/app_colors.dart';
import 'package:daily_pace/features/settings/presentation/providers/language_provider.dart';

/// Language Settings Section Widget
/// Allows user to select app language
class LanguageSection extends ConsumerWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSetting = ref.watch(languageSettingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            context.l10n.language_title,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildLanguageOption(
                context: context,
                ref: ref,
                title: context.l10n.language_system,
                subtitle: _getSystemLanguageHint(context),
                icon: Icons.settings_suggest_outlined,
                setting: LanguageSetting.system,
                currentSetting: currentSetting,
                isFirst: true,
              ),
              Divider(height: 1, color: AppColors.borderLight),
              _buildLanguageOption(
                context: context,
                ref: ref,
                title: context.l10n.language_korean,
                subtitle: '한국어',
                icon: Icons.language,
                setting: LanguageSetting.korean,
                currentSetting: currentSetting,
              ),
              Divider(height: 1, color: AppColors.borderLight),
              _buildLanguageOption(
                context: context,
                ref: ref,
                title: context.l10n.language_english,
                subtitle: 'English',
                icon: Icons.language,
                setting: LanguageSetting.english,
                currentSetting: currentSetting,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getSystemLanguageHint(BuildContext context) {
    final locale = Localizations.localeOf(context);
    if (locale.languageCode == 'ko') {
      return '현재: 한국어';
    } else {
      return 'Current: English';
    }
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required IconData icon,
    required LanguageSetting setting,
    required LanguageSetting currentSetting,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isSelected = currentSetting == setting;

    return InkWell(
      onTap: () {
        ref.read(languageSettingProvider.notifier).setSetting(setting);
      },
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: Theme.of(context).colorScheme.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
