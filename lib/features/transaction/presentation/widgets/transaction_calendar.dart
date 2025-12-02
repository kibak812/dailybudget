import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/core/utils/formatters.dart';

/// Transaction calendar widget
/// Shows monthly calendar with daily spending amounts
class TransactionCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final List<TransactionModel> transactions;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const TransactionCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.transactions,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TableCalendar(
          firstDay: DateTime(2020, 1, 1),
          lastDay: DateTime.now().add(const Duration(days: 365)),
          focusedDay: focusedDay,
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          calendarFormat: CalendarFormat.month,
          startingDayOfWeek: StartingDayOfWeek.monday,
          onDaySelected: onDaySelected,
          onPageChanged: onPageChanged,
          rowHeight: 75,

          // Styling
          calendarStyle: CalendarStyle(
            // Today
            todayDecoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: theme.colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),

            // Selected day
            selectedDecoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),

            // Default days
            defaultTextStyle: const TextStyle(
              fontWeight: FontWeight.w500,
            ),

            // Weekend days
            weekendTextStyle: TextStyle(
              color: Colors.red[400],
              fontWeight: FontWeight.w500,
            ),

            // Outside days
            outsideTextStyle: TextStyle(
              color: Colors.grey[400],
            ),

            // Markers
            markerDecoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              shape: BoxShape.circle,
            ),
            markersMaxCount: 1,
          ),

          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: false,
            titleTextStyle: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ) ?? const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            leftChevronIcon: Icon(
              Icons.chevron_left,
              color: theme.colorScheme.primary,
            ),
            rightChevronIcon: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.primary,
            ),
          ),

          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: Colors.grey[700],
              fontWeight: FontWeight.w600,
            ),
            weekendStyle: TextStyle(
              color: Colors.red[400],
              fontWeight: FontWeight.w600,
            ),
          ),

          // Event loader for markers
          eventLoader: (day) {
            return _getEventsForDay(day);
          },

          // Calendar builders for custom day widgets
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return null;

              final dayStr = Formatters.formatDateISO(day);
              final spent = _getSpentForDay(dayStr);
              final income = _getIncomeForDay(dayStr);

              // 지출과 수입이 모두 없으면 마커 표시 안 함
              if (spent == 0 && income == 0) return null;

              return Positioned(
                bottom: 4,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // 지출 표시 (빨강)
                    if (spent > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
                        margin: const EdgeInsets.only(bottom: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '-${_formatAmount(spent)}',
                          style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[700],
                            height: 1.1,
                          ),
                        ),
                      ),
                    // 수입 표시 (초록)
                    if (income > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+${_formatAmount(income)}',
                          style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                            height: 1.1,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Get transactions for a specific day
  List<TransactionModel> _getEventsForDay(DateTime day) {
    final dayStr = Formatters.formatDateISO(day);
    return transactions.where((t) => t.date == dayStr).toList();
  }

  /// Get total spent for a specific day
  int _getSpentForDay(String dateStr) {
    return transactions
        .where((t) => t.date == dateStr && t.type == TransactionType.expense)
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  /// Get total income for a specific day
  int _getIncomeForDay(String dateStr) {
    return transactions
        .where((t) => t.date == dateStr && t.type == TransactionType.income)
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  /// Format amount for display on calendar
  String _formatAmount(int amount) {
    if (amount == 0) return '';
    if (amount >= 10000) {
      final man = (amount / 10000).floor();
      return '$man만';
    } else if (amount >= 1000) {
      final cheon = (amount / 1000).floor();
      return '$cheon천';
    } else {
      return amount.toString();
    }
  }
}
