# Daily Pace 아키텍처 리뷰 보고서
## 에릭 감마 관점의 근본적 분석

> "Simple things should be simple, complex things should be possible."
> — Alan Kay (에릭 감마가 자주 인용하는 격언)

---

## Executive Summary

Daily Pace는 전반적으로 **잘 구조화된 Flutter 앱**입니다. Feature-first Clean Architecture를 적용하고, Riverpod으로 상태 관리를 하며, Repository Pattern으로 데이터 접근을 추상화했습니다.

그러나 GoF 디자인 패턴과 SOLID 원칙의 관점에서 볼 때, **몇 가지 근본적인 개선 기회**가 있습니다:

| 영역 | 현재 상태 | 개선 필요도 |
|------|----------|------------|
| 아키텍처 구조 | 양호 | 낮음 |
| 코드 중복 | 존재함 | **높음** |
| 단일 책임 원칙 (SRP) | 부분 위반 | 중간 |
| 개방-폐쇄 원칙 (OCP) | 양호 | 낮음 |
| 의존성 역전 원칙 (DIP) | 부분 적용 | 중간 |
| 디자인 패턴 활용 | 기본적 | 중간 |

---

## Part 1: 현재 아키텍처 평가

### 1.1 긍정적 요소

#### A. Feature-First 모듈화
```
lib/features/
├── budget/           # 독립적 기능 모듈
├── daily_budget/     # 자체 data/domain/presentation 계층
├── transaction/      # 명확한 경계
├── statistics/
├── settings/
└── recurring/
```

**평가**: 에릭 감마가 VS Code에서 추구한 **Extension 기반 모듈화**와 유사한 접근법입니다. 각 feature가 독립적으로 테스트 가능하고 교체 가능합니다.

#### B. Repository Pattern 적용
```dart
// 추상 인터페이스 (domain layer)
abstract class TransactionRepository {
  Future<List<TransactionModel>> getTransactions();
  // ...
}

// 구체 구현 (data layer)
class IsarTransactionRepository implements TransactionRepository {
  final Isar isar;
  // ...
}
```

**평가**: GoF의 **Bridge Pattern** 변형으로, 데이터 접근 구현을 추상화에서 분리했습니다. 테스트 시 Mock 주입이 가능합니다.

#### C. Service Layer의 순수성
```dart
class DailyBudgetService {
  DailyBudgetService._(); // Private constructor - Utility class

  static int calculateDailyBudget(
    int budgetAmount,
    int netSpent,
    int daysInMonth,
    int currentDay,
  ) {
    // Pure calculation - no side effects
  }
}
```

**평가**: Flutter/Dart 의존성 없는 순수 비즈니스 로직. **테스트 용이성 극대화**.

### 1.2 구조적 문제점

#### A. 불완전한 Repository Pattern 적용

**현재 상태**:
- `TransactionRepository`: 추상 인터페이스 + 구현 존재
- `BudgetRepository`: **존재하지 않음** (Provider가 직접 Isar 접근)
- `RecurringRepository`: **존재하지 않음**

```dart
// budget_provider.dart - 직접 Isar 접근
class BudgetNotifier extends StateNotifier<List<BudgetModel>> {
  Future<void> loadBudgets() async {
    final isar = await ref.read(isarProvider.future);
    final budgets = await isar.budgetModels.where().findAll(); // 직접 접근!
    state = budgets;
  }
}
```

**문제**: 일관성 부재. Transaction만 Repository를 사용하고 나머지는 직접 접근합니다.

#### B. Provider에 분산된 비즈니스 로직

`monthly_mosaic_provider.dart`는 **169줄의 순수 계산 로직**을 포함합니다:

```dart
final monthlyMosaicProvider = Provider<MonthlyMosaicData>((ref) {
  // ... 50줄의 데이터 조회 ...

  // 비즈니스 로직이 Provider 안에!
  if (dailyBudget <= 0) {
    status = DayStatus.noBudget;
  } else if (netSpent <= dailyBudget * 0.5) {  // 매직 넘버!
    status = DayStatus.perfect;
  } else if (netSpent <= dailyBudget) {
    status = DayStatus.safe;
  } // ... etc
});
```

**SRP 위반**: Provider는 상태 관리만 해야 하지만, 비즈니스 로직까지 수행합니다.

---

## Part 2: 코드 중복 분석

### 2.1 심각한 중복: DayStatus 결정 로직

**동일한 로직이 3곳에 존재**:

| 위치 | 라인 |
|------|------|
| `daily_summary_service.dart` | 105-113 |
| `monthly_mosaic_provider.dart` | 101-119 |
| `yesterday_summary_card.dart` | 108-119 |

