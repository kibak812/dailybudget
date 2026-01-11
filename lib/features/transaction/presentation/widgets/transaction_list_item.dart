import 'package:flutter/material.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/app/theme/app_colors.dart';

/// Transaction list item widget
/// Displays a single transaction with category, memo, time, and amount
class TransactionListItem extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;
  final VoidCallback? onDismissed;

  const TransactionListItem({
    super.key,
    required this.transaction,
    required this.onTap,
    this.onDismissed,
  });

  /// Get category color based on category name
  Color _getCategoryColor(String? category) {
    if (category == null) return AppColors.textTertiary;

    // Simple color mapping based on category name
    final colorMap = {
      '식비': Colors.orange,
      '교통': Colors.blue,
      '쇼핑': Colors.pink,
      '생활': Colors.green,
      '문화': Colors.purple,
      '의료': Colors.red,
      '주거': Colors.brown,
      '통신': Colors.teal,
      '금융': Colors.indigo,
      '기타': AppColors.textTertiary,
    };

    return colorMap[category] ?? AppColors.textTertiary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryColor = _getCategoryColor(transaction.category);

    Widget itemWidget = Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Category icon/dot
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: categoryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt,
                  color: categoryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Transaction details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Category name
                        if (transaction.category != null)
                          Text(
                            transaction.category!,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                        // Recurring badge
                        if (transaction.recurringId != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              context.l10n.recurring_title,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: Colors.blue.shade700,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Memo
                    if (transaction.memo != null && transaction.memo!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          transaction.memo!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                    // Time
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        Formatters.formatTime(transaction.createdAt),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.outline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // Amount
              Text(
                '${transaction.type == TransactionType.expense ? '-' : '+'}${Formatters.formatCurrency(transaction.amount, context)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: transaction.type == TransactionType.expense
                      ? theme.colorScheme.error
                      : Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Wrap with Dismissible for swipe-to-delete
    if (onDismissed != null) {
      return Dismissible(
        key: Key(transaction.id.toString()),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          decoration: BoxDecoration(
            color: theme.colorScheme.error,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delete,
            color: Colors.white,
          ),
        ),
        confirmDismiss: (direction) async {
          // Show confirmation dialog
          return await showDialog<bool>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: Text(ctx.l10n.transaction_deleteTitle),
              content: Text(ctx.l10n.transaction_deleteMessage),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: Text(ctx.l10n.common_cancel),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: Text(
                    ctx.l10n.common_delete,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                ),
              ],
            ),
          ) ?? false;
        },
        onDismissed: (direction) => onDismissed!(),
        child: itemWidget,
      );
    }

    return itemWidget;
  }
}
