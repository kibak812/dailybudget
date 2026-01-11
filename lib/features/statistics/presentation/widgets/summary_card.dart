import 'package:flutter/material.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/app/theme/app_colors.dart';

/// Summary card widget for statistics page
/// Displays a statistic with icon, label, and amount
class SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final int amount;
  final Color? amountColor;

  const SummaryCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.amount,
    this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon with colored background
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 12),
            // Label and amount
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    Formatters.formatCurrency(amount, context),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: amountColor ?? AppColors.textPrimary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
