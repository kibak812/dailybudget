# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Daily Pace (데일리 페이스) is a smart daily budget management Flutter application that calculates optimal daily spending budgets based on **net spending** (expenses - income). The app uses Isar for local storage, Riverpod for state management, and Syncfusion Charts for visualizations.

## Development Commands

### Running the App
```bash
# Run on default device
/c/src/flutter/bin/flutter run

# Run on specific device
/c/src/flutter/bin/flutter run -d emulator-5554    # Android emulator
/c/src/flutter/bin/flutter run -d windows          # Windows desktop
/c/src/flutter/bin/flutter run -d chrome           # Web browser
```

### Building
```bash
# Release build (default for testing, always use --split-per-abi)
/c/src/flutter/bin/flutter build apk --release --split-per-abi

# Debug build (only when debugging is needed)
/c/src/flutter/bin/flutter build apk --debug --split-per-abi
```

### Testing & Analysis
```bash
# Run tests
/c/src/flutter/bin/flutter test

# Static analysis
/c/src/flutter/bin/flutter analyze

# Check Flutter installation
/c/src/flutter/bin/flutter doctor
```

### Code Generation
When modifying Isar models (files with `@collection` annotation), regenerate code:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Architecture

### Feature-First Clean Architecture

The codebase follows a feature-first organization where each feature is self-contained:

```
lib/
├── app/                    # App-wide configuration
│   ├── theme/              # AppTheme, colors, text styles
│   └── router/             # GoRouter configuration with StatefulShellRoute
├── core/                   # Shared utilities
│   ├── providers/          # Isar database provider
│   └── utils/              # Formatters, data backup utilities
└── features/               # Feature modules
    ├── budget/             # Monthly budget management
    ├── daily_budget/       # Daily budget calculations and home page
    ├── transaction/        # Transaction CRUD and mosaic calendar
    ├── statistics/         # Charts and analytics
    ├── settings/           # App settings and categories
    └── recurring/          # Recurring transactions
```

### Layer Responsibilities

Each feature typically has 3 layers:

1. **Data Layer** (`data/`): Isar models and repositories
   - Models use `@collection` annotation and code generation
   - File pattern: `*_model.dart` + generated `*_model.g.dart`

2. **Domain Layer** (`domain/`): Business logic and services
   - Pure Dart classes with no Flutter dependencies
   - Services contain calculation logic (e.g., `DailyBudgetService`)

3. **Presentation Layer** (`presentation/`): UI and state management
   - Pages: Full screen widgets
   - Widgets: Reusable components
   - Providers: Riverpod state management

### Key Architectural Patterns

**State Management with Riverpod:**
- Use `ref.watch(provider)` to reactively listen to state changes
- Use `ref.read(provider.notifier)` for one-time reads or mutations
- NEVER watch notifiers: Use `ref.watch(provider)` not `ref.watch(provider.notifier)`
- All providers exported through `lib/core/providers/providers.dart`

**Database Access:**
- Isar instance accessed via `isarProvider`
- All models must extend `@collection` and use code generation
- Three collections: `BudgetModel`, `TransactionModel`, `RecurringTransactionModel`

**Navigation:**
- GoRouter with StatefulShellRoute for bottom navigation (4 tabs)
- Routes: `/home`, `/transactions`, `/statistics`, `/settings`
- Child routes supported (e.g., `/statistics/category-detail`)

## Critical Business Logic

### Net Spending Calculation

The app's core concept is **net spending = expenses - income**. This is used throughout for budget calculations.

**Yesterday-Based Budget Calculation:**
The daily budget for today is calculated using **yesterday's net spending**, NOT today's:
- Prevents real-time fluctuations as you spend during the day
- Provides a stable budget target throughout the day
- Formula: `(monthlyBudget - netSpentUntilYesterday) / remainingDays`

**Example (Day 3):**
```dart
// Today's budget uses Day 2's net spending
final todayBudget = (1000000 - netSpentDay1And2) / 28;

// Yesterday's budget uses Day 1's net spending
final yesterdayBudget = (1000000 - netSpentDay1) / 29;
```

**Key Service Methods:**
- `DailyBudgetService.getNetSpentUntilDate()` - Calculate net spending
- `DailyBudgetService.calculateDailyBudget()` - Calculate daily budget
- `DailyBudgetService.calculateDailyBudgetData()` - Main calculation entry point

See: `lib/features/daily_budget/domain/services/daily_budget_service.dart`

### Mosaic Calendar Logic

The Monthly Pace Mosaic shows color-coded daily spending status:
- **Perfect** (Indigo-700): Net spending ≤ 50% of daily budget
- **Safe** (Indigo-300): 50% < spending ≤ 100% of budget
- **Warning** (Amber-500): 100% < spending ≤ 150% of budget
- **Danger** (Rose-500): Spending > 150% of budget
- **Future** (Grey): Days after today
- **No Budget** (Light Grey): No budget set

