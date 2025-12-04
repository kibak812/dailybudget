import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/app/theme/app_colors.dart';

/// Category spending data class
class CategorySpending {
  final String name;
  final int amount;

  CategorySpending({required this.name, required this.amount});
}

/// Category chart card widget
/// Shows pie chart and list of category spending
class CategoryChartCard extends StatefulWidget {
  final List<CategorySpending> categoryData;
  final int totalSpent;

  const CategoryChartCard({
    super.key,
    required this.categoryData,
    required this.totalSpent,
  });

  @override
  State<CategoryChartCard> createState() => _CategoryChartCardState();
}

class _CategoryChartCardState extends State<CategoryChartCard> {
  int _touchedIndex = -1;

  // Category colors matching the web app
  static const List<Color> categoryColors = [
    Color(0xFF4F46E5), // Indigo
    Color(0xFF10B981), // Emerald
    Color(0xFFF43F5E), // Rose
    Color(0xFFF59E0B), // Amber
    Color(0xFF8B5CF6), // Violet
    Color(0xFF06B6D4), // Cyan
    Color(0xFFEC4899), // Pink
    Color(0xFF6366F1), // Light Indigo
    Color(0xFF34D399), // Light Emerald
    Color(0xFFFB7185), // Light Rose
  ];

  Color _getColorForIndex(int index) {
    return categoryColors[index % categoryColors.length];
  }

  List<PieChartSectionData> _buildPieChartSections() {
    return widget.categoryData.asMap().entries.map((entry) {
      final index = entry.key;
      final category = entry.value;
      final isTouched = index == _touchedIndex;
      final fontSize = isTouched ? 16.0 : 14.0;
      final radius = isTouched ? 130.0 : 120.0;
      final percent = widget.totalSpent > 0
          ? (category.amount / widget.totalSpent) * 100
          : 0.0;

      return PieChartSectionData(
        color: _getColorForIndex(index),
        value: category.amount.toDouble(),
        title: '${percent.toStringAsFixed(0)}%',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              '카테고리별 지출',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 24),

            // Pie chart
            if (widget.categoryData.isNotEmpty)
              SizedBox(
                height: 480,
                child: PieChart(
                  PieChartData(
                    sections: _buildPieChartSections(),
                    centerSpaceRadius: 0,
                    sectionsSpace: 2,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse
                              .touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // Category list
            if (widget.categoryData.isNotEmpty)
              ...widget.categoryData.asMap().entries.map((entry) {
                final index = entry.key;
                final category = entry.value;
                final percent = widget.totalSpent > 0
                    ? (category.amount / widget.totalSpent) * 100
                    : 0.0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      // Color indicator
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _getColorForIndex(index),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Category name
                      Expanded(
                        child: Text(
                          category.name,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),

                      // Amount and percentage
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.formatCurrency(category.amount),
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          Text(
                            '${percent.toStringAsFixed(1)}%',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
