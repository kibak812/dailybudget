import 'package:flutter/material.dart';
import 'package:daily_pace/features/transaction/domain/models/monthly_mosaic_data.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/mosaic_colors.dart';

/// Monthly pace mosaic widget - color-coded calendar grid
/// Shows spending status for each day of the month
class MonthlyPaceMosaic extends StatelessWidget {
  final MonthlyMosaicData data;
  final String? selectedDate;
  final Function(String date) onDateTap;

  const MonthlyPaceMosaic({
    super.key,
    required this.data,
    this.selectedDate,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 350, // Fixed height ~300-350px as per PRD
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Week day headers (Sun-Sat)
          _buildWeekdayHeaders(theme),
          const SizedBox(height: 12),

          // Calendar grid
          Expanded(
            child: _buildCalendarGrid(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders(ThemeData theme) {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];

    return Row(
      children: weekdays.map((day) {
        final isSunday = day == '일';
        final isSaturday = day == '토';

        return Expanded(
          child: Center(
            child: Text(
              day,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSunday
                    ? Colors.red[400]
                    : isSaturday
                        ? Colors.blue[400]
                        : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    // Calculate first day of month offset
    final firstDayDate = DateTime.parse(data.days.first.date);
    final firstWeekday = firstDayDate.weekday % 7; // 0=Sun, 1=Mon, ..., 6=Sat

    // Create grid items with empty cells for offset
    final List<Widget> gridItems = [];

    // Add empty cells for days before month start
    for (int i = 0; i < firstWeekday; i++) {
      gridItems.add(const SizedBox.shrink());
    }

    // Add day tiles
    for (final dayData in data.days) {
      gridItems.add(_buildDayTile(context, dayData));
    }

    return GridView.count(
      crossAxisCount: 7,
      mainAxisSpacing: 8,
      crossAxisSpacing: 4,
      physics: const NeverScrollableScrollPhysics(),
      children: gridItems,
    );
  }

  Widget _buildDayTile(BuildContext context, DayData dayData) {
    final theme = Theme.of(context);
    final isSelected = selectedDate == dayData.date;
    final backgroundColor = MosaicColors.getBackgroundColor(dayData.status);
    final textColor = MosaicColors.getTextColor(dayData.status);

    return GestureDetector(
      onTap: () => onDateTap(dayData.date),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: selectedDate != null && !isSelected ? 0.5 : 1.0,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 150),
          scale: isSelected ? 1.05 : 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : dayData.isToday
                        ? theme.colorScheme.primary.withOpacity(0.5)
                        : Colors.transparent,
                width: isSelected ? 2.5 : dayData.isToday ? 1.5 : 0,
              ),
            ),
            child: Center(
              child: Text(
                '${dayData.day}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: textColor,
                  fontWeight: isSelected || dayData.isToday
                      ? FontWeight.bold
                      : FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