```dart
// 중복 코드 #1: daily_summary_service.dart:105-113
static DayStatus calculateStatus(int budget, int spent) {
  if (budget <= 0) return DayStatus.noBudget;
  final ratio = spent / budget;
  if (ratio <= 0.5) return DayStatus.perfect;
  if (ratio <= 1.0) return DayStatus.safe;
  if (ratio <= 1.5) return DayStatus.warning;
  return DayStatus.danger;
}

// 중복 코드 #2: monthly_mosaic_provider.dart:101-119
if (dailyBudget <= 0) {
  status = DayStatus.noBudget;
} else if (netSpent <= dailyBudget * 0.5) {
  status = DayStatus.perfect;
} else if (netSpent <= dailyBudget) {
  status = DayStatus.safe;
} else if (netSpent <= dailyBudget * 1.5) {
  status = DayStatus.warning;
} else {
  status = DayStatus.danger;
}

// 중복 코드 #3: yesterday_summary_card.dart:108-119
// (위와 거의 동일)
```

**DRY 원칙 위반**: `DailySummaryService.calculateStatus()`가 이미 존재하지만 사용되지 않습니다.

### 2.2 날짜 포맷 중복

**Month Prefix 생성 패턴** (8+ 인스턴스):
```dart
// 반복되는 패턴
final monthPrefix = '$year-${month.toString().padLeft(2, '0')}';
```

| 파일 | 위치 |
|------|------|
| `monthly_mosaic_provider.dart` | line 26 |
| `daily_budget_provider.dart` | line 50, 83 |
| `transaction_provider.dart` | line 85 |
| `isar_transaction_repository.dart` | line 21 |
| `yesterday_summary_card.dart` | line 78 |
| `recurring_service.dart` | line 18, 40, 64 |
| `statistics_page.dart` | line 26 |

**해결책**: `Formatters.formatYearMonth(year, month)` 추가 필요

### 2.3 Daily Budget 계산 패턴 중복

**"전날까지의 순지출 기반 일예산 계산"** 패턴이 반복됩니다:

```dart
// 이 패턴이 monthly_mosaic_provider.dart에서 3번 반복 (line 68-80, 84-98, 123-137)
final prevDayStr = day > 1
    ? Formatters.formatDateISO(DateTime(year, month, day - 1))
    : null;
final netSpentUntilPrevDay = prevDayStr != null
    ? DailyBudgetService.getNetSpentUntilDate(transactions, prevDayStr)
    : 0;
final dailyBudget = DailyBudgetService.calculateDailyBudget(
  budget.amount,
  netSpentUntilPrevDay,
  daysInMonth,
  day,
);
```

---

## Part 3: GoF 디자인 패턴 적용 분석

### 3.1 현재 적용된 패턴

| 패턴 | 적용 위치 | 평가 |
|------|----------|------|
| **Singleton** | `NotificationService`, `AdService` | 적절함 |
| **Repository** | `TransactionRepository` | 부분 적용 |
| **Factory Method** | `TransactionModel.create()` | 적절함 |
| **Observer** | Riverpod watch chain | 암시적 적용 |
| **Strategy** | `DayStatus` enum | 기초적 |

### 3.2 적용 가능하지만 누락된 패턴

#### A. Strategy Pattern 강화

**현재**: DayStatus가 단순 enum
```dart
enum DayStatus {
  perfect, safe, warning, danger, noBudget, future
}
```

**개선안**: Status별 행동을 캡슐화
```dart
abstract class SpendingStatus {
  Color get color;
  String get message;
  IconData get icon;
  bool get isOverBudget;

  factory SpendingStatus.fromRatio(double ratio) {
    if (ratio <= 0.5) return PerfectStatus();
    if (ratio <= 1.0) return SafeStatus();
    // ...
  }
}

class PerfectStatus implements SpendingStatus {
  @override Color get color => AppColors.primaryDark;
  @override String get message => '훌륭해요!';
  // ...
}
```

**장점**: Status 관련 로직이 분산되지 않고 한 곳에 집중됩니다.

#### B. Template Method Pattern

**현재**: Daily budget 계산이 유사하지만 조금씩 다른 로직으로 반복

**개선안**: 공통 알고리즘 구조화
```dart
abstract class DailyBudgetCalculator {
  DailyBudgetResult calculate(DateTime date, Budget budget, List<Transaction> txns) {
    final prevDay = getPreviousDay(date);           // Hook method
    final netSpent = calculateNetSpent(txns, prevDay);
    final budget = calculateBudget(budget, netSpent, date);
    return createResult(budget, netSpent);          // Hook method
  }

  DateTime getPreviousDay(DateTime date);  // Override point
  DailyBudgetResult createResult(int budget, int spent);
}
```

#### C. Facade Pattern

**현재**: Provider들이 여러 서비스를 직접 조합
```dart
// monthly_mosaic_provider.dart
final budget = budgets.where(...).firstOrNull;
final monthTransactions = transactions.where(...).toList();
final daysInMonth = DailyBudgetService.getDaysInMonth(...);
// ... 160줄 이상의 조합 로직
```

