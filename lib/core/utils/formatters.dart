import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';

/// Utility class for formatting numbers and dates
/// Supports both Korean and English locales
class Formatters {
  /// Format currency amount with locale awareness
  /// Uses context to determine locale, falls back to Korean if no context
  /// For Korean (KRW): Amount stored as-is (no decimals). Example: 123456 -> "123,456원"
  /// For English (USD): Amount stored as cents, displayed as dollars. Example: 12345 -> "$123.45"
  static String formatCurrency(int amount, [BuildContext? context]) {
    final isEnglish = context != null && _isEnglishLocale(context);

    if (isEnglish) {
      // Convert to dollars (assuming amount is stored in cents for USD)
      // For USD, show with 2 decimal places (e.g., $123.45)
      final formatter = NumberFormat.currency(
        locale: 'en_US',
        symbol: '\$',
        decimalDigits: 2,
      );
      return formatter.format(amount / 100);
    } else {
      // Korean Won has no decimal places
      final formatter = NumberFormat('#,###', 'ko_KR');
      return '${formatter.format(amount)}원';
    }
  }

  /// Format currency for display without symbol (just number with commas)
  /// For English (USD): converts cents to dollars with 2 decimal places
  /// For Korean (KRW): displays as-is with no decimals
  static String formatCurrencyNumber(int amount, [BuildContext? context]) {
    final isEnglish = context != null && _isEnglishLocale(context);

    if (isEnglish) {
      // Convert cents to dollars
      final formatter = NumberFormat('#,##0.00', 'en_US');
      return formatter.format(amount / 100);
    } else {
      final formatter = NumberFormat('#,###', 'ko_KR');
      return formatter.format(amount);
    }
  }

  /// Format date string (YYYY-MM-DD) to localized format
  /// Example (Korean): "2025-12-01" -> "12월 1일"
  /// Example (English): "2025-12-01" -> "Dec 1"
  static String formatDate(String date, [BuildContext? context]) {
    try {
      final parts = date.split('-');
      if (parts.length != 3) return date;

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final dateTime = DateTime(year, month, day);

      final isEnglish = context != null && _isEnglishLocale(context);

      if (isEnglish) {
        final formatter = DateFormat.MMMd('en_US');
        return formatter.format(dateTime);
      } else {
        return '$month월 $day일';
      }
    } catch (e) {
      return date;
    }
  }

  /// Format date to full localized format
  /// Example (Korean): "2025-12-01" -> "2025년 12월 1일"
  /// Example (English): "2025-12-01" -> "December 1, 2025"
  static String formatDateFull(String date, [BuildContext? context]) {
    try {
      final parts = date.split('-');
      if (parts.length != 3) return date;

      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      final dateTime = DateTime(year, month, day);

      final isEnglish = context != null && _isEnglishLocale(context);

      if (isEnglish) {
        final formatter = DateFormat.yMMMMd('en_US');
        return formatter.format(dateTime);
      } else {
        return '$year년 $month월 $day일';
      }
    } catch (e) {
      return date;
    }
  }

