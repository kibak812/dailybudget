import 'package:flutter/material.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';
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
        context.l10n.mosaic_noBudget,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      );
    }

    return Text(
      context.l10n.mosaic_summary(summary.perfect, summary.overspent),
      style: theme.textTheme.bodyMedium?.copyWith(
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildSelectedDateInfo(BuildContext context) {
    final theme = Theme.of(context);
    final date = DateTime.parse(selectedDate!);
    final weekdays = [
      context.l10n.weekday_sun,
      context.l10n.weekday_mon,
      context.l10n.weekday_tue,
      context.l10n.weekday_wed,
      context.l10n.weekday_thu,
      context.l10n.weekday_fri,
      context.l10n.weekday_sat,
    ];
    final weekday = weekdays[date.weekday % 7];

    return Row(
      children: [
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium,
              children: [
                TextSpan(
                  text: context.l10n.mosaic_dateLabel(date.month, date.day, weekday),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                if (selectedDateNetSpent != null) ...[
                  const TextSpan(text: ' • '),
                  TextSpan(
                    text: context.l10n.net_expense_amount(Formatters.formatCurrency(selectedDateNetSpent!, context)),
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
          tooltip: context.l10n.transaction_viewAll,
          onPressed: onReset,
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}
