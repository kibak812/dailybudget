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

  static const Color warning = Color(0xFFE2E8F0); // Slate-200 (light grey for warning)
  static const Color warningText = Color(0xFF475569); // Slate-600

  static const Color danger = Color(0xFFCBD5E1); // Slate-300 (darker grey for danger)
  static const Color dangerText = Color(0xFF334155); // Slate-700

  static const Color future = Color(0xFFF1F5F9); // Slate-100
  static const Color futureText = Color(0xFF9E9E9E); // Grey

  static const Color noBudget = Color(0xFFFAFAFA); // Very Light Grey
  static const Color noBudgetText = Color(0xFFBDBDBD); // Grey

  /// Get background color for day status
  /// Delegates to DayStatus.backgroundColor
  static Color getBackgroundColor(DayStatus status) => status.backgroundColor;

  /// Get text color for day status
  /// Delegates to DayStatus.textColor
  static Color getTextColor(DayStatus status) => status.textColor;
}
