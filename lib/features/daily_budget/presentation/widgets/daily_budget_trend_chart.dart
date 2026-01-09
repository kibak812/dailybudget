import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/features/daily_budget/domain/models/daily_budget_data.dart';
import 'package:daily_pace/app/theme/app_colors.dart';

/// Tooltip data class for type safety
class _TooltipData {
  final String dateLabel;
  final int budget;
  _TooltipData(this.dateLabel, this.budget);
}

/// Daily budget trend chart widget (Syncfusion version)
/// Shows line chart of daily budget changes from day 1 to current day
class DailyBudgetTrendChartSyncfusion extends ConsumerStatefulWidget {
  const DailyBudgetTrendChartSyncfusion({super.key});

  @override
  ConsumerState<DailyBudgetTrendChartSyncfusion> createState() => _DailyBudgetTrendChartSyncfusionState();
}

class _DailyBudgetTrendChartSyncfusionState extends ConsumerState<DailyBudgetTrendChartSyncfusion> {
  ChartPeriod _selectedPeriod = ChartPeriod.week;

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(dailyBudgetHistoryProvider(_selectedPeriod));
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
            const SizedBox(height: 16),

            // Period selector
            Center(
              child: SegmentedButton<ChartPeriod>(
                segments: const [
                  ButtonSegment(
                    value: ChartPeriod.week,
                    label: Text('1주'),
                  ),
                  ButtonSegment(
                    value: ChartPeriod.twoWeeks,
                    label: Text('2주'),
                  ),
                  ButtonSegment(
                    value: ChartPeriod.month,
                    label: Text('1달'),
                  ),
                ],
                selected: {_selectedPeriod},
                onSelectionChanged: (Set<ChartPeriod> newSelection) {
                  setState(() {
                    _selectedPeriod = newSelection.first;
                  });
                },
              ),
            ),
            const SizedBox(height: 20),

            // Chart
            SizedBox(
              height: 200,
              child: _buildSyncfusionChart(history, theme),
            ),
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
                color: AppColors.textTertiary,
              ),
              const SizedBox(height: 12),
              Text(
                '예산 데이터가 없습니다',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncfusionChart(List<DailyBudgetHistoryItem> history, ThemeData theme) {
    // Find min and max values for Y axis
    final budgetValues = history.map((item) => item.dailyBudget).toList();
    final minBudget = budgetValues.reduce((a, b) => a < b ? a : b);
    final maxBudget = budgetValues.reduce((a, b) => a > b ? a : b);

    // Calculate Y axis range with padding
    final double yMin;
    final double yMax;

    if (minBudget >= 0 && maxBudget >= 0) {
      // All positive - tight zoom for maximum visual impact
      yMin = (minBudget * 0.9).floorToDouble();
      yMax = (maxBudget * 1.1).ceilToDouble();
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

    // Pre-extract tooltip data to avoid type inference issues in callback
    final tooltipData = history.map((item) => _TooltipData(item.dateLabel, item.dailyBudget)).toList();

    // Create a map from dayIndex to dateLabel for X-axis formatting
    final dateLabelMap = {for (var item in history) item.dayIndex: item.dateLabel};

    return SfCartesianChart(
      // Use trackball for better touch interaction
      trackballBehavior: TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
        lineType: TrackballLineType.vertical,
        lineColor: theme.colorScheme.primary.withOpacity(0.3),
        lineWidth: 2,
        tooltipSettings: InteractiveTooltip(
          enable: true,
          color: theme.colorScheme.inverseSurface,
          textStyle: TextStyle(
            color: theme.colorScheme.onInverseSurface,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          borderColor: Colors.transparent,
          format: 'point.x일\npoint.y',
        ),
      ),

      // CRITICAL: Format trackball tooltip with Korean currency
      onTrackballPositionChanging: (TrackballArgs args) {
        final pointInfo = args.chartPointInfo;
        final dataIndex = pointInfo.dataPointIndex;
        if (dataIndex != null && dataIndex < tooltipData.length) {
          final idx = dataIndex.toInt();
          final data = tooltipData[idx];
          final dateLabel = data.dateLabel;
          final budget = data.budget.toInt();
          pointInfo.label = '$dateLabel\n${Formatters.formatCurrency(budget)}';
        }
      },

      // CRITICAL: Custom marker colors based on value
      onMarkerRender: (MarkerRenderArgs args) {
        final index = args.pointIndex;
        if (index != null && index < history.length) {
          final value = history[index].dailyBudget;
          if (value > 0) {
            args.color = Colors.green;
          } else if (value < 0) {
            args.color = Colors.red;
          } else {
            args.color = AppColors.textTertiary;
          }
        }
      },

      primaryXAxis: NumericAxis(
        minimum: history.first.dayIndex.toDouble(),
        maximum: history.last.dayIndex.toDouble(),
        interval: _calculateXInterval(history.length),

        axisLabelFormatter: (AxisLabelRenderDetails args) {
          final dayIndex = args.value.toInt();
          // Skip min and max labels to match fl_chart behavior
          if (dayIndex == history.first.dayIndex ||
              dayIndex == history.last.dayIndex) {
            return ChartAxisLabel('', const TextStyle());
          }
          // Use dateLabel from map, fallback to dayIndex if not found
          final label = dateLabelMap[dayIndex] ?? '$dayIndex';
          return ChartAxisLabel(
            label,
            TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          );
        },

        axisLine: AxisLine(
          color: AppColors.border,
          width: 1,
        ),
        majorTickLines: const MajorTickLines(width: 0),
        majorGridLines: const MajorGridLines(width: 0),
      ),

      primaryYAxis: NumericAxis(
        minimum: yMin,
        maximum: yMax,
        interval: (yMax - yMin) / 4,

        // CRITICAL: Korean formatting
        axisLabelFormatter: (AxisLabelRenderDetails args) {
          return ChartAxisLabel(
            _formatYAxisValue(args.value.toInt()),
            TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          );
        },

        axisLine: AxisLine(
          color: AppColors.border,
          width: 1,
        ),
        majorTickLines: const MajorTickLines(width: 0),
        majorGridLines: MajorGridLines(
          width: 1,
          color: AppColors.border,
        ),
      ),

      series: <CartesianSeries<DailyBudgetHistoryItem, int>>[
        SplineAreaSeries<DailyBudgetHistoryItem, int>(
          dataSource: history,
          xValueMapper: (DailyBudgetHistoryItem item, _) => item.dayIndex,
          yValueMapper: (DailyBudgetHistoryItem item, _) => item.dailyBudget,

          borderColor: theme.colorScheme.primary,
          borderWidth: 3,

          // CRITICAL: Smooth curves
          splineType: SplineType.natural,

          // CRITICAL: Gradient fill
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.3),
              theme.colorScheme.primary.withOpacity(0.05),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),

          // CRITICAL: Color-coded markers (colors set via onMarkerRender)
          markerSettings: MarkerSettings(
            isVisible: true,
            height: 6,
            width: 6,
            shape: DataMarkerType.circle,
            borderWidth: 2,
            borderColor: Colors.white,
          ),

          enableTooltip: true,
        ),
      ],
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
