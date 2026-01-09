import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/features/budget/presentation/providers/current_month_provider.dart';
import 'package:daily_pace/features/settings/presentation/providers/budget_start_day_provider.dart';
import 'package:daily_pace/core/utils/date_range_extension.dart';

/// Month navigation bar for switching between months
class MonthNavigationBar extends ConsumerWidget {
  const MonthNavigationBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentMonth = ref.watch(currentMonthProvider);
    final startDay = ref.watch(budgetStartDayProvider);
    final (periodStart, periodEnd) = currentMonth.getDateRange(startDay);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => _navigateToPreviousMonth(ref, currentMonth),
            tooltip: '이전 달',
          ),
          Text(
            startDay == 1
                ? '${currentMonth.year}년 ${currentMonth.month}월'
                : '${periodStart.year}.${periodStart.month}.${periodStart.day} ~ ${periodEnd.month}.${periodEnd.day}',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => _navigateToNextMonth(ref, currentMonth),
            tooltip: '다음 달',
          ),
        ],
      ),
    );
  }

  void _navigateToPreviousMonth(WidgetRef ref, CurrentMonth current) {
    final newMonth = current.month == 1 ? 12 : current.month - 1;
    final newYear = current.month == 1 ? current.year - 1 : current.year;

    ref.read(currentMonthProvider.notifier).state = CurrentMonth(
      year: newYear,
      month: newMonth,
    );
  }

  void _navigateToNextMonth(WidgetRef ref, CurrentMonth current) {
    final newMonth = current.month == 12 ? 1 : current.month + 1;
    final newYear = current.month == 12 ? current.year + 1 : current.year;

    ref.read(currentMonthProvider.notifier).state = CurrentMonth(
      year: newYear,
      month: newMonth,
    );
  }
}
