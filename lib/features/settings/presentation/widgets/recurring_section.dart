import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/app/theme/app_colors.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/features/recurring/data/models/recurring_transaction_model.dart';
import 'package:daily_pace/features/settings/presentation/widgets/recurring_modal.dart';

/// Recurring Transactions Section Widget
/// Displays and manages recurring transactions
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
      builder: (context) => AlertDialog(
        title: const Text('반복 지출 삭제'),
        content: const Text('정말로 이 반복 지출을 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('삭제'),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '반복 지출',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      letterSpacing: 1.2,
                    ),
              ),
              InkWell(
                onTap: () => _showRecurringModal(context, null),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '추가하기',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
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
              if (recurringTransactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      '등록된 반복 지출이 없습니다',
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
                      if (index > 0)
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
                                      Formatters.formatCurrency(recurring.amount),
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
                      '현재 기간 반복 지출 다시 생성하기',
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
      ],
    );
  }
}
