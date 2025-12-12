# Daily Pace 아키텍처 리뷰: Martin Fowler 관점
## 에릭 감마 리뷰에 대한 실용주의적 재평가

> "Any fool can write code that a computer can understand. Good programmers write code that humans can understand."
> — Martin Fowler, Refactoring (1999)

---

## 에릭 감마 리뷰에 대한 Fowler의 평가

에릭 감마의 리뷰는 **패턴 중심적**이고 **구조적으로 정확**합니다. 그러나 Fowler의 관점에서는 몇 가지 다른 시각을 제시할 수 있습니다.

### 동의하는 부분

| 감마의 지적 | Fowler 동의도 | 이유 |
|------------|--------------|------|
| DayStatus 로직 중복 | **강하게 동의** | "Duplicated Code"는 가장 심각한 코드 냄새 |
| 날짜 포맷 중복 | 동의 | 하지만 더 근본적 원인이 있음 |
| Repository Pattern 미완성 | **부분 동의** | 일관성보다 필요성이 중요 |
| Strategy Pattern 도입 | **약하게 동의** | 현재 규모에서는 과도할 수 있음 |
| ISP 적용 | **비동의** | 6개 메서드는 과분리 |

### 비동의 또는 다른 시각

#### 1. Repository Pattern "완성"의 함정

감마는 `BudgetRepository`, `RecurringRepository` 추가를 권장했지만:

> **Fowler**: "Pattern을 위한 Pattern은 피하라. 실제 문제가 있을 때만 도입하라."

```dart
// 현재 Budget Provider - 이것이 정말 문제인가?
class BudgetNotifier extends StateNotifier<List<BudgetModel>> {
  Future<void> loadBudgets() async {
    final isar = await ref.read(isarProvider.future);
    final budgets = await isar.budgetModels.where().findAll();
    state = budgets;
  }
}
```

