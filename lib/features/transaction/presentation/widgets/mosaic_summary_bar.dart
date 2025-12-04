import 'package:flutter/material.dart';
import 'package:daily_pace/features/transaction/domain/models/monthly_mosaic_data.dart';
import 'package:daily_pace/core/utils/formatters.dart';

/// Summary bar showing mosaic statistics or selected date info
class MosaicSummaryBar extends StatelessWidget {
  final MonthlyMosaicSummary summary;
  final String? selectedDate;
  final int? selectedDateNetSpent;
  final VoidCallback? onReset;

  const MosaicSummaryBar({
    super.key,
    required this.summary,
    this.selectedDate,
    this.selectedDateNetSpent,
    this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: selectedDate != null
          ? _buildSelectedDateInfo(context)
          : _buildMonthlySummary(context),
    );
  }

  Widget _buildMonthlySummary(BuildContext context) {
    final theme = Theme.of(context);

    if (!summary.hasBudget) {
      return Text(
        '이번 달 예산이 설정되지 않았습니다.',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Text(
      '이번 달: 퍼펙트 ${summary.perfect}일, 과소비 ${summary.overspent}일',
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSelectedDateInfo(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateTime.parse(selectedDate!);
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    final weekday = weekdays[date.weekday % 7];

    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: '${date.month}월 ${date.day}일 ($weekday)',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (selectedDateNetSpent != null) ...[
                  const TextSpan(text: ' • '),
                  TextSpan(
                    text: '순지출 ${Formatters.formatCurrency(selectedDateNetSpent!)}',
                    style: TextStyle(
                      color: selectedDateNetSpent! > 0
                          ? theme.colorScheme.error
                          : theme.colorScheme.tertiary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close),
          tooltip: '전체 보기',
          onPressed: onReset,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
