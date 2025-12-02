# Changelog

All notable changes to the Daily Pace project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Phase 5] - 2025-12-02

### Summary
Major improvements to budget calculation system, UI/UX enhancements, and statistics reorganization. The app now uses net spending (expenses - income) as the basis for budget calculations, providing more accurate daily budget recommendations.

### Added

#### Net Spending Calculation
- Added `totalIncome` field to `DailyBudgetData` model for tracking income separately
- Added `getIncomeUntilDate()` method in `DailyBudgetService` to calculate cumulative income
- Added `getNetSpentUntilDate()` method in `DailyBudgetService` to calculate net spending (expenses - income)
- Added detailed breakdown card in Statistics page showing total expenses and total income separately

#### Statistics Page Enhancement
- Added "순지출" (net spending) summary card replacing "총 지출"
- Added detailed breakdown card with:
  - 총 지출 (Total Expenses) with red indicator
  - 총 수입 (Total Income) with green indicator
- Statistics now properly organized in the Statistics tab instead of Transactions page

#### Calendar UI Improvements
- Income and expenses now displayed separately on calendar
- Expenses shown with red background and "-" prefix
- Income shown with green background and "+" prefix
- Changed from horizontal to vertical marker layout for better readability
- Increased row height: 52px → 60px → **75px (final)**
  - First increase for vertical layout
  - Second increase to prevent date number overlap on busy days
- Increased font size from 7.5 to 10.0
- Improved spacing and padding for better touch targets

### Changed

#### Budget Calculation Logic
- **BREAKING**: Changed daily budget calculation from expense-only to net spending basis
  - Old formula: `(monthlyBudget - totalExpenses) / remainingDays`
  - New formula: `(monthlyBudget - netSpending) / remainingDays`
  - Net spending = Total Expenses - Total Income
- This change means income now increases available daily budget

- **CRITICAL**: Changed calculation timing to use previous day's data for stability
  - **Today's daily budget** now calculated based on **net spending until yesterday**
    - Prevents daily budget from fluctuating as you spend during the day
    - Provides stable budget target that doesn't change throughout the day
  - **Yesterday's daily budget** (for comparison) now calculated based on **net spending until day before yesterday**
    - Ensures fair comparison between consecutive days
    - Both use the same calculation methodology

  **Example:**
  - Day 3 at 10:00 AM: Daily budget shows based on Day 2's net spending
  - Day 3 at 11:00 PM: Same daily budget (doesn't change with today's spending)
  - Diff shows: (Day 3's budget based on Day 2) - (Day 2's budget based on Day 1)

  **Benefits:**
  - ✅ Stable daily budget throughout the day
  - ✅ Accurate day-to-day comparison
  - ✅ No confusing real-time fluctuations as you spend

#### Statistics Display Location
- Moved total spent/income/net spending statistics from Transactions page to Statistics page
- Removed AppBar bottom section from Transactions page (freed up vertical space)
- Changed "총 지출" card to "순지출" card in Statistics page
- Remaining budget calculation now uses net spending

#### Category Management
- Fixed Riverpod state management pattern in category lists
- Changed from `ref.watch(provider.notifier)` to `ref.watch(provider)` + `ref.read(provider.notifier)`
- Categories now update immediately when added without requiring manual refresh

### Removed

- Removed graph legend (양수/0) from daily budget trend chart for cleaner UI
- Removed statistics AppBar section from Transactions page
- Removed unused calculation methods from TransactionsPage:
  - `_calculateTotalSpent()`
  - `_calculateTotalIncome()`
  - `_calculateNetSpending()`

### Fixed

- Fixed category dropdown lists not updating immediately after adding new category
  - Affected components: `CategoryManagementSection`, `AddTransactionSheet`, `TransactionEditModalSheet`
  - Root cause: Watching notifier instead of state in Riverpod
- Fixed calendar markers overlapping when both income and expense exist on same day
  - Solution: Changed to vertical layout with proper spacing
