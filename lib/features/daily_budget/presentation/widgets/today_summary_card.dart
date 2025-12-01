import 'package:flutter/material.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/features/daily_budget/domain/models/daily_budget_data.dart';

/// Today's budget summary card with gradient background
/// Shows daily budget, trend indicator, and difference from yesterday
class TodaySummaryCard extends StatelessWidget {
  final DailyBudgetData budgetData;

  const TodaySummaryCard({
    super.key,
    required this.budgetData,
  });

  @override
  Widget build(BuildContext context) {
    final trendInfo = _getTrendInfo();

    return Card(
      elevation: 8,
      shadowColor: Colors.indigo.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4F46E5), // Indigo-600
              Color(0xFF7C3AED), // Violet-600
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            // Abstract background shape
            Positioned(
              top: -80,
              right: -80,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '오늘 사용할 수 있는 예산',
                    style: TextStyle(
                      color: Colors.indigo[100],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    Formatters.formatCurrency(budgetData.dailyBudgetNow),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (budgetData.diff != 0) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trendInfo.icon,
                            color: trendInfo.color,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            trendInfo.text,
                            style: TextStyle(
                              color: trendInfo.color,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  _TrendInfo _getTrendInfo() {
    if (budgetData.diff > 0) {
      return _TrendInfo(
        icon: Icons.trending_up,
        text: '어제보다 ${Formatters.formatCurrency(budgetData.diff)} 늘었어요',
        color: Colors.green[300]!,
      );
    } else if (budgetData.diff < 0) {
      return _TrendInfo(
        icon: Icons.trending_down,
        text: '어제보다 ${Formatters.formatCurrency(budgetData.diff.abs())} 줄었어요',
        color: Colors.red[300]!,
      );
    } else {
      return _TrendInfo(
        icon: Icons.remove,
        text: '어제와 동일해요',
        color: Colors.indigo[200]!,
      );
    }
  }
}

class _TrendInfo {
  final IconData icon;
  final String text;
  final Color color;

  _TrendInfo({
    required this.icon,
    required this.text,
    required this.color,
  });
}

// Extension for custom colors
extension CustomColors on Colors {
  static MaterialColor? get emerald => const MaterialColor(
        0xFF10B981,
        <int, Color>{
          50: Color(0xFFECFDF5),
          100: Color(0xFFD1FAE5),
          200: Color(0xFFA7F3D0),
          300: Color(0xFF6EE7B7),
          400: Color(0xFF34D399),
          500: Color(0xFF10B981),
          600: Color(0xFF059669),
          700: Color(0xFF047857),
          800: Color(0xFF065F46),
          900: Color(0xFF064E3B),
        },
      );
}
