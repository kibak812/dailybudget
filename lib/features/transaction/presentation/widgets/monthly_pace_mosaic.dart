import 'package:flutter/material.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;
        final screenHeight = MediaQuery.of(context).size.height;

        // Calculate number of weeks needed for this month's calendar
        final firstDayDate = DateTime.parse(data.days.first.date);
        final firstWeekday = firstDayDate.weekday % 7; // 0=Sun, 1=Mon, ..., 6=Sat
        final totalCells = firstWeekday + data.days.length;
        final numRows = (totalCells / 7).ceil(); // 4, 5, or 6 rows

        // Calculate responsive height based on available space
        final cellSize = (availableWidth - 32 - (6 * 4)) / 7; // Account for padding and spacing
        final headerHeight = 24.0; // Approximate height of weekday headers
        final spacingHeight = 12.0; // SizedBox between header and grid
        final gridSpacing = 8.0 * (numRows - 1); // mainAxisSpacing between rows

        final calculatedHeight = 16.0 + // Top padding
                                headerHeight +
                                spacingHeight +
                                (cellSize * numRows) +
                                gridSpacing +
                                16.0; // Bottom padding

        // Constrain height: min 280px, max 50% of screen
        // For wide layout (split panel with finite height), fit within available space
        final constrainedHeight = availableHeight.isFinite
            ? calculatedHeight.clamp(280.0, availableHeight)
            : calculatedHeight.clamp(280.0, screenHeight * 0.5);

        return Container(
          height: constrainedHeight,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Week day headers (Sun-Sat)
              _buildWeekdayHeaders(context, theme),
              const SizedBox(height: 12),

              // Calendar grid
              Expanded(
                child: _buildCalendarGrid(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeekdayHeaders(BuildContext context, ThemeData theme) {
    final weekdays = [
      context.l10n.weekday_short_sun,
      context.l10n.weekday_short_mon,
      context.l10n.weekday_short_tue,
      context.l10n.weekday_short_wed,
      context.l10n.weekday_short_thu,
      context.l10n.weekday_short_fri,
      context.l10n.weekday_short_sat,
    ];

    return Row(
      children: weekdays.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final isSunday = index == 0;
        final isSaturday = index == 6;

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
      clipBehavior: Clip.hardEdge,
      children: gridItems,
    );
  }

  Widget _buildDayTile(BuildContext context, DayData dayData) {
    final theme = Theme.of(context);
    final isSelected = selectedDate == dayData.date;

    // Today: same as future (gray background) with border (pending settlement)
    // Other days: use status-based colors
    final backgroundColor = MosaicColors.getBackgroundColor(dayData.status);
    final textColor = dayData.isToday
        ? theme.colorScheme.primary
        : MosaicColors.getTextColor(dayData.status);

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
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                width: isSelected ? 2.5 : dayData.isToday ? 2.0 : 0,
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
