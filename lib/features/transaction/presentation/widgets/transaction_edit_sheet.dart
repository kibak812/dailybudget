import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/category_selector_sheet.dart';
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => TransactionEditModalSheet(transaction: transaction),
    );
  }
}

/// Separate modal sheet widget for editing transactions with proper Riverpod context
class TransactionEditModalSheet extends ConsumerStatefulWidget {
  final TransactionModel transaction;

  const TransactionEditModalSheet({
    super.key,
    required this.transaction,
  });

  @override
  ConsumerState<TransactionEditModalSheet> createState() =>
      _TransactionEditModalSheetState();
}

class _TransactionEditModalSheetState
    extends ConsumerState<TransactionEditModalSheet> {
  late final TextEditingController _amountController;
  late final TextEditingController _memoController;
  late String? _categoryValue;
  late TransactionType _typeValue;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: Formatters.formatNumberInput(widget.transaction.amount.toString()),
    );
    _memoController = TextEditingController(
      text: widget.transaction.memo ?? '',
    );
    _categoryValue = widget.transaction.category;
    _typeValue = widget.transaction.type;
    _selectedDate = DateTime.parse(widget.transaction.date);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    try {
      final amount = Formatters.parseFormattedNumber(_amountController.text);
      if (amount <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('올바른 금액을 입력해주세요')),
          );
        }
        return;
      }

      final updates = <String, dynamic>{
        'type': _typeValue,
        'amount': amount,
        'date': Formatters.formatDateISO(_selectedDate),
        'category': (_categoryValue ?? '').isEmpty ? null : _categoryValue,
        'memo': _memoController.text.trim().isEmpty
            ? null
            : _memoController.text.trim(),
      };

      await ref.read(transactionProvider.notifier).updateTransaction(
            widget.transaction.id,
            updates,
          );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('거래가 수정되었습니다')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('수정 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _showCategorySelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CategorySelectorSheet(
        type: _typeValue == TransactionType.expense
            ? CategoryType.expense
            : CategoryType.income,
        selectedCategory: _categoryValue,
        onSelected: (category) {
          setState(() => _categoryValue = category);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '거래 수정',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SegmentedButton<TransactionType>(
            segments: const [
              ButtonSegment(
                value: TransactionType.expense,
                label: Text('지출'),
                icon: Icon(Icons.remove_circle_outline),
              ),
              ButtonSegment(
                value: TransactionType.income,
                label: Text('수입'),
                icon: Icon(Icons.add_circle_outline),
              ),
            ],
            selected: {_typeValue},
            onSelectionChanged: (value) {
              setState(() {
                _typeValue = value.first;
                _categoryValue = null; // Reset category when type changes
              });
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: '금액',
              hintText: '0',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final formatted = Formatters.formatNumberInput(value);
              if (formatted != value) {
                _amountController.value = TextEditingValue(
                  text: formatted,
                  selection: TextSelection.collapsed(offset: formatted.length),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _showCategorySelector(context),
            borderRadius: BorderRadius.circular(4),
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: '카테고리 (선택)',
                border: OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _categoryValue ?? '선택하세요',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _categoryValue == null
                          ? theme.colorScheme.onSurfaceVariant
                          : null,
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _memoController,
            decoration: const InputDecoration(
              labelText: '메모 (선택)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text(
                '날짜: ${Formatters.formatDateFull(Formatters.formatDateISO(_selectedDate))}'),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _handleUpdate,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('수정 완료'),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
