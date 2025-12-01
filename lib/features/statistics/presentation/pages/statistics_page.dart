import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/features/budget/presentation/providers/current_month_provider.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/statistics/presentation/widgets/summary_card.dart';
import 'package:daily_pace/features/statistics/presentation/widgets/budget_usage_card.dart';
import 'package:daily_pace/features/statistics/presentation/widgets/category_chart_card.dart';
import 'package:daily_pace/app/theme/app_colors.dart';

/// Statistics page
/// Displays spending analytics, charts, and insights
class StatisticsPage extends ConsumerWidget {
  const StatisticsPage({super.key});

  /// Filter transactions by current month
  List<TransactionModel> _filterByMonth(
    List<TransactionModel> transactions,
    CurrentMonth currentMonth,
  ) {
    final monthPrefix =
        '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}';
    return transactions.where((t) => t.date.startsWith(monthPrefix)).toList();
  }

  /// Calculate category spending data
  List<CategorySpending> _calculateCategoryData(
      List<TransactionModel> transactions) {
    final Map<String, int> categoryMap = {};

    for (final t
        in transactions.where((t) => t.type == TransactionType.expense)) {
      final category = t.category ?? '기타';
      categoryMap[category] = (categoryMap[category] ?? 0) + t.amount;
    }

    return categoryMap.entries
        .map((e) => CategorySpending(name: e.key, amount: e.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
  }

  Widget _buildEmptyState(BuildContext context, String message,
      {VoidCallback? onAction, String? actionLabel}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pie_chart_outline,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(int monthlyBudget, int totalSpent, int remaining) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use column layout for narrow screens, row for wider screens
        final useColumnLayout = constraints.maxWidth < 600;

        if (useColumnLayout) {
          return Column(
            children: [
              SummaryCard(
                icon: Icons.attach_money,
                iconColor: AppColors.primary,
                label: '이번 달 예산',
                amount: monthlyBudget,
              ),
              const SizedBox(height: 12),
              SummaryCard(
                icon: Icons.trending_down,
                iconColor: AppColors.danger,
                label: '총 지출',
                amount: totalSpent,
                amountColor: AppColors.danger,
              ),
              const SizedBox(height: 12),
              SummaryCard(
                icon: Icons.trending_up,
                iconColor: AppColors.success,
                label: '남은 예산',
                amount: remaining,
                amountColor: AppColors.success,
              ),
            ],
          );
        } else {
          return Row(
            children: [
              Expanded(
                child: SummaryCard(
                  icon: Icons.attach_money,
                  iconColor: AppColors.primary,
                  label: '이번 달 예산',
                  amount: monthlyBudget,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  icon: Icons.trending_down,
                  iconColor: AppColors.danger,
                  label: '총 지출',
                  amount: totalSpent,
                  amountColor: AppColors.danger,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SummaryCard(
                  icon: Icons.trending_up,
                  iconColor: AppColors.success,
                  label: '남은 예산',
                  amount: remaining,
                  amountColor: AppColors.success,
                ),
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentMonth = ref.watch(currentMonthProvider);
    final transactions = ref.watch(transactionProvider);
    final budgets = ref.watch(budgetProvider);
    final budgetData = ref.watch(dailyBudgetProvider);

    // Get budget for current month
    final budget = budgets
        .where((b) =>
            b.year == currentMonth.year && b.month == currentMonth.month)
        .firstOrNull;

    // If no budget, show empty state
    if (budget == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('통계'),
        ),
        body: _buildEmptyState(
          context,
          '예산을 먼저 설정해주세요.',
        ),
      );
    }

    // Filter transactions for current month
    final monthTransactions = _filterByMonth(transactions, currentMonth);

    // Calculate category data
    final categoryData = _calculateCategoryData(monthTransactions);

    return Scaffold(
      appBar: AppBar(
        title: const Text('통계'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Refresh providers
          ref.invalidate(transactionProvider);
          ref.invalidate(budgetProvider);
          await Future.delayed(const Duration(milliseconds: 500));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Summary cards
              _buildSummaryCards(
                budget.amount,
                budgetData.totalSpent,
                budgetData.totalRemaining,
              ),
              const SizedBox(height: 16),

              // Budget usage bar
              BudgetUsageCard(
                totalBudget: budget.amount,
                totalSpent: budgetData.totalSpent,
              ),
              const SizedBox(height: 16),

              // Category pie chart
              if (categoryData.isNotEmpty)
                CategoryChartCard(
                  categoryData: categoryData,
                  totalSpent: budgetData.totalSpent,
                )
              else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.pie_chart_outline,
                            size: 48,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '아직 거래 내역이 없습니다',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        ],
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
