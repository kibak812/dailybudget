import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/app/theme/app_colors.dart';

class CategoryDetailPage extends ConsumerWidget {
  final String categoryName;
  final Color categoryColor;
  final int year;
  final int month;

  const CategoryDetailPage({
    super.key,
    required this.categoryName,
    required this.categoryColor,
    required this.year,
    required this.month,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allTransactions = ref.watch(transactionProvider);

    // Filter transactions for this category and month
    final categoryTransactions = allTransactions.where((t) {
      final matchesMonth = t.year == year && t.month == month;
      final matchesCategory = (t.category ?? context.l10n.category_other) == categoryName;
      final isExpense = t.type == TransactionType.expense;
      return matchesMonth && matchesCategory && isExpense;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Sort by date descending

    // Calculate total for this category
    final totalAmount = categoryTransactions.fold<int>(
      0,
      (sum, t) => sum + t.amount,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.statistics_categoryDetail(categoryName)),
        backgroundColor: categoryColor.withOpacity(0.1),
      ),
      body: Column(
        children: [
          // Summary card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: categoryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      Formatters.formatYearMonthDisplay(year, month, context),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  context.l10n.statistics_totalExpense,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatCurrency(totalAmount, context),
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: categoryColor,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.statistics_transactionCount(categoryTransactions.length),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),

          // Transaction list
          Expanded(
            child: categoryTransactions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          context.l10n.statistics_categoryNoTransactions,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categoryTransactions.length,
                    itemBuilder: (context, index) {
                      final transaction = categoryTransactions[index];
                      return _buildTransactionItem(
                        context,
                        transaction,
                        categoryColor,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    BuildContext context,
    TransactionModel transaction,
    Color categoryColor,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.receipt,
            color: categoryColor,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                transaction.memo?.isNotEmpty == true
                    ? transaction.memo!
                    : categoryName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
            Text(
              Formatters.formatCurrency(transaction.amount, context),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: categoryColor,
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Builder(
            builder: (ctx) => Text(
              _formatDate(ctx, transaction.date),
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(BuildContext context, String dateStr) {
    // Format: "YYYY-MM-DD" -> locale-aware date with weekday
    final parts = dateStr.split('-');
    if (parts.length != 3) return dateStr;

    final year = int.parse(parts[0]);
    final month = int.parse(parts[1]);
    final day = int.parse(parts[2]);

    final date = DateTime(year, month, day);
    final weekdays = [
      context.l10n.weekday_mon,
      context.l10n.weekday_tue,
      context.l10n.weekday_wed,
      context.l10n.weekday_thu,
      context.l10n.weekday_fri,
      context.l10n.weekday_sat,
      context.l10n.weekday_sun,
    ];
    final weekday = weekdays[date.weekday - 1];

    // Use locale-aware date formatting
    final dateFormatted = Formatters.formatDateWithoutYear(date, context);
    return '$dateFormatted ($weekday)';
  }
}
