import 'package:flutter/material.dart';

/// Status of a day based on spending vs daily budget
enum DayStatus {
  /// Future day (after today)
  future,

  /// Perfect day: net spent <= 50% of daily budget
  perfect,

  /// Safe day: 0 < net spent <= daily budget
  safe,

  /// Warning day: daily budget < net spent <= 1.5x daily budget
  warning,

  /// Danger day: net spent > 1.5x daily budget
  danger,

  /// No budget set for this month OR daily budget <= 0
  noBudget;

  /// Background color for mosaic cells
  Color get backgroundColor => switch (this) {
    DayStatus.perfect => const Color(0xFF4338CA),  // Indigo-700
    DayStatus.safe => const Color(0xFFA5B4FC),     // Indigo-300
    DayStatus.warning => const Color(0xFFE2E8F0), // Slate-200
    DayStatus.danger => const Color(0xFFCBD5E1),  // Slate-300
    DayStatus.future => const Color(0xFFF1F5F9),  // Slate-100
    DayStatus.noBudget => const Color(0xFFFAFAFA), // Very Light Grey
  };

  /// Text color for mosaic cells
  Color get textColor => switch (this) {
    DayStatus.perfect => const Color(0xFFFFFFFF),  // White
    DayStatus.safe => const Color(0xFF4338CA),     // Indigo-700
    DayStatus.warning => const Color(0xFF475569), // Slate-600
    DayStatus.danger => const Color(0xFF334155),  // Slate-700
    DayStatus.future => const Color(0xFF9E9E9E),  // Grey
    DayStatus.noBudget => const Color(0xFFBDBDBD), // Grey
  };

  /// Card color for summary cards (YesterdaySummary, etc.)
  Color get cardColor => switch (this) {
    DayStatus.perfect => const Color(0xFF4338CA),  // Indigo-700
    DayStatus.safe => const Color(0xFF6366F1),     // Indigo-500
    DayStatus.warning => const Color(0xFFF59E0B), // Amber-500
    DayStatus.danger => const Color(0xFFEF4444),  // Red-500
    DayStatus.future => Colors.grey,
    DayStatus.noBudget => Colors.grey,
  };

  /// Icon for status display
  IconData get icon => switch (this) {
    DayStatus.perfect => Icons.star_rounded,
    DayStatus.safe => Icons.check_circle_rounded,
    DayStatus.warning => Icons.warning_rounded,
    DayStatus.danger => Icons.error_rounded,
    DayStatus.future => Icons.info_rounded,
    DayStatus.noBudget => Icons.info_rounded,
  };

}
