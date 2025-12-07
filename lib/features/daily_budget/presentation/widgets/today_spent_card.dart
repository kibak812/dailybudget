import 'package:flutter/material.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/features/daily_budget/domain/models/daily_budget_data.dart';
import 'package:daily_pace/app/theme/app_colors.dart';

/// Today's spent and remaining budget card
/// Shows two-column layout with spent and remaining amounts
class TodaySpentCard extends StatelessWidget {
  final DailyBudgetData budgetData;

  const TodaySpentCard({
    super.key,
    required this.budgetData,
  });

  @override
  Widget build(BuildContext context) {
    final isOverBudget = budgetData.remainingToday < 0;

    return Row(
      children: [
        // Spent Today
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘 지출',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.formatCurrency(budgetData.spentToday),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Remaining Today or Over Budget
        Expanded(
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isOverBudget ? '오늘 예산 초과' : '오늘 남은 예산',
                    style: TextStyle(
                      color: isOverBudget ? Colors.red[700] : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.formatCurrency(budgetData.remainingToday.abs()),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isOverBudget ? Colors.red[700] : Colors.green[700],
                    ),
                  ),
                  if (isOverBudget) ...[
                    const SizedBox(height: 4),
                    Text(
                      '내일부터 일별 예산이 줄어듭니다',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
