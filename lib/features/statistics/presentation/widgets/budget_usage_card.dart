import 'package:flutter/material.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/app/theme/app_colors.dart';

/// Budget usage card widget
/// Shows budget usage with progress bar
class BudgetUsageCard extends StatefulWidget {
  final int totalBudget;
  final int totalSpent;

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
    final percent = widget.totalBudget > 0
        ? (widget.totalSpent / widget.totalBudget).clamp(0.0, 1.0)
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
    final budgetUsagePercent = widget.totalBudget > 0
        ? (widget.totalSpent / widget.totalBudget) * 100
        : 0.0;

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
                  '사용: ${Formatters.formatCurrency(widget.totalSpent)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
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
