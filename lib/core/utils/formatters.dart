import 'package:intl/intl.dart';

/// Utility class for formatting numbers and dates
class Formatters {
  /// Format currency amount to Korean format
  /// Example: 123456 -> "123,456원"
  static String formatCurrency(int amount) {
    final formatter = NumberFormat('#,###', 'ko_KR');
    return '${formatter.format(amount)}원';
  }

  /// Format date string (YYYY-MM-DD) to Korean format
  /// Example: "2025-12-01" -> "12월 1일"
  static String formatDate(String date) {
    try {
      final parts = date.split('-');
      if (parts.length != 3) return date;

      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      return '$month월 $day일';
    } catch (e) {
      return date;
    }
  }

  /// Format date to full Korean format
  /// Example: "2025-12-01" -> "2025년 12월 1일"
  static String formatDateFull(String date) {
    try {
      final parts = date.split('-');
      if (parts.length != 3) return date;

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);

      return '$year년 $month월 $day일';
    } catch (e) {
      return date;
    }
  }

  /// Format DateTime to ISO date string (YYYY-MM-DD)
  static String formatDateISO(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format year and month to YYYY-MM string
  /// Example: (2025, 12) -> "2025-12"
  /// Useful for filtering transactions by month prefix
  static String formatYearMonth(int year, int month) {
    return '$year-${month.toString().padLeft(2, '0')}';
  }

  /// Format number input with Korean locale (add commas)
  /// Example: "1234567" -> "1,234,567"
  static String formatNumberInput(String input) {
    // Remove all non-digits
    final value = input.replaceAll(RegExp(r'[^0-9]'), '');
    if (value.isEmpty) return '';

    final number = int.tryParse(value);
    if (number == null) return '';

    final formatter = NumberFormat('#,###', 'ko_KR');
    return formatter.format(number);
  }

  /// Parse formatted number string to int
  /// Example: "1,234,567" -> 1234567
  static int parseFormattedNumber(String formatted) {
    final value = formatted.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(value) ?? 0;
  }

  /// Format DateTime to time string (HH:mm)
  /// Example: DateTime(2025, 12, 1, 14, 30) -> "14:30"
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
