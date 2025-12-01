import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/features/recurring/data/models/recurring_transaction_model.dart';

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

  @override
  void initState() {
    super.initState();

    if (widget.recurring != null) {
      // Edit mode
      _type = widget.recurring!.type;
      _amountController.text =
          Formatters.formatNumberInput(widget.recurring!.amount.toString());
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
  void dispose() {
    _amountController.dispose();
    _dayController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final amount = Formatters.parseFormattedNumber(_amountController.text);
    final day = int.tryParse(_dayController.text);

    // Validation
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('올바른 금액을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (day == null || day < 1 || day > 31) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('날짜는 1~31 사이여야 합니다.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_category == null || _category!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('카테고리를 선택해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.recurring != null) {
      // Update existing
      ref.read(recurringProvider.notifier).updateRecurringTransaction(
        widget.recurring!.id,
        {
          'type': _type,
          'amount': amount,
          'dayOfMonth': day,
          'category': _category,
          'memo': _memoController.text.isEmpty ? null : _memoController.text,
          'isActive': _isActive,
          'startMonth': _startMonth,
          'endMonth': _endMonth,
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('반복 지출이 수정되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
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

      ref.read(recurringProvider.notifier).addRecurringTransaction(newRecurring);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('반복 지출이 추가되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    // Set default category if not set
    if (_category == null && categories.isNotEmpty) {
      _category = categories.first;
    }

    return Dialog(
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
                  widget.recurring != null ? '반복 지출 수정' : '반복 지출 추가',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Type Selector
                Text(
                  '타입',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                SegmentedButton<RecurringTransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: RecurringTransactionType.expense,
                      label: Text('지출'),
                    ),
                    ButtonSegment(
                      value: RecurringTransactionType.income,
                      label: Text('수입'),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (Set<RecurringTransactionType> newSelection) {
                    setState(() {
                      _type = newSelection.first;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Amount
                Text(
                  '금액',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    hintText: '예: 500,000',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    final formatted = Formatters.formatNumberInput(value);
                    if (formatted != value) {
                      _amountController.value = TextEditingValue(
                        text: formatted,
                        selection: TextSelection.collapsed(
                          offset: formatted.length,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Day of Month
                Text(
                  '매월 실행 날짜',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _dayController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: '1~31',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Category
                Text(
                  '카테고리',
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
                  '메모',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _memoController,
                  decoration: InputDecoration(
                    hintText: '예: 월세',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Active Switch
                SwitchListTile(
                  title: const Text('활성화'),
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
                        child: const Text('취소'),
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
                        child: Text(widget.recurring != null ? '수정' : '추가'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