  /// Format DateTime to ISO date string (YYYY-MM-DD)
  static String formatDateISO(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format DateTime to localized short format (without year)
  /// Example (Korean): DateTime(2025, 12, 1) -> "12월 1일"
  /// Example (English): DateTime(2025, 12, 1) -> "Dec 1"
  static String formatDateWithoutYear(DateTime date, [BuildContext? context]) {
    final isEnglish = context != null && _isEnglishLocale(context);

    if (isEnglish) {
      final formatter = DateFormat.MMMd('en_US');
      return formatter.format(date);
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }

  /// Format year and month to YYYY-MM string
  /// Example: (2025, 12) -> "2025-12"
  /// Useful for filtering transactions by month prefix
  static String formatYearMonth(int year, int month) {
    return '$year-${month.toString().padLeft(2, '0')}';
  }

  /// Format year and month for display
  /// Example (Korean): (2025, 12) -> "2025년 12월" or "2025.12"
  /// Example (English): (2025, 12) -> "Dec 2025"
  static String formatYearMonthDisplay(int year, int month, [BuildContext? context]) {
    final isEnglish = context != null && _isEnglishLocale(context);

    if (isEnglish) {
      final date = DateTime(year, month);
      final formatter = DateFormat.yMMM('en_US');
      return formatter.format(date);
    } else {
      return '$year.$month';
    }
  }

  /// Format number input with locale (add commas, handle decimals for USD)
  /// For Korean: "1234567" -> "1,234,567"
  /// For English: "1234.56" -> "1,234.56"
  static String formatNumberInput(String input, [BuildContext? context]) {
    final isEnglish = context != null && _isEnglishLocale(context);

    if (isEnglish) {
      // For English, allow decimal point
      // Remove all except digits and decimal point
      String cleaned = input.replaceAll(RegExp(r'[^0-9.]'), '');
      if (cleaned.isEmpty) return '';

      // Handle multiple decimal points - keep only first
      final parts = cleaned.split('.');
      if (parts.length > 2) {
        cleaned = '${parts[0]}.${parts[1]}';
      }

      // Limit decimal places to 2
      if (parts.length == 2 && parts[1].length > 2) {
        cleaned = '${parts[0]}.${parts[1].substring(0, 2)}';
      }

      // Format the integer part with commas
      if (cleaned.contains('.')) {
        final intPart = int.tryParse(parts[0]) ?? 0;
        final decPart = parts.length > 1 ? parts[1] : '';
        final formatter = NumberFormat('#,###', 'en_US');
        return '${formatter.format(intPart)}.$decPart';
      } else {
        final number = int.tryParse(cleaned) ?? 0;
        final formatter = NumberFormat('#,###', 'en_US');
        return formatter.format(number);
      }
    } else {
      // For Korean, integers only
      final value = input.replaceAll(RegExp(r'[^0-9]'), '');
      if (value.isEmpty) return '';

      final number = int.tryParse(value);
      if (number == null) return '';

      final formatter = NumberFormat('#,###', 'ko_KR');
      return formatter.format(number);
    }
  }

  /// Parse formatted number string to int (stored value)
  /// For Korean: "1,234,567" -> 1234567 (as-is)
  /// For English: "1,234.56" -> 123456 (converted to cents)
  static int parseFormattedNumber(String formatted, [BuildContext? context]) {
    final isEnglish = context != null && _isEnglishLocale(context);

    if (isEnglish) {
      // For English, parse as dollars and convert to cents
      // Remove commas
      final cleaned = formatted.replaceAll(',', '');
      final doubleValue = double.tryParse(cleaned) ?? 0.0;
      // Convert to cents (multiply by 100)
      return (doubleValue * 100).round();
    } else {
      // For Korean, just extract digits
      final value = formatted.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(value) ?? 0;
    }
  }

  /// Format DateTime to time string (HH:mm)
  /// Example: DateTime(2025, 12, 1, 14, 30) -> "14:30"
  static String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Format month and day for display
  /// Example (Korean): (12, 1) -> "12월 1일"
  /// Example (English): (12, 1) -> "12/1"
  static String formatMonthDay(int month, int day, [BuildContext? context]) {
    final isEnglish = context != null && _isEnglishLocale(context);

    if (isEnglish) {
      return '$month/$day';
    } else {
      return '$month월 $day일';
    }
  }

  /// Format weekday based on locale
  static String formatWeekday(int weekday, BuildContext context) {
    final weekdays = [
      context.l10n.weekday_sun,
      context.l10n.weekday_mon,
      context.l10n.weekday_tue,
      context.l10n.weekday_wed,
      context.l10n.weekday_thu,
      context.l10n.weekday_fri,
      context.l10n.weekday_sat,
    ];
    return weekdays[weekday % 7];
  }

  /// Check if current locale is English (public)
  static bool isEnglishLocale(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'en';
  }

  /// Check if current locale is English (private, for internal use)
  static bool _isEnglishLocale(BuildContext context) {
    return isEnglishLocale(context);
  }

  /// Get locale code from context
  static String getLocaleCode(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode;
  }
}
