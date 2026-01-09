import 'package:flutter_test/flutter_test.dart';
import 'package:daily_pace/features/budget/presentation/providers/current_month_provider.dart';
import 'package:daily_pace/core/utils/date_range_extension.dart';

void main() {
  group('DateRangeForBudget Extension', () {
    group('getDateRange', () {
      test('시작일 1일 → 기존과 동일 (1월)', () {
        final month = CurrentMonth(year: 2024, month: 1);
        final (start, end) = month.getDateRange(1);
        expect(start, DateTime(2024, 1, 1));
        expect(end, DateTime(2024, 1, 31));
      });

      test('시작일 1일 → 기존과 동일 (2월 윤년)', () {
        final month = CurrentMonth(year: 2024, month: 2);
        final (start, end) = month.getDateRange(1);
        expect(start, DateTime(2024, 2, 1));
        expect(end, DateTime(2024, 2, 29));
      });

      test('시작일 1일 → 기존과 동일 (2월 평년)', () {
        final month = CurrentMonth(year: 2023, month: 2);
        final (start, end) = month.getDateRange(1);
        expect(start, DateTime(2023, 2, 1));
        expect(end, DateTime(2023, 2, 28));
      });

      test('시작일 25일 → 이전달 25일 ~ 이번달 24일', () {
        final month = CurrentMonth(year: 2024, month: 2);
        final (start, end) = month.getDateRange(25);
        expect(start, DateTime(2024, 1, 25));
        expect(end, DateTime(2024, 2, 24));
      });

      test('시작일 15일 → 이전달 15일 ~ 이번달 14일', () {
        final month = CurrentMonth(year: 2024, month: 3);
        final (start, end) = month.getDateRange(15);
        expect(start, DateTime(2024, 2, 15));
        expect(end, DateTime(2024, 3, 14));
      });

      test('연초 경계: 1월 시작일 25일 → 이전년도 12월 25일', () {
        final month = CurrentMonth(year: 2024, month: 1);
        final (start, end) = month.getDateRange(25);
        expect(start, DateTime(2023, 12, 25));
        expect(end, DateTime(2024, 1, 24));
      });

      test('연말 경계: 12월 시작일 25일', () {
        final month = CurrentMonth(year: 2024, month: 12);
        final (start, end) = month.getDateRange(25);
        expect(start, DateTime(2024, 11, 25));
        expect(end, DateTime(2024, 12, 24));
      });

      test('시작일 31일, 1월 → 12/31 ~ 1/30', () {
        final month = CurrentMonth(year: 2024, month: 1);
        final (start, end) = month.getDateRange(31);
        expect(start, DateTime(2023, 12, 31));
        expect(end, DateTime(2024, 1, 30));
      });

      test('시작일 31일, 2월 (윤년) → 1/31 ~ 2/28 (29-1=28)', () {
        final month = CurrentMonth(year: 2024, month: 2);
        final (start, end) = month.getDateRange(31);
        expect(start, DateTime(2024, 1, 31));
        expect(end, DateTime(2024, 2, 28)); // 29-1=28
      });

      test('시작일 31일, 3월 → 2/29 (윤년) ~ 3/30', () {
        final month = CurrentMonth(year: 2024, month: 3);
        final (start, end) = month.getDateRange(31);
        expect(start, DateTime(2024, 2, 29)); // 윤년이라 29일
        expect(end, DateTime(2024, 3, 30));
      });

      test('시작일 31일, 5월 → 4/30 ~ 5/30', () {
        final month = CurrentMonth(year: 2024, month: 5);
        final (start, end) = month.getDateRange(31);
        expect(start, DateTime(2024, 4, 30)); // 4월은 30일까지
        expect(end, DateTime(2024, 5, 30));
      });

      test('시작일 30일, 3월 → 2/29 (윤년에서 min) ~ 3/29', () {
        final month = CurrentMonth(year: 2024, month: 3);
        final (start, end) = month.getDateRange(30);
        expect(start, DateTime(2024, 2, 29)); // 2월은 29일까지라 min(30, 29)=29
        expect(end, DateTime(2024, 3, 29));
      });
    });

    group('getDaysInPeriod', () {
      test('1월 시작일 1일 → 31일', () {
        final month = CurrentMonth(year: 2024, month: 1);
        expect(month.getDaysInPeriod(1), 31);
      });

      test('2월 시작일 1일 (윤년) → 29일', () {
        final month = CurrentMonth(year: 2024, month: 2);
        expect(month.getDaysInPeriod(1), 29);
      });

      test('2월 시작일 1일 (평년) → 28일', () {
        final month = CurrentMonth(year: 2023, month: 2);
        expect(month.getDaysInPeriod(1), 28);
      });

      test('2월 시작일 25일 → 31일 (1/25~2/24)', () {
        final month = CurrentMonth(year: 2024, month: 2);
        expect(month.getDaysInPeriod(25), 31);
      });

      test('1월 시작일 25일 → 31일 (12/25~1/24)', () {
        final month = CurrentMonth(year: 2024, month: 1);
        expect(month.getDaysInPeriod(25), 31);
      });
    });

    group('Edge cases', () {
      test('시작일 2일', () {
        final month = CurrentMonth(year: 2024, month: 1);
        final (start, end) = month.getDateRange(2);
        expect(start, DateTime(2023, 12, 2));
        expect(end, DateTime(2024, 1, 1));
      });

      test('시작일 28일 (2월 안전)', () {
        final month = CurrentMonth(year: 2024, month: 2);
        final (start, end) = month.getDateRange(28);
        expect(start, DateTime(2024, 1, 28));
        expect(end, DateTime(2024, 2, 27));
      });
    });
  });
}