**개선안**: BudgetFacade로 복잡성 숨김
```dart
class BudgetAnalysisFacade {
  final DailyBudgetService _budgetService;
  final TransactionRepository _transactionRepo;

  MonthlyMosaicData getMonthlyMosaic(int year, int month, DateTime today) {
    // 복잡한 조합 로직을 캡슐화
  }

  YesterdaySummary? getYesterdaySummary(DateTime today) {
    // 어제 결산 로직 캡슐화
  }
}
```

---

## Part 4: SOLID 원칙 준수 분석

### 4.1 Single Responsibility Principle (SRP)

#### 위반 사례

**`yesterday_summary_card.dart`** (395줄):
- Provider 정의 (line 17-48, 51-127)
- Data Model 정의 (line 130-198)
- Widget 구현 (line 200-395)

**3가지 책임이 한 파일에 혼재**

**개선안**: 파일 분리
```
lib/features/daily_budget/
├── domain/models/
│   └── yesterday_summary.dart        # Data Model
├── presentation/providers/
│   └── yesterday_summary_provider.dart  # Provider
└── presentation/widgets/
    └── yesterday_summary_card.dart   # Widget only
```

### 4.2 Open-Closed Principle (OCP)

**양호**: ChartPeriod enum이 확장 가능
```dart
enum ChartPeriod {
  week, twoWeeks, month;

  int getStartDay(int currentDay) {
    return switch (this) {
      ChartPeriod.week => max(1, currentDay - 6),
      ChartPeriod.twoWeeks => max(1, currentDay - 13),
      ChartPeriod.month => 1,
    };
  }
}
```

새 기간 추가 시 enum만 확장하면 됩니다.

### 4.3 Liskov Substitution Principle (LSP)

**양호**: `TransactionRepository` 인터페이스 준수
```dart
// 어떤 구현이든 교체 가능
class IsarTransactionRepository implements TransactionRepository { }
class MockTransactionRepository implements TransactionRepository { }
```

### 4.4 Interface Segregation Principle (ISP)

**부분 위반**: `TransactionRepository`가 6개 메서드를 강제
```dart
abstract class TransactionRepository {
  Future<List<TransactionModel>> getTransactions();
  Future<List<TransactionModel>> getTransactionsForMonth(...);
  Future<List<TransactionModel>> getTransactionsForDateRange(...);
  Future<void> addTransaction(...);
  Future<void> updateTransaction(...);
  Future<void> deleteTransaction(...);
}
```

**개선안**: 역할별 인터페이스 분리
```dart
abstract class TransactionReader {
  Future<List<TransactionModel>> getTransactions();
  Future<List<TransactionModel>> getTransactionsForMonth(...);
}

abstract class TransactionWriter {
  Future<void> addTransaction(...);
  Future<void> updateTransaction(...);
  Future<void> deleteTransaction(...);
}
```

### 4.5 Dependency Inversion Principle (DIP)

**부분 적용**:
- `TransactionProvider` → `TransactionRepository` (추상화 의존)
- `BudgetProvider` → `Isar` 직접 의존 (위반)

---

## Part 5: 하드코딩된 상수

### 5.1 매직 넘버

| 값 | 의미 | 위치 |
|----|------|------|
| `0.5` | Perfect 임계값 | 3곳 |
| `1.0` | Safe 임계값 | 3곳 |
| `1.5` | Warning 임계값 | 3곳 |
| `5.0` | 차트 "기타" 임계값 | category_chart_card.dart |
| `500` | 애니메이션 지연(ms) | statistics_page.dart |
| `2` | 광고 재시도 횟수 | banner_ad_widget.dart |

### 5.2 개선안: 상수 중앙화

```dart
// lib/core/constants/budget_thresholds.dart
class BudgetThresholds {
  static const double perfect = 0.5;  // 50% 이하
  static const double safe = 1.0;     // 100% 이하
  static const double warning = 1.5;  // 150% 이하
}

// lib/core/constants/ui_constants.dart
class UIConstants {
  static const Duration animationDelay = Duration(milliseconds: 500);
  static const int maxAdRetries = 2;
  static const double otherCategoryThreshold = 5.0;  // 5%
}
```

---

## Part 6: 권장 개선 사항

### 6.1 즉시 개선 (High Priority)

#### 1. DayStatus 로직 통합
```dart
// 기존: DailySummaryService.calculateStatus() 사용하지 않음
// 개선: 모든 곳에서 이 메서드 사용

// monthly_mosaic_provider.dart, yesterday_summary_card.dart 수정
status = DailySummaryService.calculateStatus(dailyBudget, netSpent);
```

