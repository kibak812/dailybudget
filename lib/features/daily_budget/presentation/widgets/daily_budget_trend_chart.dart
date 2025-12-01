import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/core/utils/formatters.dart';

/// Daily budget trend chart widget
/// Shows line chart of daily budget changes from day 1 to current day
class DailyBudgetTrendChart extends ConsumerWidget {
  const DailyBudgetTrendChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(dailyBudgetHistoryProvider);
    final theme = Theme.of(context);

    // If no data, show empty state
    if (history.isEmpty) {
      return _buildEmptyState(context);
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Icons.show_chart,
                  color: theme.colorScheme.primary,
                  size: 22,
                ),
                const SizedBox(width: 8),
                Text(
                  '일별 예산 추이',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Chart
            SizedBox(
              height: 200,
              child: LineChart(
                _buildLineChartData(history, theme),
              ),
            ),

            const SizedBox(height: 16),

            // Legend
            _buildLegend(context),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(
                Icons.show_chart,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                '예산 데이터가 없습니다',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegend(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildLegendItem(
          context,
          color: Colors.green,
          label: '양수',
        ),
        const SizedBox(width: 24),
        _buildLegendItem(
          context,
          color: Colors.red,
          label: '음수',
        ),
        const SizedBox(width: 24),
        _buildLegendItem(
          context,
          color: Colors.grey,
          label: '0',
        ),
      ],
    );
  }

  Widget _buildLegendItem(BuildContext context, {required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
      ],
    );
  }

  LineChartData _buildLineChartData(List history, ThemeData theme) {
    // Create spots from history data
    final spots = history.map((item) {
      return FlSpot(
        item.day.toDouble(),
        item.dailyBudget.toDouble(),
      );
    }).toList();

    // Find min and max values for Y axis
    final budgetValues = history.map((item) => item.dailyBudget).toList();
    final minBudget = budgetValues.reduce((a, b) => a < b ? a : b);
    final maxBudget = budgetValues.reduce((a, b) => a > b ? a : b);

    // Calculate Y axis range with padding
    final double yMin;
    final double yMax;

    if (minBudget >= 0 && maxBudget >= 0) {
      // All positive
      yMin = 0;
      yMax = (maxBudget * 1.2).ceilToDouble();
    } else if (minBudget < 0 && maxBudget <= 0) {
      // All negative
      yMin = (minBudget * 1.2).floorToDouble();
      yMax = 0;
    } else {
      // Mixed positive and negative
      final absMax = [minBudget.abs(), maxBudget.abs()].reduce((a, b) => a > b ? a : b);
      yMin = -(absMax * 1.2);
      yMax = absMax * 1.2;
    }

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (yMax - yMin) / 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[200]!,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: _calculateXInterval(history.length),
            getTitlesWidget: (value, meta) {
              if (value == meta.min || value == meta.max) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '${value.toInt()}일',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 50,
            interval: (yMax - yMin) / 4,
            getTitlesWidget: (value, meta) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  _formatYAxisValue(value.toInt()),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.right,
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(color: Colors.grey[300]!),
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      minX: history.first.day.toDouble(),
      maxX: history.last.day.toDouble(),
      minY: yMin,
      maxY: yMax,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.3,
          color: theme.colorScheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              final value = spot.y.toInt();
              final color = value > 0
                  ? Colors.green
                  : value < 0
                      ? Colors.red
                      : Colors.grey;
              return FlDotCirclePainter(
                radius: 3,
                color: color,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                theme.colorScheme.primary.withOpacity(0.3),
                theme.colorScheme.primary.withOpacity(0.05),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        enabled: true,
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => theme.colorScheme.inverseSurface,
          tooltipRoundedRadius: 8,
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final day = spot.x.toInt();
              final budget = spot.y.toInt();
              return LineTooltipItem(
                '$day일\n${Formatters.formatCurrency(budget)}',
                TextStyle(
                  color: theme.colorScheme.onInverseSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList();
          },
        ),
        handleBuiltInTouches: true,
      ),
    );
  }

  /// Calculate appropriate X-axis interval based on data points
  double _calculateXInterval(int dataPoints) {
    if (dataPoints <= 7) return 1;
    if (dataPoints <= 14) return 2;
    if (dataPoints <= 21) return 3;
    return 5;
  }

  /// Format Y-axis values with Korean units
  String _formatYAxisValue(int value) {
    if (value == 0) return '0';

    final absValue = value.abs();
    final sign = value < 0 ? '-' : '';

    if (absValue >= 10000) {
      final man = (absValue / 10000).floor();
      final remainder = absValue % 10000;
      if (remainder == 0) {
        return '$sign$man만';
      } else {
        return '$sign$man.${(remainder / 1000).floor()}만';
      }
    } else if (absValue >= 1000) {
      return '$sign${(absValue / 1000).floor()}천';
    } else {
      return '$sign$absValue';
    }
  }
}
