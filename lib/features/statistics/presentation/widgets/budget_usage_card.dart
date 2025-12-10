import 'package:flutter/material.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/app/theme/app_colors.dart';

/// Budget usage card widget
/// Shows budget usage with progress bar (based on net spending)
class BudgetUsageCard extends StatefulWidget {
  final int totalBudget;
  final int totalSpent; // Net spending (can be negative if income > expenses)

  const BudgetUsageCard({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
  });

  @override
  State<BudgetUsageCard> createState() => _BudgetUsageCardState();
}

class _BudgetUsageCardState extends State<BudgetUsageCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _updateAnimation();
    _animationController.forward();
  }

  @override
  void didUpdateWidget(BudgetUsageCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalBudget != widget.totalBudget ||
        oldWidget.totalSpent != widget.totalSpent) {
      _updateAnimation();
      _animationController.forward(from: 0);
    }
  }

  void _updateAnimation() {
    // For negative net spending (income > expenses), progress is 0
    final effectiveSpent = widget.totalSpent < 0 ? 0 : widget.totalSpent;
    final percent = widget.totalBudget > 0
        ? (effectiveSpent / widget.totalBudget).clamp(0.0, 1.0)
        : 0.0;

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: percent,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Color _getProgressColor(double percent) {
    if (percent > 1.0) {
      return AppColors.danger;
    } else if (percent >= 0.8) {
      return AppColors.warning;
    } else {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNetIncome = widget.totalSpent < 0;
    final effectiveSpent = isNetIncome ? 0 : widget.totalSpent;
    final budgetUsagePercent = widget.totalBudget > 0
        ? (effectiveSpent / widget.totalBudget) * 100
        : 0.0;

    // Display label and value based on net spending/income
    final displayLabel = isNetIncome ? '순수입' : '순지출';
    final displayAmount = isNetIncome
        ? '+${Formatters.formatCurrency(widget.totalSpent.abs())}'
        : Formatters.formatCurrency(widget.totalSpent);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              '예산 사용률',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),

            // Usage info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$displayLabel: $displayAmount',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isNetIncome ? AppColors.success : AppColors.textSecondary,
                      ),
                ),
                Text(
                  '${budgetUsagePercent.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Animated progress bar
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                final progress = _progressAnimation.value;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 16,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getProgressColor(progress),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
