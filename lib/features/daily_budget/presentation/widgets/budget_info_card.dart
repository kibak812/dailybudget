import 'package:flutter/material.dart';
import 'package:daily_pace/app/theme/app_colors.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/features/daily_budget/domain/models/daily_budget_data.dart';

/// Budget information card
/// Shows remaining days and total remaining budget
class BudgetInfoCard extends StatelessWidget {
  final DailyBudgetData budgetData;

  const BudgetInfoCard({
    super.key,
    required this.budgetData,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              '남은 일수: ${budgetData.remainingDays}일',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '총 남은 예산: ${Formatters.formatCurrency(budgetData.totalRemaining)}',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
