import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:go_router/go_router.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';
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

  /// 차트용 색상 (기타는 회색)
  Color _getColorForChartItem(BuildContext context, String name, int index) {
    if (name == context.l10n.category_other) {
      return const Color(0xFF9CA3AF); // Gray-400
    }
    return categoryColors[index % categoryColors.length];
  }

  /// 차트용 데이터 전처리: 정렬 + 기타 합산
  List<CategorySpending> _preprocessChartData(
      BuildContext context, List<CategorySpending> data, int total) {
    if (data.isEmpty || total <= 0) return data;

    const double threshold = 5.0; // 5% 미만은 기타로

    final List<CategorySpending> majorItems = [];
    int etcAmount = 0;

    for (final item in data) {
      final percent = (item.amount / total) * 100;
      if (percent >= threshold) {
        majorItems.add(item);
      } else {
        etcAmount += item.amount;
      }
    }

    // 내림차순 정렬
    majorItems.sort((a, b) => b.amount.compareTo(a.amount));

    // 기타 항목 추가 (있는 경우)
    if (etcAmount > 0) {
      majorItems.add(CategorySpending(name: context.l10n.category_other, amount: etcAmount));
    }

    return majorItems;
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
              context.l10n.statistics_categoryExpense,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),

            // Pie chart
            if (widget.categoryData.isNotEmpty)
              LayoutBuilder(
                builder: (context, constraints) {
                  // Use constraints for responsive sizing in split panels
                  final availableWidth = constraints.maxWidth;
                  final screenHeight = MediaQuery.of(context).size.height;

                  // Responsive calculations - use available width for split panel support
                  final chartHeight = (screenHeight * 0.28).clamp(200.0, 300.0);
                  final baseFontSize = (availableWidth * 0.028).clamp(7.5, 10.0);

                  // 차트용 전처리 데이터 (5% 미만 기타 합산, 내림차순)
                  final chartData = _preprocessChartData(
                      context, widget.categoryData, widget.totalSpent);

                  return SizedBox(
                    height: chartHeight,
                    child: SfCircularChart(
                      legend: Legend(isVisible: false),
                      series: <CircularSeries>[
                        DoughnutSeries<CategorySpending, String>(
                          dataSource: chartData,
                          xValueMapper: (data, _) => data.name,
                          yValueMapper: (data, _) => data.amount.toDouble(),
                          pointColorMapper: (data, index) =>
                              _getColorForChartItem(context, data.name, index),
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
                            textStyle: TextStyle(
                              fontSize: baseFontSize,
                              fontWeight: FontWeight.normal,
                              color: Colors.black87,
                            ),
                            connectorLineSettings: const ConnectorLineSettings(
                              type: ConnectorType.curve,
                              length: '8%',
                              width: 1.0,
                              color: Colors.black38,
                            ),
                            labelIntersectAction: LabelIntersectAction.shift,
                            overflowMode: OverflowMode.trim,
                          ),

                          radius: '70%',
                          innerRadius: '55%',
                          startAngle: 270, // 12시 방향에서 시작
                          endAngle: 630,
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 12),

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
                                      fontWeight: FontWeight.normal,
                                    ),
                          ),
                        ),

                        // Amount and percentage
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              Formatters.formatCurrency(category.amount, context),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w500,
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
                          color: AppColors.textTertiary,
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
