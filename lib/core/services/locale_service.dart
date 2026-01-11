import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

/// Service for accessing locale without BuildContext
/// Used by background services like notifications
class LocaleService {
  static final LocaleService _instance = LocaleService._internal();
  factory LocaleService() => _instance;
  LocaleService._internal();

  static const String _languageKey = 'app_language';

  String _currentLocale = 'ko'; // Default to Korean
  bool _isInitialized = false;

  /// Initialize the service by reading stored locale
  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey);

    if (savedLanguage == null || savedLanguage == 'system') {
      // Try to get system locale
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
      _currentLocale = systemLocale.languageCode == 'en' ? 'en' : 'ko';
    } else {
      _currentLocale = savedLanguage;
    }

    _isInitialized = true;
  }

  /// Get current locale code ('ko' or 'en')
  String get currentLocale => _currentLocale;

  /// Check if current locale is English
  bool get isEnglish => _currentLocale == 'en';

  /// Check if current locale is Korean
  bool get isKorean => _currentLocale == 'ko';

  /// Refresh locale from storage (call after language change)
  Future<void> refresh() async {
    _isInitialized = false;
    await initialize();
  }

  // ============================================
  // Localized Strings for Background Services
  // ============================================

  /// Notification channel name
  String get notificationChannelName => isEnglish ? 'Daily Summary' : '하루 결산';

  /// Notification channel description
  String get notificationChannelDesc => isEnglish
      ? 'Daily spending summary notifications at your set time'
      : '매일 설정한 시간에 어제의 지출 결산을 알려드립니다';

  /// Default notification title
  String get notificationPushTitle => isEnglish ? 'Daily Summary' : '하루 결산';

  /// Default notification body
  String get notificationPushBody => isEnglish
      ? 'Check yesterday\'s spending'
      : '어제의 지출을 확인해보세요';

  /// Status messages based on spending
  String getStatusMessage(String status) {
    final messages = isEnglish
        ? {
            'perfect': 'Great! You spent less than 50% of budget',
            'safe': 'Good job! You stayed within budget',
            'warning': 'Be careful. You slightly exceeded budget',
            'danger': 'Budget management needed. Significantly exceeded',
            'noBudget': 'Set a budget to manage your spending',
            'future': 'A new day begins!',
          }
        : {
            'perfect': '훌륭해요! 어제 예산의 50% 이하로 지출했어요',
            'safe': '잘했어요! 어제 예산 내에서 지출했어요',
            'warning': '조금 주의하세요. 어제 예산을 약간 초과했어요',
            'danger': '예산 관리가 필요해요. 어제 크게 초과했어요',
            'noBudget': '예산을 설정하고 지출을 관리해보세요',
            'future': '새로운 하루가 시작됐어요!',
          };
    return messages[status] ?? '';
  }

  /// Notification title based on status
  String getNotificationTitle(String status) {
    final titles = isEnglish
        ? {
            'perfect': 'Perfect Day!',
            'safe': 'Great Day!',
            'warning': 'Spending Report',
            'danger': 'Budget Alert',
            'default': 'Daily Summary',
          }
        : {
            'perfect': '완벽한 하루였어요!',
            'safe': '좋은 하루였어요',
            'warning': '어제 지출 리포트',
            'danger': '예산 초과 알림',
            'default': '하루 결산',
          };
    return titles[status] ?? titles['default']!;
  }

  // ============================================
  // Currency and Number Formatting
  // ============================================

  /// Format currency with locale awareness
  /// For English (USD), amount is treated as cents and converted to dollars
  /// For Korean (KRW), amount is displayed as-is (no decimal places)
  String formatCurrency(int amount) {
    if (isEnglish) {
      // Convert to dollars (assuming amount is stored in cents for USD)
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

  /// Format currency without symbol (for display)
  /// For English (USD): converts cents to dollars with 2 decimal places
  /// For Korean (KRW): displays as-is with no decimals
  String formatNumber(int amount) {
    if (isEnglish) {
      // Convert cents to dollars
      final formatter = NumberFormat('#,##0.00', 'en_US');
      return formatter.format(amount / 100);
    } else {
      final formatter = NumberFormat('#,###', 'ko_KR');
      return formatter.format(amount);
    }
  }

  /// Parse formatted number string to int (stored value)
  /// For English: "1,234.56" -> 123456 (converted to cents)
  /// For Korean: "1,234,567" -> 1234567 (as-is)
  int parseFormattedNumber(String formatted) {
    if (isEnglish) {
      // Parse as dollars and convert to cents
      final cleaned = formatted.replaceAll(',', '');
      final doubleValue = double.tryParse(cleaned) ?? 0.0;
      return (doubleValue * 100).round();
    } else {
      final value = formatted.replaceAll(RegExp(r'[^0-9]'), '');
      return int.tryParse(value) ?? 0;
    }
  }

  // ============================================
  // Date Formatting
  // ============================================

  /// Format date to full format (e.g., "January 11, 2026" or "2026년 1월 11일")
  String formatDateFull(DateTime date) {
    if (isEnglish) {
      final formatter = DateFormat.yMMMMd('en_US');
      return formatter.format(date);
    } else {
      return '${date.year}년 ${date.month}월 ${date.day}일';
    }
  }

  /// Format date to short format (e.g., "Jan 11" or "1월 11일")
  String formatDateShort(DateTime date) {
    if (isEnglish) {
      final formatter = DateFormat.MMMd('en_US');
      return formatter.format(date);
    } else {
      return '${date.month}월 ${date.day}일';
    }
  }

  /// Format date to month/day only (e.g., "1/11" or "1월 11일")
  String formatMonthDay(int month, int day) {
    if (isEnglish) {
      return '$month/$day';
    } else {
      return '$month월 $day일';
    }
  }

  /// Format date for chart X-axis (compact, unambiguous)
  /// English: "Jan 6" (month abbreviation + day)
  /// Korean: "1/6" (compact numeric)
  String formatChartDate(DateTime date) {
    if (isEnglish) {
      final formatter = DateFormat.MMMd('en_US');
      return formatter.format(date);
    } else {
      return '${date.month}/${date.day}';
    }
  }

  /// Format date for chart X-axis from month/day
  String formatChartDateFromParts(int month, int day) {
    if (isEnglish) {
      final date = DateTime(2000, month, day); // Year doesn't matter for formatting
      final formatter = DateFormat.MMMd('en_US');
      return formatter.format(date);
    } else {
      return '$month/$day';
    }
  }

  /// Format year and month (e.g., "Jan 2026" or "2026년 1월")
  String formatYearMonth(int year, int month) {
    if (isEnglish) {
      final date = DateTime(year, month);
      final formatter = DateFormat.yMMM('en_US');
      return formatter.format(date);
    } else {
      return '$year년 $month월';
    }
  }

  // ============================================
  // Notification Body Formatting
  // ============================================

  /// Format notification body with budget details
  String formatNotificationBody({
    required String statusMessage,
    required int yesterdayBudget,
    required int yesterdaySpent,
    required int todayBudget,
    required int monthProgress,
    required int usagePercentage,
  }) {
    final buffer = StringBuffer();
    buffer.writeln(statusMessage);
    buffer.writeln();

    if (yesterdayBudget > 0) {
      if (isEnglish) {
        buffer.writeln('Yesterday\'s budget: ${formatCurrency(yesterdayBudget)}');
        buffer.writeln('Yesterday\'s spending: ${formatCurrency(yesterdaySpent)} ($usagePercentage%)');
      } else {
        buffer.writeln('어제 예산: ${formatCurrency(yesterdayBudget)}');
        buffer.writeln('어제 지출: ${formatCurrency(yesterdaySpent)} ($usagePercentage%)');
      }
    }

    if (todayBudget > 0) {
      if (isEnglish) {
        buffer.writeln('Today\'s budget: ${formatCurrency(todayBudget)}');
      } else {
        buffer.writeln('오늘 예산: ${formatCurrency(todayBudget)}');
      }
    }

    if (isEnglish) {
      buffer.write('Period progress: $monthProgress%');
    } else {
      buffer.write('기간 진행률: $monthProgress%');
    }

    return buffer.toString();
  }
}