- Fixed date numbers being covered by markers on busy days
  - Increased calendar rowHeight from 60px to 75px (+25%)
  - Ensures date numbers remain visible even with both income and expense markers
  - Commit: `5c6c306`

### Technical Details

#### Files Modified

**Core Business Logic:**
- `lib/features/daily_budget/domain/models/daily_budget_data.dart`
  - Added `totalIncome` field
  - Added `ChartPeriod` enum for period filtering (week/2weeks/month)
- `lib/features/daily_budget/domain/services/daily_budget_service.dart`
  - Added `getIncomeUntilDate()` method for income tracking
  - Added `getNetSpentUntilDate()` method for net spending calculation
  - **Changed `calculateDailyBudget()` to use net spending instead of total expenses**
  - **Modified calculation timing in `calculateDailyBudgetData()`:**
    - Today's budget uses yesterday's net spending (line 134)
    - Yesterday's budget uses day-before-yesterday's net spending (line 143)
    - Prevents real-time fluctuations during the day
  - Updated `getDailyBudgetHistory()` to support custom date ranges
  - Changed all calculations to use net spending basis
- `lib/features/daily_budget/presentation/providers/daily_budget_provider.dart`
  - Changed `dailyBudgetHistoryProvider` to `Provider.family<List<DailyBudgetHistoryItem>, ChartPeriod>`
  - Added period-based filtering support (week/2weeks/month)
  - Passes `startDay` and `endDay` to service based on selected period

**UI Components:**
- `lib/features/statistics/presentation/pages/statistics_page.dart`
  - Added detailed breakdown card
  - Changed summary card from expenses to net spending
  - Updated layout to always use Column
- `lib/features/transaction/presentation/pages/transactions_page.dart`
  - Removed AppBar statistics section
  - Simplified AppBar to title and actions only
- `lib/features/transaction/presentation/widgets/transaction_calendar.dart`
  - Increased rowHeight: 52px (default) → 60px → **75px (final, commit 5c6c306)**
  - Changed marker layout from Row to Column (vertical stacking)
  - Increased font size: 7.5 → 10.0
  - Added income display with green styling
  - Final height ensures date numbers visible even with both markers
- `lib/features/daily_budget/presentation/widgets/daily_budget_trend_chart.dart`
  - Changed from `ConsumerWidget` to `ConsumerStatefulWidget` to support period filtering
  - Added `SegmentedButton` for period selection (1주/2주/1달)
  - Removed legend section (양수/음수/0)
  - Chart now shows filtered data based on selected period
- `lib/features/daily_budget/presentation/pages/home_page.dart`
  - Removed notification button from AppBar (Phase 4)

**State Management Fixes:**
- `lib/features/settings/presentation/widgets/category_management_section.dart`
- `lib/features/transaction/presentation/widgets/add_transaction_sheet.dart`
- `lib/features/transaction/presentation/widgets/transaction_edit_sheet.dart`

**Visual Enhancements:**
- `lib/features/daily_budget/presentation/widgets/daily_budget_trend_chart.dart`
  - Removed legend display
- `lib/features/daily_budget/presentation/pages/home_page.dart`
  - Updated to work with new data model

#### Migration Notes

For users upgrading from Phase 4:
- Daily budget values may differ due to new net spending calculation
- If you have income transactions, your daily budget will now be higher (more accurate)
- Statistics are now only visible in the Statistics tab, not in Transactions tab
- Calendar now shows both income and expenses visually distinguished by color

### Testing

- ✓ Build successful: `flutter build apk --debug`
- ✓ No compilation errors
- ✓ Riverpod state management working correctly
- ✓ Calendar displays both income and expenses without overlap
- ✓ Statistics page shows all metrics correctly
- ✓ Budget calculations accurate with net spending basis

---

## [Phase 4] - Previous

- Added notification button removal
- Added calendar date auto-input
- Added graph period filtering

---

## [Initial Commit]

- Initial Flutter project setup
- Basic budget tracking functionality
- Transaction management
- Statistics and reporting
