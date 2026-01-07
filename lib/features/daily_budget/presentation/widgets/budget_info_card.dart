import 'package:flutter/material.dart';
import 'package:daily_pace/app/theme/app_colors.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/features/daily_budget/domain/models/daily_budget_data.dart';

/// Budget information card
/// Shows monthly budget overview with stacked bar visualization
class BudgetInfoCard extends StatelessWidget {
  final DailyBudgetData budgetData;

  const BudgetInfoCard({
    super.key,
    required this.budgetData,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate values
    final netSpent = budgetData.totalSpent - budgetData.totalIncome;
    final monthlyBudget = budgetData.totalRemaining + netSpent;
    final remaining = budgetData.totalRemaining;
    final remainingDays = budgetData.remainingDays;

    // Calculate ratio for the bar (handle edge cases)
    double spentRatio = 0.0;
    if (monthlyBudget > 0) {
      spentRatio = (netSpent / monthlyBudget).clamp(0.0, 1.0);
    }

    // Determine if net spent is negative (income > expenses)
    final isNetIncome = netSpent < 0;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: title and remaining days
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '이달 예산',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '$remainingDays일 남음',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Stacked bar
            _buildStackedBar(spentRatio, isNetIncome),
            const SizedBox(height: 10),

            // Labels below the bar
            _buildLabels(netSpent, remaining, isNetIncome),
            const SizedBox(height: 12),

            // Total budget at bottom
            Center(
              child: Text(
                '예산 ${Formatters.formatCurrency(monthlyBudget)}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStackedBar(double spentRatio, bool isNetIncome) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        color: AppColors.primaryLight.withOpacity(0.2),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Row(
          children: [
            // Spent portion (or income portion if negative)
            if (spentRatio > 0)
              Flexible(
                flex: (spentRatio * 100).round(),
                child: Container(
                  decoration: BoxDecoration(
                    color: isNetIncome
                        ? AppColors.success.withOpacity(0.7)
                        : AppColors.primary.withOpacity(0.7),
                  ),
                ),
              ),
            // Remaining portion
            if (spentRatio < 1)
              Flexible(
                flex: ((1 - spentRatio) * 100).round(),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabels(int netSpent, int remaining, bool isNetIncome) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Net spent label
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isNetIncome
                    ? AppColors.success
                    : AppColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              isNetIncome
                  ? '순수입 ${Formatters.formatCurrency(netSpent.abs())}'
                  : '순지출 ${Formatters.formatCurrency(netSpent)}',
              style: TextStyle(
                color: isNetIncome ? AppColors.success : AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        // Remaining label
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLight.withOpacity(0.4),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '남은 예산 ${Formatters.formatCurrency(remaining)}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
