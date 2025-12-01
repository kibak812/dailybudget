import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/core/providers/providers.dart';

/// Bottom sheet for editing or deleting a transaction
class TransactionEditSheet extends ConsumerWidget {
  final TransactionModel transaction;

  const TransactionEditSheet({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title
              Text(
                '거래 상세',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Transaction details
              _buildDetailRow(
                context,
                '금액',
                '${transaction.type == TransactionType.expense ? '-' : '+'}${Formatters.formatCurrency(transaction.amount)}',
                isAmount: true,
              ),
              const Divider(height: 24),

              _buildDetailRow(
                context,
                '카테고리',
                transaction.category ?? '미분류',
              ),
              const Divider(height: 24),

              if (transaction.memo != null && transaction.memo!.isNotEmpty) ...[
                _buildDetailRow(
                  context,
                  '메모',
                  transaction.memo!,
                ),
                const Divider(height: 24),
              ],

              _buildDetailRow(
                context,
                '날짜',
                Formatters.formatDateFull(transaction.date),
              ),
              const Divider(height: 24),

              _buildDetailRow(
                context,
                '등록 시간',
                Formatters.formatTime(transaction.createdAt),
              ),

              if (transaction.recurringId != null) ...[
                const Divider(height: 24),
                _buildDetailRow(
                  context,
                  '반복 거래',
                  '예',
                  badge: true,
                ),
              ],

              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  // Delete button
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        // Confirm delete
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('거래 삭제'),
                            content: const Text('이 거래를 삭제하시겠습니까?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text('취소'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: Text(
                                  '삭제',
                                  style: TextStyle(color: theme.colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          // Delete transaction
                          await ref
                              .read(transactionProvider.notifier)
                              .deleteTransaction(transaction.id);

                          if (context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('거래가 삭제되었습니다')),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('삭제'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                        side: BorderSide(color: theme.colorScheme.error),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Edit button
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        // Close this sheet
                        Navigator.of(context).pop();

                        // Show edit dialog
                        _showEditDialog(context, ref);
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('수정'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value, {
    bool isAmount = false,
    bool badge = false,
  }) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (badge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          Flexible(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isAmount ? FontWeight.bold : FontWeight.w600,
                color: isAmount
                    ? (transaction.type == TransactionType.expense
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary)
                    : theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.end,
            ),
          ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    // TODO: Implement edit dialog or navigate to edit page
    // For now, just show a placeholder snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('수정 기능은 추후 구현 예정입니다')),
    );
  }
}
