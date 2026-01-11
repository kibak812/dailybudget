import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/app/theme/app_colors.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/category_selector_sheet.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/calculator_sheet.dart';
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
                context.l10n.transaction_detailTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Transaction details
              _buildDetailRow(
                context,
                context.l10n.transaction_amount,
                '${transaction.type == TransactionType.expense ? '-' : '+'}${Formatters.formatCurrency(transaction.amount, context)}',
                isAmount: true,
              ),
              const Divider(height: 24),

              _buildDetailRow(
                context,
                context.l10n.transaction_category,
                transaction.category ?? context.l10n.transaction_uncategorized,
              ),
              const Divider(height: 24),

              if (transaction.memo != null && transaction.memo!.isNotEmpty) ...[
                _buildDetailRow(
                  context,
                  context.l10n.transaction_memo.replaceAll(' (선택)', '').replaceAll(' (Optional)', ''),
                  transaction.memo!,
                ),
                const Divider(height: 24),
              ],

              _buildDetailRow(
                context,
                context.l10n.transaction_date,
                Formatters.formatDateFull(transaction.date, context),
              ),
              const Divider(height: 24),

              _buildDetailRow(
                context,
                context.l10n.transaction_createdAt,
                Formatters.formatTime(transaction.createdAt),
              ),

              if (transaction.recurringId != null) ...[
                const Divider(height: 24),
                _buildDetailRow(
                  context,
                  context.l10n.transaction_isRecurring,
                  context.l10n.common_yes,
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
                        );

                        if (confirmed == true && context.mounted) {
                          // Delete transaction
                          await ref
                              .read(transactionProvider.notifier)
                              .deleteTransaction(transaction.id);

                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        }
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: Text(context.l10n.common_delete),
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
                      label: Text(context.l10n.common_edit),
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
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _memoController = TextEditingController(
      text: widget.transaction.memo ?? '',
    );
    _categoryValue = widget.transaction.category;
    _typeValue = widget.transaction.type;
    _selectedDate = DateTime.parse(widget.transaction.date);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      // Initialize amount with locale-aware formatting
      final isEnglish = Formatters.isEnglishLocale(context);
      final amount = widget.transaction.amount;
      // For English, convert cents to dollars for display
      final displayValue = isEnglish
          ? (amount / 100).toStringAsFixed(2)
          : amount.toString();
      _amountController.text = Formatters.formatNumberInput(displayValue, context);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _handleUpdate() async {
    try {
      final amount = Formatters.parseFormattedNumber(_amountController.text, context);
      if (amount <= 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.error_invalidAmount)),
          );
        }
        return;
      }

      // Create updated transaction model with all fields
      final updatedTransaction = TransactionModel(
        type: _typeValue,
        amount: amount,
        date: Formatters.formatDateISO(_selectedDate),
        category: (_categoryValue ?? '').isEmpty ? null : _categoryValue,
        memo: _memoController.text.trim().isEmpty
            ? null
            : _memoController.text.trim(),
        createdAt: widget.transaction.createdAt,
        updatedAt: DateTime.now(),
        recurringId: widget.transaction.recurringId,
      )..id = widget.transaction.id;

      await ref.read(transactionProvider.notifier).updateTransaction(updatedTransaction);

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.error_generic(e.toString())),
            backgroundColor: AppColors.danger,
          ),
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

  void _showCalculator() async {
    final currentAmount = Formatters.parseFormattedNumber(_amountController.text, context);

    final result = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CalculatorSheet(
        initialValue: currentAmount > 0 ? currentAmount : null,
      ),
    );

    if (result != null && result > 0) {
      // For English locale, convert cents back to dollars for display
      final isEnglish = Formatters.isEnglishLocale(context);
      final displayValue = isEnglish ? (result / 100).toStringAsFixed(2) : result.toString();
      final formatted = Formatters.formatNumberInput(displayValue, context);
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
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
            context.l10n.transaction_editTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SegmentedButton<TransactionType>(
            segments: [
              ButtonSegment(
                value: TransactionType.expense,
                label: Text(context.l10n.transaction_expense),
                icon: const Icon(Icons.remove_circle_outline),
              ),
              ButtonSegment(
                value: TransactionType.income,
                label: Text(context.l10n.transaction_income),
                icon: const Icon(Icons.add_circle_outline),
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
          Builder(
            builder: (context) {
              final isEnglish = Formatters.isEnglishLocale(context);
              return TextField(
                controller: _amountController,
                keyboardType: isEnglish
                    ? const TextInputType.numberWithOptions(decimal: true)
                    : TextInputType.number,
                inputFormatters: isEnglish
                    ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
                    : [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: context.l10n.transaction_amount,
                  hintText: isEnglish ? '0.00' : context.l10n.transaction_amountHint,
                  prefixText: isEnglish ? '\$ ' : null,
                  suffixText: isEnglish ? null : context.l10n.unit_won,
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calculate_outlined),
                    tooltip: context.l10n.calculator_title,
                    onPressed: _showCalculator,
                  ),
                ),
                onChanged: (value) {
                  final formatted = Formatters.formatNumberInput(value, context);
                  if (formatted != value) {
                    _amountController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
              );
            },
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _showCategorySelector(context),
            borderRadius: BorderRadius.circular(4),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: context.l10n.transaction_categoryOptional,
                border: const OutlineInputBorder(),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _categoryValue ?? context.l10n.transaction_categorySelect,
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
            decoration: InputDecoration(
              labelText: context.l10n.transaction_memo,
              border: const OutlineInputBorder(),
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
                context.l10n.transaction_dateLabel(Formatters.formatDateFull(Formatters.formatDateISO(_selectedDate), context))),
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _handleUpdate,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Text(context.l10n.transaction_editButton),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
