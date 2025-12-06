import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/core/utils/formatters.dart';
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

  // Breakpoint for wide layout (Galaxy Fold inner display)
  static const double _wideBreakpoint = 600.0;

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

  Widget _buildSummaryCards(
    int monthlyBudget,
    int totalSpent,
    int totalIncome,
    int netSpending,
    int remaining,
  ) {
    // Determine if net is spending or income
    final isNetIncome = netSpending < 0;
    final netLabel = isNetIncome ? '순수입' : '순지출';
    final netAmount = isNetIncome ? -netSpending : netSpending;

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
          icon: Icons.swap_vert,
          iconColor: AppColors.warning,
          label: netLabel,
          amount: netAmount,
          amountColor: isNetIncome ? AppColors.success : AppColors.danger,
        ),
        const SizedBox(height: 12),
        SummaryCard(
          icon: Icons.trending_up,
          iconColor: AppColors.success,
          label: '남은 예산',
          amount: remaining,
          amountColor: remaining >= 0 ? AppColors.success : AppColors.danger,
        ),
        const SizedBox(height: 12),
        _buildDetailedBreakdown(totalSpent, totalIncome),
      ],
    );
  }

  Widget _buildDetailedBreakdown(int totalSpent, int totalIncome) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.danger.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.remove_circle_outline,
                        size: 16,
                        color: AppColors.danger,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '총 지출',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  Formatters.formatCurrency(totalSpent),
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.add_circle_outline,
                        size: 16,
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '총 수입',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Text(
                  Formatters.formatCurrency(totalIncome),
                  style: TextStyle(
                    color: AppColors.success,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= _wideBreakpoint;

          if (isWide) {
            return _buildWideLayout(
              context,
              ref,
              budget,
              budgetData,
              categoryData,
              currentMonth,
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
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
                    budgetData.totalIncome,
                    budgetData.totalSpent - budgetData.totalIncome,
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
                  _buildCategorySection(context, categoryData, budgetData, currentMonth),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// Wide layout for foldable devices (2-column split)
  Widget _buildWideLayout(
    BuildContext context,
    WidgetRef ref,
    dynamic budget,
    dynamic budgetData,
    List<CategorySpending> categoryData,
    CurrentMonth currentMonth,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left panel: Summary cards + Budget usage
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(transactionProvider);
              ref.invalidate(budgetProvider);
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildSummaryCards(
                    budget.amount,
                    budgetData.totalSpent,
                    budgetData.totalIncome,
                    budgetData.totalSpent - budgetData.totalIncome,
                    budgetData.totalRemaining,
                  ),
                  const SizedBox(height: 16),
                  BudgetUsageCard(
                    totalBudget: budget.amount,
                    totalSpent: budgetData.totalSpent,
                  ),
                ],
              ),
            ),
          ),
        ),
        // Vertical divider
        const VerticalDivider(width: 1, thickness: 1),
        // Right panel: Category chart
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: _buildCategorySection(context, categoryData, budgetData, currentMonth),
          ),
        ),
      ],
    );
  }

  /// Category section widget (reusable for both layouts)
  Widget _buildCategorySection(
    BuildContext context,
    List<CategorySpending> categoryData,
    dynamic budgetData,
    CurrentMonth currentMonth,
  ) {
    if (categoryData.isNotEmpty) {
      return CategoryChartCardSyncfusion(
        categoryData: categoryData,
        totalSpent: budgetData.totalSpent,
        year: currentMonth.year,
        month: currentMonth.month,
      );
    }

    return Card(
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
    );
  }
}
