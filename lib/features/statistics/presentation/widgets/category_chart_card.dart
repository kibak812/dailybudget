import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:go_router/go_router.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/app/theme/app_colors.dart';

/// Category spending data class
class CategorySpending {
  final String name;
  final int amount;

  CategorySpending({required this.name, required this.amount});
}

/// Category chart card widget (Syncfusion version)
/// Shows pie chart with connector lines and enhanced labels
class CategoryChartCardSyncfusion extends StatefulWidget {
  final List<CategorySpending> categoryData;
  final int totalSpent;
  final int year;
  final int month;

  const CategoryChartCardSyncfusion({
    super.key,
    required this.categoryData,
    required this.totalSpent,
    required this.year,
    required this.month,
  });

  @override
  State<CategoryChartCardSyncfusion> createState() =>
      _CategoryChartCardSyncfusionState();
}

class _CategoryChartCardSyncfusionState
    extends State<CategoryChartCardSyncfusion> {
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
                height: 520,
                child: SfCircularChart(
                    legend: Legend(isVisible: false),
                    series: <CircularSeries>[
                      DoughnutSeries<CategorySpending, String>(
                        dataSource: widget.categoryData,
                        xValueMapper: (data, _) => data.name,
                        yValueMapper: (data, _) => data.amount.toDouble(),
                        pointColorMapper: (data, index) =>
                            _getColorForIndex(index),
                        strokeWidth: 2,
                        strokeColor: Colors.white,

                        // CRITICAL: Category name + percentage
                        dataLabelMapper: (data, index) {
                          final percent = widget.totalSpent > 0
                              ? (data.amount / widget.totalSpent) * 100
                              : 0.0;
                          return '${data.name}(${percent.toStringAsFixed(1)}%)';
                        },

                        // CRITICAL: Connector lines and enhanced labels
                        dataLabelSettings: DataLabelSettings(
                          isVisible: true,
                          labelPosition: ChartDataLabelPosition.outside,
                          textStyle: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          connectorLineSettings: const ConnectorLineSettings(
                            type: ConnectorType.line,
                            length: '20%',
                            width: 1.5,
                            color: Colors.black38,
                          ),
                          labelIntersectAction: LabelIntersectAction.shift,
                        ),

                        radius: '100',
                        innerRadius: '60%',
                      ),
                    ],
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

                return InkWell(
                  onTap: () {
                    // Navigate to category detail page
                    context.push('/statistics/category-detail', extra: {
                      'categoryName': category.name,
                      'categoryColor': _getColorForIndex(index),
                      'year': widget.year,
                      'month': widget.month,
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
                        const SizedBox(width: 8),

                        // Chevron icon to indicate tappability
                        Icon(
                          Icons.chevron_right,
                          size: 20,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}
