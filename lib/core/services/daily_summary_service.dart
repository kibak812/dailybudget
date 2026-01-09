import 'package:daily_pace/features/transaction/domain/models/day_status.dart';
import 'package:daily_pace/core/constants/budget_constants.dart';

/// Daily summary data for notifications
class DailySummary {
  final int yesterdayBudget;
  final int yesterdaySpent;
  final int todayBudget;
  final int monthProgress; // percentage
  final int remainingDays;
  final DayStatus status;

  const DailySummary({
    required this.yesterdayBudget,
    required this.yesterdaySpent,
    required this.todayBudget,
    required this.monthProgress,
    required this.remainingDays,
    required this.status,
  });

  /// Get percentage of budget used
  int get usagePercentage {
    if (yesterdayBudget <= 0) return 0;
    return ((yesterdaySpent / yesterdayBudget) * 100).round();
  }

  /// Get encouragement message based on status
  String get encouragementMessage {
    switch (status) {
      case DayStatus.perfect:
        return '훌륭해요! 어제 예산의 50% 이하로 지출했어요';
      case DayStatus.safe:
        return '잘했어요! 어제 예산 내에서 지출했어요';
      case DayStatus.warning:
        return '조금 주의하세요. 어제 예산을 약간 초과했어요';
      case DayStatus.danger:
        return '예산 관리가 필요해요. 어제 크게 초과했어요';
      case DayStatus.noBudget:
        return '예산을 설정하고 지출을 관리해보세요';
      case DayStatus.future:
        return '새로운 하루가 시작됐어요!';
    }
  }

  /// Get notification title
  String get notificationTitle {
    switch (status) {
      case DayStatus.perfect:
        return '완벽한 하루였어요!';
      case DayStatus.safe:
        return '좋은 하루였어요';
      case DayStatus.warning:
        return '어제 지출 리포트';
      case DayStatus.danger:
        return '예산 초과 알림';
      case DayStatus.noBudget:
      case DayStatus.future:
        return '하루 결산';
    }
  }

  /// Get notification body
  String get notificationBody {
    final buffer = StringBuffer();
    buffer.writeln(encouragementMessage);
    buffer.writeln();

    if (yesterdayBudget > 0) {
      buffer.writeln('어제 예산: ${_formatCurrency(yesterdayBudget)}');
      buffer.writeln('어제 지출: ${_formatCurrency(yesterdaySpent)} ($usagePercentage%)');
    }

    if (todayBudget > 0) {
      buffer.writeln('오늘 예산: ${_formatCurrency(todayBudget)}');
    }

    buffer.write('기간 진행률: $monthProgress%');

    return buffer.toString();
  }

  String _formatCurrency(int amount) {
    if (amount >= 10000) {
      final man = amount ~/ 10000;
      final remainder = amount % 10000;
      if (remainder > 0) {
        return '$man만 ${_formatNumber(remainder)}원';
      }
      return '$man만원';
    }
    return '${_formatNumber(amount)}원';
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

/// Service to calculate daily summary
class DailySummaryService {
  /// Calculate status based on spending ratio
  /// Uses BudgetThresholds constants for threshold values
  static DayStatus calculateStatus(int budget, int spent) {
    if (budget <= 0) return DayStatus.noBudget;

    final ratio = spent / budget;
    if (ratio <= BudgetThresholds.perfect) return DayStatus.perfect;
    if (ratio <= BudgetThresholds.safe) return DayStatus.safe;
    if (ratio <= BudgetThresholds.warning) return DayStatus.warning;
    return DayStatus.danger;
  }
}