For each day D, the calculation:
1. Calculate `dailyBudgetForDay` using net spending until day D-1
2. Calculate `netSpentThatDay` = expenses - income for day D
3. Determine status based on thresholds above

See: `lib/features/transaction/presentation/providers/monthly_mosaic_provider.dart`

## Chart Migration (Syncfusion)

The app recently migrated from fl_chart to Syncfusion Flutter Charts (v31.2.16):
- **Pie Chart**: Uses `SfCircularChart` with `DoughnutSeries` and connector lines
- **Line Chart**: Uses `SfCartesianChart` with `SplineAreaSeries`
- License: Syncfusion Community License (free for <$1M revenue)

When modifying charts:
- Pie chart: `lib/features/statistics/presentation/widgets/category_chart_card.dart`
- Line chart: `lib/features/daily_budget/presentation/widgets/daily_budget_trend_chart.dart`

## Common Development Patterns

### Adding a New Transaction
```dart
final isar = await ref.read(isarProvider.future);
await isar.writeTxn(() async {
  await isar.transactionModels.put(transaction);
});
// Providers automatically refresh due to Riverpod invalidation
```

### Reading Current Month Transactions
```dart
final currentMonth = ref.watch(currentMonthProvider);
final transactions = ref.watch(transactionProvider(currentMonth));
```

### Updating Categories
Categories are stored in SharedPreferences as JSON arrays:
- Expense categories: Key `expense_categories`
- Income categories: Key `income_categories`

See: `lib/features/settings/presentation/providers/categories_provider.dart`

## Database Migration Notes

The app previously used Hive but migrated to Isar. The database is stored in:
- Path: `ApplicationDocumentsDirectory/daily_pace_db`
- Enabled Isar Inspector for debugging

## Testing Strategy

When adding features:
1. Write tests for services (domain layer) - pure Dart, no Flutter dependencies
2. Build and verify on Android emulator first
3. Use `/c/src/flutter/bin/flutter analyze` to catch issues early
4. Test with different date scenarios (beginning/middle/end of month)
5. Verify calculations with both positive and negative budgets

## Known Constraints

1. **Date Format**: All dates stored as `YYYY-MM-DD` strings for consistent filtering
2. **Currency**: All amounts stored as integers (Korean won, no decimals)
3. **Month Navigation**: Uses `DateTime(year, month, 1)` format for month keys
4. **SMS Parsing**: Feature exists but currently commented out in pubspec.yaml
5. **Windows Environment**: Flutter path is `/c/src/flutter/bin/flutter` (Git Bash)

## Recent Migration History

See CHANGELOG.md for detailed history. Key recent changes:
- **Phase 11**: Migrated charts from fl_chart to Syncfusion
- **Phase 9**: Added Monthly Pace Mosaic calendar visualization
- **Phase 5**: Changed to net spending-based calculation, added yesterday-based logic
- **Phase 6**: Simplified Transactions page (removed complex calendar widget)

## Riverpod Anti-Patterns to Avoid

❌ **WRONG:**
```dart
final categories = ref.watch(expenseCategoriesProvider.notifier);
```

✅ **CORRECT:**
```dart
final categories = ref.watch(expenseCategoriesProvider);
final notifier = ref.read(expenseCategoriesProvider.notifier);
```

The `.notifier` pattern is only for reading/mutations, never for watching state changes.

## UI/UX Conventions

- Korean language throughout the app
- Indigo color scheme (primary: Indigo-700)
- Format numbers with Korean notation: 만 (10,000), 천 (1,000)
- Use `formatCurrency()` from `lib/core/utils/formatters.dart`
- Bottom navigation: 4 tabs (홈, 거래내역, 통계, 설정)
- No emojis in user-facing text unless explicitly requested

## Color Coding Standards

- **Expenses**: Red/Rose colors with minus symbol
- **Income**: Green colors with plus symbol
- **Budget Status**: Indigo gradient (Perfect → Safe)
- **Warnings**: Amber-500
- **Danger**: Rose-500

See: `lib/app/theme/app_colors.dart` and `lib/features/transaction/presentation/widgets/mosaic_colors.dart`

## Development Workflow

When completing a feature or fix request:

1. **Implement** - Complete the requested changes
2. **Build** - Always run `flutter build apk --release --split-per-abi` after implementation
3. **Wait for Confirm** - User will install and test the APK on device
4. **After User Confirms** - Proceed with:
   - Update CHANGELOG.md with the changes
   - `git add` relevant files
   - `git commit` with descriptive message
   - `git push` to remote

Do NOT commit or push until user explicitly confirms the changes work correctly.