**예상 효과**: 약 40줄 코드 제거, 버그 수정 시 한 곳만 수정

#### 2. Formatters 확장
```dart
// lib/core/utils/formatters.dart에 추가
static String formatYearMonth(int year, int month) {
  return '$year-${month.toString().padLeft(2, '0')}';
}

static String formatYearMonthDay(int year, int month, int day) {
  return '${formatYearMonth(year, month)}-${day.toString().padLeft(2, '0')}';
}
```

**예상 효과**: 8+ 중복 제거

#### 3. 상수 파일 생성
```dart
// lib/core/constants/constants.dart
library constants;

export 'budget_thresholds.dart';
export 'ui_constants.dart';
export 'category_constants.dart';  // '기타', '미분류' 통일
```

### 6.2 중기 개선 (Medium Priority)

#### 1. Repository Pattern 완성
- `BudgetRepository` 추상 인터페이스 + Isar 구현
- `RecurringTransactionRepository` 추상 인터페이스 + Isar 구현

#### 2. Provider 책임 분리
```dart
// AS-IS: Provider 내 비즈니스 로직
final monthlyMosaicProvider = Provider((ref) {
  // 169줄의 계산 로직
});

// TO-BE: Service로 분리
class MonthlyMosaicService {
  MonthlyMosaicData calculate(...) { /* 로직 이동 */ }
}

final monthlyMosaicProvider = Provider((ref) {
  return MonthlyMosaicService().calculate(...);  // 위임만
});
```

#### 3. 파일 분리
- `yesterday_summary_card.dart` → 3개 파일로 분리
- `statistics_page.dart` → 헬퍼 메서드를 별도 서비스로

### 6.3 장기 개선 (Low Priority)

#### 1. Strategy Pattern 도입
DayStatus를 행동을 가진 객체로 전환

#### 2. Facade Pattern 도입
복잡한 Provider 조합을 캡슐화

#### 3. ISP 적용
큰 Repository를 역할별 인터페이스로 분리

---

## Part 7: 에릭 감마 스타일의 우선순위 매트릭스

> "First, make it work. Then make it right. Then make it fast."
> — Kent Beck (에릭 감마의 협업자)

| 우선순위 | 작업 | ROI | 복잡도 |
|---------|------|-----|--------|
| **P0** | DayStatus 로직 중복 제거 | 높음 | 낮음 |
| **P0** | Formatters.formatYearMonth() 추가 | 높음 | 낮음 |
| **P0** | 상수 파일 생성 | 높음 | 낮음 |
| **P1** | Repository Pattern 완성 | 중간 | 중간 |
| **P1** | yesterday_summary_card.dart 분리 | 중간 | 낮음 |
| **P2** | Provider → Service 로직 분리 | 중간 | 중간 |
| **P3** | Strategy Pattern 도입 | 낮음 | 높음 |
| **P3** | Facade Pattern 도입 | 낮음 | 높음 |

---

## Part 8: 코드 라인 수 분석

### 현재 상태
```
Total Dart Files: 66
Estimated LoC: ~8,000 lines (excluding generated)
Generated Code: 3 files (.g.dart)
```

### 개선 후 예상
```
P0 개선 적용 시:
- 중복 제거: -80 lines
- 상수 파일: +30 lines
- 순감소: -50 lines

P1 개선 적용 시:
- Repository 추가: +150 lines (but better structure)
- 파일 분리: ±0 lines (reorganization)
```

---

## Part 9: 결론

### 강점
1. **Feature-First Architecture**: 모듈화 우수
2. **Riverpod 활용**: 반응형 상태 관리
3. **Service Layer 순수성**: 테스트 용이
4. **일관된 네이밍**: 코드 가독성 양호

### 개선 필요
1. **DRY 원칙 위반**: 중복 코드 다수
2. **불완전한 추상화**: Repository Pattern 미완성
3. **SRP 위반**: Provider에 비즈니스 로직 혼재
4. **매직 넘버**: 상수 미중앙화

### 최종 평가

> **"Good architecture is not about perfection, but about making the system easy to change."**
> — 에릭 감마

Daily Pace는 **실용적이고 동작하는 앱**입니다. 완벽한 아키텍처보다 중요한 것은 **점진적 개선 가능성**인데, 이 코드베이스는 그 가능성을 갖추고 있습니다.

P0 개선 사항만 적용해도 **코드 품질이 크게 향상**될 것입니다. 이는 몇 시간 내에 완료할 수 있는 작업이며, 향후 유지보수 비용을 현저히 줄여줄 것입니다.

---

**작성일**: 2025-12-12
**분석 도구**: Claude Code (Opus 4)
**참조 문헌**:
- Design Patterns: Elements of Reusable Object-Oriented Software (GoF)
- Clean Architecture (Robert C. Martin)
- Flutter Architecture Guidelines
