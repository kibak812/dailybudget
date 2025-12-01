import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';

/// Quick expense input form
/// Allows users to quickly add expenses
class QuickAddCard extends ConsumerStatefulWidget {
  const QuickAddCard({super.key});

  @override
  ConsumerState<QuickAddCard> createState() => _QuickAddCardState();
}

class _QuickAddCardState extends ConsumerState<QuickAddCard> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _memoController = TextEditingController();
  String? _selectedCategory;

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  void _handleAmountChange(String value) {
    final formatted = Formatters.formatNumberInput(value);
    if (formatted != _amountController.text) {
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final amount = Formatters.parseFormattedNumber(_amountController.text);
    if (amount <= 0) {
      _showMessage('올바른 금액을 입력해주세요.', isError: true);
      return;
    }

    final categories = ref.read(categoriesProvider);
    final category = _selectedCategory ?? (categories.isNotEmpty ? categories.first : null);

    // Create transaction
    final transaction = TransactionModel.create(
      type: TransactionType.expense,
      amount: amount,
      date: Formatters.formatDateISO(DateTime.now()),
      category: category,
      memo: _memoController.text.trim().isEmpty ? null : _memoController.text.trim(),
    );

    // Add transaction
    await ref.read(transactionProvider.notifier).addTransaction(transaction);

    // Show success message
    if (mounted) {
      _showMessage('지출 ${Formatters.formatCurrency(amount)} 기록 완료');

      // Reset form
      _amountController.clear();
      _memoController.clear();
      setState(() {
        _selectedCategory = null;
      });
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red[700] : Colors.green[700],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '빠른 지출 입력',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Amount Input
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '금액',
                  hintText: '0',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: _handleAmountChange,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '금액을 입력해주세요';
                  }
                  final amount = Formatters.parseFormattedNumber(value);
                  if (amount <= 0) {
                    return '올바른 금액을 입력해주세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  labelText: '카테고리',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
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
                    _selectedCategory = value;
                  });
                },
                hint: Text(categories.isNotEmpty ? categories.first : '카테고리 선택'),
              ),
              const SizedBox(height: 12),
              // Memo Input
              TextField(
                controller: _memoController,
                decoration: InputDecoration(
                  labelText: '메모 (선택)',
                  hintText: '간단한 메모를 입력하세요',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '저장',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
