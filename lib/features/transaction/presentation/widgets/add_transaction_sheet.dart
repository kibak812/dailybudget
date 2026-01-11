import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';
import 'package:daily_pace/app/theme/app_colors.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/category_selector_sheet.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/calculator_sheet.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/core/providers/providers.dart';

/// Bottom sheet for adding a new transaction
class AddTransactionSheet extends ConsumerStatefulWidget {
  final DateTime? initialDate;

  const AddTransactionSheet({
    super.key,
    this.initialDate,
  });

  @override
  ConsumerState<AddTransactionSheet> createState() => _AddTransactionSheetState();
}

class _AddTransactionSheetState extends ConsumerState<AddTransactionSheet> {
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();

  TransactionType _selectedType = TransactionType.expense;
  String? _selectedCategory;
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Validate amount (pass context for locale-aware parsing)
    final amount = Formatters.parseFormattedNumber(_amountController.text, context);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.error_enterAmount)),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final transaction = TransactionModel.create(
        type: _selectedType,
        amount: amount,
        date: Formatters.formatDateISO(_selectedDate),
        category: _selectedCategory,
        memo: _memoController.text.isEmpty ? null : _memoController.text,
      );

      await ref.read(transactionProvider.notifier).addTransaction(transaction);

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
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
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

  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => CategorySelectorSheet(
        type: _selectedType == TransactionType.expense
            ? CategoryType.expense
            : CategoryType.income,
        selectedCategory: _selectedCategory,
        onSelected: (category) {
          setState(() => _selectedCategory = category);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
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
                context.l10n.transaction_addTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // Type selector
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
                selected: {_selectedType},
                onSelectionChanged: (Set<TransactionType> newSelection) {
                  setState(() {
                    _selectedType = newSelection.first;
                    _selectedCategory = null; // Reset category
                  });
                },
              ),
              const SizedBox(height: 24),

              // Amount input
              Builder(
                builder: (context) {
                  final isEnglish = Formatters.isEnglishLocale(context);
                  return TextField(
                    controller: _amountController,
                    decoration: InputDecoration(
                      labelText: context.l10n.transaction_amount,
                      hintText: isEnglish ? '0.00' : context.l10n.transaction_amountHint,
                      prefixText: isEnglish ? '\$ ' : null,
                      suffixText: isEnglish ? null : context.l10n.unit_won,
                      border: const OutlineInputBorder(),
                      prefixIcon: Icon(
                        _selectedType == TransactionType.expense
                            ? Icons.remove_circle
                            : Icons.add_circle,
                        color: _selectedType == TransactionType.expense
                            ? theme.colorScheme.error
                            : theme.colorScheme.primary,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.calculate_outlined),
                        tooltip: context.l10n.calculator_title,
                        onPressed: _showCalculator,
                      ),
                    ),
                    keyboardType: isEnglish
                        ? const TextInputType.numberWithOptions(decimal: true)
                        : TextInputType.number,
                    inputFormatters: isEnglish
                        ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'))]
                        : [FilteringTextInputFormatter.digitsOnly],
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
              const SizedBox(height: 16),

              // Category selector
              InkWell(
                onTap: () => _showCategorySelector(),
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: context.l10n.transaction_category,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.category),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory ?? context.l10n.transaction_categorySelect,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: _selectedCategory == null
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
              const SizedBox(height: 16),

              // Memo input
              TextField(
                controller: _memoController,
                decoration: InputDecoration(
                  labelText: context.l10n.transaction_memo,
                  hintText: context.l10n.transaction_memoHint,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.note),
                ),
                maxLines: 2,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),

              // Date picker
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: context.l10n.transaction_date,
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    Formatters.formatDateFull(
                      Formatters.formatDateISO(_selectedDate),
                      context,
                    ),
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              FilledButton(
                onPressed: _isLoading ? null : _handleSubmit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.transaction_addButton),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
