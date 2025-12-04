# Changelog

All notable changes to the Daily Pace project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Phase 8] - 2025-12-04

### Summary
Improved UX in Statistics tab by increasing pie chart size for better visibility.

### Changed

#### Statistics Page
- **Increased pie chart size** in category spending chart (2x larger)
  - Chart container height: 240px → 480px
  - Pie chart radius: 60/65 → 120/130 (normal/touched state)
  - Provides better visibility of category breakdown and percentages
  - Location: `lib/features/statistics/presentation/widgets/category_chart_card.dart:57, 96`

---

## [Phase 7] - 2025-12-02

### Summary
Bug fixes for budget settings, recurring transaction category filtering, daily budget trend chart calculation, and app name update.

### Fixed

#### Budget Settings
- **Fixed save button activation issue** in budget settings
  - Save button now activates immediately when monthly budget is entered
  - Added `setState()` call in TextField's `onChanged` callback to trigger UI rebuild
  - Location: `lib/features/settings/presentation/widgets/budget_settings_section.dart:157`

#### Recurring Transaction Modal
- **Fixed category dropdown filtering** in recurring transaction modal
  - Category dropdown now shows only relevant categories based on selected type
  - When "지출" is selected, only expense categories appear
  - When "수입" is selected, only income categories appear
  - Category selection resets when type is changed to prevent invalid category selection
  - Added import for `CategoryType` enum
  - Location: `lib/features/settings/presentation/widgets/recurring_modal.dart`

#### Daily Budget Trend Chart
- **Fixed calculation logic** in daily budget history chart
  - Chart now uses the new calculation logic that excludes current day's transactions
  - Each day's budget is calculated based on spending until the PREVIOUS day
  - This matches the current logic where today's available budget doesn't include today's transactions
  - Example: Day 3's budget = (Monthly budget - Day 1-2 spending) / Remaining days
  - Location: `lib/features/daily_budget/domain/services/daily_budget_service.dart:197-213`

### Changed

#### App Name
- **Updated app name** from "daily_pace" to "DailyPace"
  - Android: Updated `android:label` in AndroidManifest.xml
  - iOS: Updated `CFBundleDisplayName` and `CFBundleName` in Info.plist
  - Provides more professional and consistent branding

---

## [Phase 6] - 2025-12-02

### Summary
Major UI simplification of Transactions page by replacing complex calendar widget with simple date picker. This change improves maintainability, reduces UI complexity, and provides cleaner transaction browsing experience.

### Changed

#### Transactions Page UI Overhaul
- **Removed complex calendar widget** (`TransactionCalendar`) from Transactions page
- **Replaced with simple date picker button** using Flutter's native `showDatePicker`
- **Restored original list-based UI** showing transactions grouped by date
- **Added "이번 달 총 지출" display** in AppBar bottom section
- **Changed default view** from single-date to all dates (grouped by date)
- **Added date filter button** at top of transaction list
  - Shows "날짜 선택" when no date selected
  - Shows selected date in full format when filtered
  - Clear button (X) appears when date is selected to return to full view

#### Transaction List Improvements
- Transactions now displayed grouped by date (descending order)
- Each date section shows:
  - Date header with day of week (e.g., "12월 2일 (월)")
  - Daily total spending on the right
  - All transactions for that date below
- Smoother scrolling through multiple dates
- Better use of screen space

#### Calendar Widget Changes
- Calendar widget file still exists but no longer used in Transactions page
- Previous calendar improvements (amount display, layout fixes) preserved in widget
- Widget can be reused elsewhere if needed in future

### Removed
- Calendar widget from Transactions page (`TransactionCalendar` component usage)
- State variables: `_focusedDay`, `_selectedDay`
- Calendar-based date selection UI
- Selected date header display

### Added
- `_selectedDate` nullable state variable (null = show all dates)
- `_buildDateFilterButton()` method for date selection UI
- `_showDatePickerDialog()` method using native Flutter date picker
- `_buildDateSection()` method for rendering date-grouped transactions
- `_groupByDate()` helper method for grouping transactions
- `_calculateTotalSpent()` method for monthly expense total
- `_calculateDayTotal()` method for daily expense total

### Technical Details

**Files Modified:**
- `lib/features/transaction/presentation/pages/transactions_page.dart`
  - Removed calendar import
  - Changed filtering logic to support optional date selection
  - Restructured `_buildBody()` for list-based display
  - Updated `_buildAppBar()` to include monthly total
  - Added helper methods for grouping and calculations

**Files Preserved (but unused):**
- `lib/features/transaction/presentation/widgets/transaction_calendar.dart`
  - Widget preserved for potential future use
  - Contains all previous improvements (full amount display, better spacing, rounded rectangle indicators)

**Benefits:**
- Simpler codebase (less complex layout logic)
- Easier maintenance (no calendar layout issues)
- Better UX for browsing all transactions
- Native date picker provides familiar experience
- Faster navigation through transactions
- Better screen space utilization

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
