import 'package:flutter/material.dart';
import 'package:daily_pace/features/transaction/domain/models/day_status.dart';

/// Color constants for the monthly pace mosaic
/// Adjusted to match existing Indigo-600 theme for design consistency
class MosaicColors {
  MosaicColors._();

  // Status colors
  static const Color perfect = Color(0xFF4338CA); // Indigo-700
  static const Color perfectText = Color(0xFFFFFFFF); // White

  static const Color safe = Color(0xFFA5B4FC); // Indigo-300
  static const Color safeText = Color(0xFF4338CA); // Indigo-700

  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color warningText = Color(0xFF000000); // Dark

  static const Color danger = Color(0xFFF43F5E); // Rose-500
  static const Color dangerText = Color(0xFFFFFFFF); // White

  static const Color future = Color(0xFFF1F5F9); // Slate-100
  static const Color futureText = Color(0xFF9E9E9E); // Grey

  static const Color noBudget = Color(0xFFFAFAFA); // Very Light Grey
  static const Color noBudgetText = Color(0xFFBDBDBD); // Grey

  /// Get background color for day status
  static Color getBackgroundColor(DayStatus status) {
    switch (status) {
      case DayStatus.perfect:
        return perfect;
      case DayStatus.safe:
        return safe;
      case DayStatus.warning:
        return warning;
      case DayStatus.danger:
        return danger;
      case DayStatus.future:
        return future;
      case DayStatus.noBudget:
        return noBudget;
    }
  }

  /// Get text color for day status
  static Color getTextColor(DayStatus status) {
    switch (status) {
      case DayStatus.perfect:
        return perfectText;
      case DayStatus.safe:
        return safeText;
      case DayStatus.warning:
        return warningText;
      case DayStatus.danger:
        return dangerText;
      case DayStatus.future:
        return futureText;
      case DayStatus.noBudget:
        return noBudgetText;
    }
  }
}
