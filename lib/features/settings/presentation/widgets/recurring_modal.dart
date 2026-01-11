import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';
import 'package:daily_pace/app/theme/app_colors.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/features/recurring/data/models/recurring_transaction_model.dart';
import 'package:daily_pace/features/settings/presentation/providers/categories_provider.dart';

/// Recurring Transaction Modal Widget
/// Add or edit recurring transactions
class RecurringModal extends ConsumerStatefulWidget {
  final RecurringTransactionModel? recurring;

  const RecurringModal({
    super.key,
    this.recurring,
  });

  @override
  ConsumerState<RecurringModal> createState() => _RecurringModalState();
}

class _RecurringModalState extends ConsumerState<RecurringModal> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _memoController = TextEditingController();

  late RecurringTransactionType _type;
  String? _category;
  bool _isActive = true;
  String? _startMonth;
  String? _endMonth;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    if (widget.recurring != null) {
      // Edit mode (amount will be set in didChangeDependencies)
      _type = widget.recurring!.type;
      _dayController.text = widget.recurring!.dayOfMonth.toString();
      _category = widget.recurring!.category;
      _memoController.text = widget.recurring!.memo ?? '';
      _isActive = widget.recurring!.isActive;
      _startMonth = widget.recurring!.startMonth;
      _endMonth = widget.recurring!.endMonth;
    } else {
      // Add mode
      _type = RecurringTransactionType.expense;
      _dayController.text = '1';
      final now = DateTime.now();
      _startMonth =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized && widget.recurring != null) {
      // Initialize amount with locale-aware formatting
      final isEnglish = Formatters.isEnglishLocale(context);
      final amount = widget.recurring!.amount;
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
    _dayController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final amount = Formatters.parseFormattedNumber(_amountController.text, context);
    final day = int.tryParse(_dayController.text);

    // Validation
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.error_invalidAmount),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (day == null || day < 1 || day > 31) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.error_invalidDay),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (_category == null || _category!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.error_selectCategory),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    try {
      if (widget.recurring != null) {
        // Update existing - create updated model with all fields
        final updatedRecurring = RecurringTransactionModel(
          type: _type,
          amount: amount,
          dayOfMonth: day,
          category: _category,
          memo: _memoController.text.isEmpty ? null : _memoController.text,
          isActive: _isActive,
          startMonth: _startMonth ?? widget.recurring!.startMonth,
          endMonth: _endMonth,
          createdAt: widget.recurring!.createdAt,
          updatedAt: DateTime.now(),
        )..id = widget.recurring!.id;

        await ref.read(recurringProvider.notifier).updateRecurringTransaction(updatedRecurring);
      } else {
        // Add new
        final newRecurring = RecurringTransactionModel.create(
          type: _type,
          amount: amount,
          dayOfMonth: day,
          category: _category,
          memo: _memoController.text.isEmpty ? null : _memoController.text,
          isActive: _isActive,
          startMonth: _startMonth!,
          endMonth: _endMonth,
        );

        await ref.read(recurringProvider.notifier).addRecurringTransaction(newRecurring);
      }

      if (mounted) {
        Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    ref.watch(categoriesProvider);

    // Get categories based on selected type
    final categories = ref.read(categoriesProvider.notifier).getCategoriesByType(
      _type == RecurringTransactionType.expense ? CategoryType.expense : CategoryType.income,
    );

    // Set default category if not set or if current category is not in filtered list
    if (_category == null || !categories.contains(_category)) {
      _category = categories.isNotEmpty ? categories.first : null;
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.recurring != null ? context.l10n.recurring_editTitle : context.l10n.recurring_addTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Type Selector
                Text(
                  context.l10n.recurring_type,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<RecurringTransactionType>(
                  segments: [
                    ButtonSegment(
                      value: RecurringTransactionType.expense,
                      label: Text(context.l10n.transaction_expense),
                    ),
                    ButtonSegment(
                      value: RecurringTransactionType.income,
                      label: Text(context.l10n.transaction_income),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (Set<RecurringTransactionType> newSelection) {
                    setState(() {
                      _type = newSelection.first;
                      // Reset category when type changes
                      _category = null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Amount
                Text(
                  context.l10n.recurring_amount,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
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
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        hintText: isEnglish ? '0.00' : context.l10n.recurring_amountExample,
                        prefixText: isEnglish ? '\$ ' : null,
                        suffixText: isEnglish ? null : context.l10n.unit_won,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        final formatted = Formatters.formatNumberInput(value, context);
                        if (formatted != value) {
                          _amountController.value = TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(
                              offset: formatted.length,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Day of Month
                Text(
                  context.l10n.recurring_dayOfMonth,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dayController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: context.l10n.recurring_dayOfMonthHint,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category
                Text(
                  context.l10n.transaction_category,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: categories.map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _category = value;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Memo
                Text(
                  context.l10n.recurring_memo,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _memoController,
                  decoration: InputDecoration(
                    hintText: context.l10n.recurring_example,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Active Switch
                SwitchListTile(
                  title: Text(context.l10n.recurring_enabled),
                  value: _isActive,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(context.l10n.common_cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(widget.recurring != null ? context.l10n.common_edit : context.l10n.common_add),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