**Fowler 평가**:
- Budget은 Transaction보다 **훨씬 단순한 도메인**
- CRUD만 있고 복잡한 쿼리가 없음
- Repository 추상화의 이점(테스트, 교체)이 **실제로 필요한가?**
- "YAGNI" (You Aren't Gonna Need It) 원칙 적용 여지

**권장**: Budget과 Recurring에 Repository가 필요해지는 **구체적 상황**(예: 다른 DB 지원, 복잡한 테스트 필요)이 발생할 때 도입

#### 2. Interface Segregation 과적용 우려

감마가 제안한:
```dart
abstract class TransactionReader { ... }
abstract class TransactionWriter { ... }
```

**Fowler 관점**:
> "인터페이스 분리는 클라이언트가 다를 때 의미가 있다."

현재 코드베이스에서:
- `TransactionRepository`의 유일한 클라이언트는 `TransactionNotifier`
- Reader와 Writer를 분리해도 **같은 클래스가 둘 다 구현**
- 복잡성만 증가하고 실질적 이득 없음

**권장**: 현재 인터페이스 유지. 분리가 필요한 **구체적 use case** 발생 시 리팩토링

---

## Fowler 고유의 분석: 코드 냄새(Code Smells)

### 발견된 주요 코드 냄새

| 냄새 | 심각도 | 위치 | Fowler 리팩토링 |
|-----|--------|------|----------------|
| **Duplicated Code** | 높음 | DayStatus 로직 3곳 | Extract Method → Move Method |
| **Long Method** | 중간 | monthlyMosaicProvider (169줄) | Extract Method |
| **Primitive Obsession** | 중간 | 날짜 문자열 `YYYY-MM-DD` 전달 | Introduce Value Object |
| **Feature Envy** | 낮음 | YesterdaySummary.statusColor | Move Method to DayStatus |
| **Data Clumps** | 중간 | (year, month) 쌍 반복 | Introduce Parameter Object |

### 1. Primitive Obsession (가장 근본적 문제)

감마 리뷰에서 놓친 **근본 원인**:

```dart
// 코드베이스 전반에 걸친 날짜 문자열 전달
final yesterdayStr = Formatters.formatDateISO(yesterday);
final monthPrefix = '$year-${month.toString().padLeft(2, '0')}';
transactions.where((t) => t.date.startsWith(monthPrefix));
```

**문제**: `String` 타입의 날짜가 시스템 전체를 오염시킴

**Fowler 해결책**: Value Object 도입

```dart
// lib/core/domain/date_range.dart
class BudgetMonth {
  final int year;
  final int month;

  const BudgetMonth(this.year, this.month);

  String get prefix => '$year-${month.toString().padLeft(2, '0')}';

  bool contains(String dateStr) => dateStr.startsWith(prefix);

  BudgetMonth get previous => month == 1
      ? BudgetMonth(year - 1, 12)
      : BudgetMonth(year, month - 1);

  @override
  bool operator ==(Object other) =>
      other is BudgetMonth && year == other.year && month == other.month;

  @override
  int get hashCode => Object.hash(year, month);
}

class BudgetDate {
  final int year;
  final int month;
  final int day;

  const BudgetDate(this.year, this.month, this.day);

  factory BudgetDate.fromDateTime(DateTime dt) =>
      BudgetDate(dt.year, dt.month, dt.day);

  String get isoString =>
      '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  BudgetMonth get budgetMonth => BudgetMonth(year, month);

  BudgetDate get yesterday => day > 1
      ? BudgetDate(year, month, day - 1)
      : BudgetDate.fromDateTime(
          DateTime(year, month, day).subtract(const Duration(days: 1)));
}
```

**효과**:
- 8+ 중복 포맷팅 코드 제거
- 타입 안전성 확보
- 도메인 개념 명시화

### 2. Data Clumps: (year, month) 쌍

```dart
// 반복되는 패턴
DailyBudgetService.getDaysInMonth(currentMonth.year, currentMonth.month);
DateTime(currentMonth.year, currentMonth.month, day);
b.year == currentMonth.year && b.month == currentMonth.month
```

**Fowler 해결책**: 위의 `BudgetMonth` Value Object가 이 문제도 해결

```dart
// Before
DailyBudgetService.getDaysInMonth(currentMonth.year, currentMonth.month);

// After
currentMonth.daysInMonth;  // BudgetMonth에 메서드 추가
```

### 3. Feature Envy: 다른 클래스의 데이터에 대한 과도한 관심

```dart
// yesterday_summary_card.dart - YesterdaySummary 클래스
Color get statusColor {
  switch (status) {
    case DayStatus.perfect:
      return const Color(0xFF4338CA);  // DayStatus의 정보인데 여기서 정의
    // ...
  }
}
```

**문제**: `YesterdaySummary`가 `DayStatus`의 색상을 알고 있음

**Fowler 해결책**: Move Method

```dart
// DayStatus에 직접 정의 (Dart enum extension)
extension DayStatusVisual on DayStatus {
  Color get color => switch (this) {
    DayStatus.perfect => const Color(0xFF4338CA),
    DayStatus.safe => const Color(0xFF6366F1),
    DayStatus.warning => const Color(0xFFF59E0B),
    DayStatus.danger => const Color(0xFFEF4444),
    DayStatus.noBudget => Colors.grey,
    DayStatus.future => Colors.grey,
  };

  IconData get icon => switch (this) {
    DayStatus.perfect => Icons.star_rounded,
    DayStatus.safe => Icons.check_circle_rounded,
    // ...
  };

  String get message => switch (this) {
    DayStatus.perfect => '훌륭해요! 예산의 50% 이하로 지출했어요',
    // ...
  };
}
```

**효과**: DayStatus 관련 모든 정보가 한 곳에 집중

---

## Fowler의 리팩토링 우선순위

> "리팩토링은 코드 변경이 필요할 때 그 부분만 개선하는 것이 가장 효율적이다."
> — Martin Fowler, Refactoring

### 에릭 감마 우선순위 vs Fowler 우선순위

| 감마 순위 | 감마 제안 | Fowler 재평가 | 이유 |
|---------|----------|--------------|------|
| P0 | DayStatus 중복 제거 | **P0 유지** | 가장 명확한 중복 |
| P0 | Formatters 확장 | **P1로 하향** | Value Object가 더 근본적 해결 |
| P0 | 상수 파일 생성 | **P0 유지** | 빠르고 안전한 개선 |
| P1 | Repository 완성 | **P2로 하향** | YAGNI - 필요 시 도입 |
| P1 | 파일 분리 | **P1 유지** | SRP 개선 |
| P2 | Provider→Service 분리 | **P1로 상향** | 테스트 가능성 핵심 |
| P3 | Strategy Pattern | **P3 유지** | 현재 불필요 |
| - | Value Object 도입 | **P0 신규** | 근본 원인 해결 |
| - | DayStatus extension | **P0 신규** | Feature Envy 해결 |

### Fowler 권장 우선순위

```
P0 (즉시, 작은 변경):
├── DayStatus extension 추가 (색상, 아이콘, 메시지 통합)
├── DailySummaryService.calculateStatus() 재사용
└── 상수 파일 생성

P1 (다음 기능 개발 시):
├── BudgetMonth, BudgetDate Value Object 도입
├── Provider → Service 비즈니스 로직 분리
└── yesterday_summary_card.dart 파일 분리

P2 (필요 시):
├── Repository Pattern 확장 (테스트 필요 시)
└── Facade Pattern (복잡도 증가 시)

하지 않음:
├── TransactionRepository 분리 (ISP 과적용)
├── Strategy Pattern for DayStatus (enum으로 충분)
└── Template Method Pattern (현재 규모에서 불필요)
```

---

## Domain-Driven Design 관점

Fowler는 Eric Evans의 DDD에 큰 영향을 받았습니다.

### 현재 도메인 모델 평가

```
현재 구조:
├── BudgetModel (Isar Entity)
├── TransactionModel (Isar Entity)
├── DailyBudgetData (Value Object - Good!)
├── MonthlyMosaicData (Value Object - Good!)
└── DayStatus (Enum - Good!)
```

**긍정적**:
- `DailyBudgetData`, `MonthlyMosaicData`는 좋은 Value Object
- 비즈니스 로직이 Model이 아닌 Service에 있음 (Transaction Script 패턴)

**개선 가능**:
- `BudgetModel`과 `TransactionModel`이 **Anemic Domain Model** 경향
- 날짜/월 관련 도메인 개념 누락

### Ubiquitous Language (보편 언어) 분석

코드에서 발견되는 도메인 용어:

| 용어 | 한국어 | 사용 빈도 | 일관성 |
|-----|-------|----------|--------|
| Daily Budget | 일예산 | 높음 | 좋음 |
| Net Spent | 순지출 | 중간 | 좋음 |
| Day Status | - | 높음 | 좋음 |
| Monthly Mosaic | 월간 모자이크 | 낮음 | ? |
| Perfect/Safe/Warning/Danger | - | 높음 | 좋음 |

**제안**: `MonthlyMosaic` 보다 `MonthlyPace` 또는 `SpendingCalendar`가 더 도메인 친화적

---

## 테스트 가능성 분석

> "Whenever you are tempted to type something into a print statement or a debugger expression, write it as a test instead."
> — Martin Fowler

### 현재 테스트 가능성 평가

| 계층 | 테스트 용이성 | 이유 |
|-----|-------------|------|
| DailyBudgetService | **높음** | 순수 함수, Flutter 의존성 없음 |
| RecurringService | **높음** | 순수 함수 |
| TransactionNotifier | 중간 | Repository 주입 가능 |
| BudgetNotifier | **낮음** | Isar 직접 의존 |
| monthlyMosaicProvider | **낮음** | Provider 내 복잡한 로직 |

### Fowler 권장 개선

```dart
// 현재: 테스트하기 어려운 Provider
final monthlyMosaicProvider = Provider((ref) {
  // 169줄의 로직 - Provider 내부에서 계산
});

// 개선: 테스트 가능한 Service 분리
class MonthlyMosaicService {
  // 순수 함수로 변환 - 쉽게 테스트 가능
  MonthlyMosaicData calculate(
    BudgetModel? budget,
    List<TransactionModel> transactions,
    DateTime today,
    int year,
    int month,
  ) {
    // 로직 이동
  }
}

// Provider는 얇게 유지
final monthlyMosaicProvider = Provider((ref) {
  final budget = ref.watch(budgetProvider).firstOrNull;
  final transactions = ref.watch(transactionProvider);
  final today = ref.watch(currentDateProvider);
  final month = ref.watch(currentMonthProvider);

  return MonthlyMosaicService().calculate(
    budget, transactions, today, month.year, month.month,
  );
});
```

---

## 기술 부채 분석

> "Technical debt is a metaphor for the implied cost of additional rework caused by choosing an easy solution now instead of using a better approach that would take longer."
> — Martin Fowler

### 현재 기술 부채 목록

| 부채 | 이자율 | 설명 |
|-----|-------|------|
| DayStatus 중복 | **높음** | 변경 시 3곳 수정 필요, 버그 위험 |
| Primitive Obsession (날짜) | **중간** | 매번 포맷팅 필요, 타입 안전성 없음 |
| Provider 내 로직 | **중간** | 테스트 어려움, 리팩토링 저항 |
| 매직 넘버 | **낮음** | 가독성 저하, 변경 시 검색 필요 |
| 불완전한 Repository | **낮음** | 현재는 문제 없음, 필요 시 부채화 |

### 부채 상환 전략

```
Sprint 1 (즉시):
- DayStatus extension 추가 (2시간)
- calculateStatus() 재사용 (1시간)
- 상수 파일 생성 (1시간)
→ 부채 30% 상환

Sprint 2 (다음 기능과 함께):
- Value Object 도입 (4시간)
- MonthlyMosaicService 분리 (3시간)
→ 부채 60% 상환

Sprint 3+ (점진적):
- 파일 분리 리팩토링
- 테스트 커버리지 증가
→ 부채 80%+ 상환
```

---

## 결론: 감마 vs Fowler

### 관점 차이

| 측면 | 에릭 감마 | Martin Fowler |
|-----|---------|---------------|
| 초점 | 패턴과 구조 | 코드 냄새와 점진적 개선 |
| Repository 미완성 | 일관성 문제 | YAGNI - 필요할 때 |
| ISP 적용 | 원칙 준수 권장 | 과도한 분리 경고 |
| Strategy Pattern | 도입 권장 | Enum extension으로 충분 |
| 근본 원인 | 중복 코드 | Primitive Obsession |

### 공통 합의점

1. **DayStatus 로직 중복은 즉시 해결 필요**
2. **Provider에서 비즈니스 로직 분리 필요**
3. **상수 중앙화 필요**

### Fowler의 최종 평가

> "이 코드베이스는 **동작하는 소프트웨어**입니다. 에릭 감마의 분석은 정확하지만, 모든 패턴을 도입하려 하지 마세요."

> "대신 **코드를 변경해야 할 때 그 부분을 조금씩 개선**하세요. 'Rule of Three'를 따르세요 - 세 번 중복되면 그때 추상화하세요."

> "Value Object 도입이 가장 높은 ROI를 제공할 것입니다. 이것이 날짜 포맷팅, Data Clumps, 타입 안전성 문제를 **한 번에 해결**합니다."

---

## 부록: Fowler 스타일 리팩토링 레시피

### 레시피 1: Extract DayStatus Extension (30분)

```dart
// Step 1: day_status.dart에 extension 추가
extension DayStatusPresentation on DayStatus {
  Color get color => switch (this) { ... };
  IconData get icon => switch (this) { ... };
  String get koreanMessage => switch (this) { ... };
}

// Step 2: yesterday_summary_card.dart에서 statusColor, statusIcon 제거
// Step 3: mosaic_colors.dart에서 getColorForStatus() 제거 후 .color 사용
// Step 4: 테스트 실행
```

### 레시피 2: Unify calculateStatus (15분)

```dart
// Step 1: monthly_mosaic_provider.dart 수정
// Before:
if (dailyBudget <= 0) {
  status = DayStatus.noBudget;
} else if (netSpent <= dailyBudget * 0.5) {
  status = DayStatus.perfect;
}
// ...

// After:
status = DailySummaryService.calculateStatus(dailyBudget, netSpent);

// Step 2: yesterday_summary_card.dart 동일 적용
// Step 3: 테스트 실행
```

### 레시피 3: Introduce BudgetMonth (1시간)

```dart
// Step 1: lib/core/domain/budget_month.dart 생성
// Step 2: CurrentMonth 타입을 BudgetMonth로 교체
// Step 3: 컴파일 에러 수정하며 점진적 전환
// Step 4: 중복 포맷팅 코드를 BudgetMonth.prefix로 교체
// Step 5: 테스트 실행
```

---

**작성일**: 2025-12-12
**분석 도구**: Claude Code (Opus 4)
**참조 문헌**:
- Refactoring: Improving the Design of Existing Code (Martin Fowler, 1999/2018)
- Patterns of Enterprise Application Architecture (Martin Fowler, 2002)
- Domain-Driven Design (Eric Evans, 2003)
- Bliki: YAGNI, TechnicalDebt, CodeSmell (martinfowler.com)
