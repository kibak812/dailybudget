import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';
import 'package:daily_pace/app/theme/app_colors.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/features/recurring/data/models/recurring_transaction_model.dart';
import 'package:daily_pace/features/settings/presentation/widgets/recurring_modal.dart';

/// Recurring Transactions Section Widget
/// Displays and manages recurring transactions in an expandable tile
class RecurringSection extends ConsumerWidget {
  const RecurringSection({super.key});

  Future<void> _showRecurringModal(
    BuildContext context,
    RecurringTransactionModel? recurring,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => RecurringModal(recurring: recurring),
    );
  }

  Future<void> _handleToggle(
    WidgetRef ref,
    BuildContext context,
    RecurringTransactionModel recurring,
  ) async {
    await ref.read(recurringProvider.notifier).toggleActive(recurring.id);
  }

  Future<void> _handleDelete(
    WidgetRef ref,
    BuildContext context,
    RecurringTransactionModel recurring,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.recurring_deleteTitle),
        content: Text(context.l10n.recurring_deleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(context.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: Text(context.l10n.common_delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(recurringProvider.notifier).deleteRecurringTransaction(recurring.id);
    }
  }

  Future<void> _handleRegenerate(
    WidgetRef ref,
    BuildContext context,
  ) async {
    final currentMonth = ref.read(currentMonthProvider);
    await ref.read(recurringProvider.notifier).generateForMonth(
          currentMonth.year,
          currentMonth.month,
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recurringTransactions = ref.watch(recurringProvider);
    final count = recurringTransactions.length;

    return Container(
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
              color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.repeat_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          title: Text(
            context.l10n.recurring_title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (count > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.l10n.recurring_count(count),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
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
            // Add button
            InkWell(
              onTap: () => _showRecurringModal(context, null),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.add_circle_outline,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      context.l10n.recurring_add,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            if (recurringTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    context.l10n.recurring_empty,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                  ),
                ),
              )
            else
              ...recurringTransactions.asMap().entries.map((entry) {
                final index = entry.key;
                final recurring = entry.value;

                return Column(
                  children: [
                    Divider(height: 1, color: AppColors.borderLight),
                    InkWell(
                      onTap: null,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Day Badge
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: recurring.isActive
                                    ? Theme.of(context)
                                        .colorScheme
                                        .primaryContainer
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  recurring.dayOfMonth.toString(),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: recurring.isActive
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : AppColors.textTertiary,
                                      ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          recurring.memo ?? recurring.category ?? '',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.w500,
                                                color: recurring.isActive
                                                    ? AppColors.textPrimary
                                                    : AppColors.textTertiary,
                                              ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (!recurring.isActive) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.surfaceVariant,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'OFF',
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelSmall
                                                ?.copyWith(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: AppColors.textSecondary,
                                                ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Formatters.formatCurrency(recurring.amount, context),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                  ),
                                ],
                              ),
                            ),

                            // Action Buttons
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Toggle Button
                                IconButton(
                                  onPressed: () =>
                                      _handleToggle(ref, context, recurring),
                                  icon: Icon(
                                    recurring.isActive
                                        ? Icons.toggle_on
                                        : Icons.toggle_off,
                                    size: 28,
                                    color: recurring.isActive
                                        ? Theme.of(context).colorScheme.primary
                                        : AppColors.textTertiary,
                                  ),
                                ),

                                // Edit Button
                                IconButton(
                                  onPressed: () =>
                                      _showRecurringModal(context, recurring),
                                  icon: Icon(
                                    Icons.edit,
                                    size: 20,
                                    color: AppColors.textTertiary,
                                  ),
                                ),

                                // Delete Button
                                IconButton(
                                  onPressed: () =>
                                      _handleDelete(ref, context, recurring),
                                  icon: Icon(
                                    Icons.delete,
                                    size: 20,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }),

            // Regenerate Button
            if (recurringTransactions.isNotEmpty) ...[
              Container(
                color: AppColors.surfaceVariant.withOpacity(0.5),
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: () => _handleRegenerate(ref, context),
                  style: TextButton.styleFrom(
                    minimumSize: const Size.fromHeight(32),
                  ),
                  child: Text(
                    context.l10n.recurring_regenerate,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
