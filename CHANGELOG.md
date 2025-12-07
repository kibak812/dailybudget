# Changelog

All notable changes to the DailyBudget project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Phase 20] - 2025-12-07

### Summary
Category rename now updates all existing transactions with that category. Previously, renaming a category only changed the category list, leaving transactions with the old name disconnected.

### Changed

#### Category Rename with Transaction Sync
- **Bulk transaction update**: When renaming a category, all transactions using that category are automatically updated
- **Consistent data**: No more orphaned transactions with old category names
- **Statistics accuracy**: Category-based statistics now correctly reflect renamed categories

### Technical Details
- `CategoriesNotifier._updateTransactionsCategory()`: New method to update transactions in Isar DB
- `_CategoryEditDialog`: Separate StatefulWidget for proper TextEditingController lifecycle management
- 50ms delay after dialog close to prevent Flutter build cycle conflicts
- `ref.invalidate(transactionProvider)` called from UI layer for safe state refresh

### Files Modified
- `lib/features/settings/presentation/providers/categories_provider.dart`
- `lib/features/settings/presentation/widgets/category_management_section.dart`
- `lib/features/transaction/presentation/widgets/category_selector_sheet.dart`

---

## [Phase 19] - 2025-12-07

### Summary
Renamed app from DailyPace to DailyBudget. Improved category management UX with long-press reordering and added category rename functionality.

### Changed

#### App Name
- Renamed from **DailyPace** to **DailyBudget** across all platforms
  - Android: `AndroidManifest.xml`
  - iOS: `Info.plist`
  - Windows: `main.cpp`
  - macOS: `AppInfo.xcconfig`

#### Category Reorder UX
- **Long-press required**: Changed from `ReorderableDragStartListener` to `ReorderableDelayedDragStartListener`
- Prevents accidental reordering when scrolling
- Settings category management: drag handle requires long-press
- Transaction category selector: drag handle only visible in edit mode, requires long-press

### Added

#### Category Rename Feature
- **Settings > Category Management**: Tap category name or edit icon to rename
- **Transaction Category Selector (Edit Mode)**: Edit icon to rename categories
- `updateCategory()` method in `CategoriesNotifier` (already existed, now used in UI)

---

## [Phase 18] - 2025-12-07

### Summary
Unified category management into transaction add/edit flow. Users can now select, add, delete, and reorder categories directly when adding or editing transactions, eliminating the need to navigate to settings.

### Added

#### CategorySelectorSheet Widget
- **New widget**: `lib/features/transaction/presentation/widgets/category_selector_sheet.dart`
- **List-style UI**: Categories displayed as a scrollable list (not chips)
- **Selection mode**: Tap category to select and close sheet
- **Edit mode**: Toggle via pencil icon (✏️) in header
  - Add new category via input field at top
  - Delete category via × button on each item
- **Drag & drop reorder**: Long-press to drag and reorder categories
- **Visual feedback**: Selected category shows checkmark (✓), elevation on drag

### Changed

#### Transaction Sheets
- **add_transaction_sheet.dart**: Replaced `DropdownButtonFormField` with tap-to-open `CategorySelectorSheet`
- **transaction_edit_sheet.dart**: Same change applied

#### Settings Page
- **Removed**: Category management section from settings page
- Categories are now managed exclusively through the transaction flow

### Removed
- Category management section from settings tab (functionality moved to transaction flow)

---

## [Phase 17] - 2025-12-07

### Summary
Improved donut chart visualization with data preprocessing and optimized connector line settings to prevent label overlap and improve readability.

### Added

#### Data Preprocessing for Chart
- **'기타' category grouping**: Items below 5% threshold are merged into '기타'
- **Descending sort**: Chart data sorted by amount (largest first)
- **Separate chart/list data**: Chart shows preprocessed data, bottom list shows original

### Changed

#### Syncfusion Donut Chart Optimization
- **Connector line**: Changed from `line` to `curve` type, length set to `8%`
- **Start angle**: Changed to 270° (12 o'clock position) for better label distribution
- **'기타' color**: Gray-400 (#9CA3AF) for visual distinction
- **Radius**: Changed from pixel-based to percentage-based (`70%`)
- Location: `lib/features/statistics/presentation/widgets/category_chart_card.dart`

---

## [Phase 16] - 2025-12-06

### Summary
Added Galaxy Fold optimization with 2-column split layout for Transactions and Statistics tabs when using the inner display (width >= 600dp).

### Added

#### Foldable Device Support
- **Transactions Tab - Split Layout**
  - Left panel (380px): Month navigation + Calendar mosaic
  - Right panel: Transaction list with filters
  - FAB positioned at bottom-left of left panel
  - Location: `lib/features/transaction/presentation/pages/transactions_page.dart`

- **Statistics Tab - Split Layout**
  - Left panel: Summary cards + Budget usage bar
  - Right panel: Category pie chart
  - Location: `lib/features/statistics/presentation/pages/statistics_page.dart`

- **Responsive Widget Updates**
  - MonthlyPaceMosaic: Added LayoutBuilder for width-based sizing in split panels
  - CategoryChartCard: Uses constraint-based width for font sizing
  - Breakpoint: 600dp (Material Design tablet threshold)

### Changed

#### Development Workflow (CLAUDE.md)
- Default build changed to release (`--release --split-per-abi`)
- Added workflow: Implement → Build → User Confirm → Commit → Push

---

## [Phase 15] - 2025-12-06

### Summary
Improved responsive design for calendar mosaic and category chart to prevent overflow and text truncation on various screen sizes.

### Changed

#### Calendar Mosaic - Overflow Prevention
- **Added cell size maximum limit**
  - Previous: Cell size grew unbounded on large screens
  - New: `cellSize.clamp(0.0, 48.0)` limits max cell size to 48px
  - Prevents calendar from overflowing container on large screens/tablets
  - Location: `lib/features/transaction/presentation/widgets/monthly_pace_mosaic.dart:32`

- **Added ClipBehavior to GridView**
  - Added `clipBehavior: Clip.hardEdge` to prevent content from rendering outside bounds
  - Location: `lib/features/transaction/presentation/widgets/monthly_pace_mosaic.dart:115`

#### Category Chart - Small Screen Text Visibility
- **Reduced chart dimensions**
  - Chart height: `(screenHeight * 0.35).clamp(280, 400)` → `(screenHeight * 0.28).clamp(200, 300)`
  - Chart radius: `(chartHeight * 0.28).clamp(70, 110)` → `(chartHeight * 0.26).clamp(55, 85)`
  - Location: `lib/features/statistics/presentation/widgets/category_chart_card.dart:81-83`

- **Reduced font sizes**
  - Base font: `(screenWidth * 0.028).clamp(9, 11)` → `(screenWidth * 0.022).clamp(7.5, 9)`
  - Prevents text truncation with "(..)" on small screens

- **Removed bold styling from labels**
  - Chart labels: `FontWeight.bold` → `FontWeight.normal`
  - Category list name: `FontWeight.w500` → `FontWeight.normal`
  - Category list amount: `FontWeight.bold` → `FontWeight.w500`
  - Reduces text width, allowing more characters to fit

- **Changed overflow handling**
  - `overflowMode: OverflowMode.hide` → `OverflowMode.trim`
  - Removes "(..)" truncation indicator for cleaner appearance

- **Shortened connector lines**
  - Length: `18%` → `12%`
  - Provides more space for label text

---

## [Phase 14] - 2025-12-06

### Summary
Fixed responsive design issues across Statistics, Home, and Transactions tabs to improve UX on various screen sizes (phones, tablets, foldables).

### Changed

#### Statistics Tab - Donut Chart Responsive Sizing
- **Implemented responsive chart sizing with LayoutBuilder**
  - Previous: Fixed 520px height causing overflow on small screens
  - New: Dynamic sizing based on screen dimensions
  - Chart height: `(screenHeight * 0.35).clamp(280.0, 400.0)`
  - Chart radius: `(chartHeight * 0.28).clamp(70.0, 110.0)`
  - Font size: `(screenWidth * 0.028).clamp(9.0, 11.0)`
  - Result: Chart scales appropriately, preventing label truncation with "..."
  - Location: `lib/features/statistics/presentation/widgets/category_chart_card.dart:75-83`

- **Reduced vertical spacing around chart**
  - Changed top/bottom spacing from 24px to 12px
  - Provides more room for chart content
  - Location: `lib/features/statistics/presentation/widgets/category_chart_card.dart:71, 135`

- **Reduced connector line length**
  - Changed from 20% to 18% to prevent clipping on small screens
  - Location: `lib/features/statistics/presentation/widgets/category_chart_card.dart:118`

- **Added overflow protection**
  - Added `overflowMode: OverflowMode.hide` to hide labels that don't fit
  - Location: `lib/features/statistics/presentation/widgets/category_chart_card.dart:123`

#### Home Tab - Line Chart Touch Interaction & Tooltips
- **Replaced TooltipBehavior with TrackballBehavior**
  - Previous: Required precise touch on data points, showed "Series 0" prefix
  - New: Vertical trackball line for wider touch area, clean tooltips
  - Users can tap anywhere near data points to see values
  - Location: `lib/features/daily_budget/presentation/widgets/daily_budget_trend_chart.dart:165-182`

- **Implemented Korean currency formatting in tooltips**
  - Added `onTrackballPositionChanging` callback with `Formatters.formatCurrency()`
  - Previous: "3일\n50000" (raw number)
  - New: "3일\n50,000원" (formatted with commas and currency symbol)
  - Created `_TooltipData` helper class for type safety
  - Location: `lib/features/daily_budget/presentation/widgets/daily_budget_trend_chart.dart:8-13, 161, 185-195`

- **Reduced warning text font size**
  - Changed "내일부터 일별 예산이 줄어듭니다" from 11pt to 10pt
  - Location: `lib/features/daily_budget/presentation/widgets/today_spent_card.dart:89`

#### Transactions Tab - Calendar Responsive Height
- **Implemented dynamic calendar height calculation**
  - Previous: Fixed 350px height causing bottom dates to be cut off on large screens
  - New: Calculates height based on number of calendar weeks (4-6 rows) and screen size
  - Formula: Accounts for cell size, header, spacing, and grid gaps
  - Constraints: `min 280px, max 50% of screen height`
  - Result: Adapts to different month layouts and device types
  - Location: `lib/features/transaction/presentation/widgets/monthly_pace_mosaic.dart:22-48`

### Technical Details

- **Type Safety Improvements**
  - Created `_TooltipData` class to handle Syncfusion's `num` vs `int` type conflicts
  - Added `.toInt()` conversions where needed for list indexing

- **Responsive Design Patterns**
  - Used `MediaQuery` for screen dimensions
  - Used `LayoutBuilder` for constraint-based sizing
  - Used `.clamp()` for min/max bounds
  - Percentage-based sizing with pixel constraints

### Files Modified
1. `lib/features/statistics/presentation/widgets/category_chart_card.dart`
2. `lib/features/daily_budget/presentation/widgets/daily_budget_trend_chart.dart`
3. `lib/features/daily_budget/presentation/widgets/today_spent_card.dart`
4. `lib/features/transaction/presentation/widgets/monthly_pace_mosaic.dart`

---

## [Phase 13] - 2025-12-06

### Summary
Refined donut chart UX by removing unnecessary touch interactions and improving label visibility, plus added new category detail page for drilling down into transaction details.

### Changed

#### Donut Chart UX Refinements
- **Removed touch interaction/explode functionality**
  - Previous: Tapping chart segments triggered explode/collapse animation
  - New: Removed all touch interactions (GestureDetector, selectionBehavior, explode properties)
  - Reason: Touch behavior was unnatural on mobile; feature was not essential
  - Impact: Cleaner, simpler user experience
  - Location: `lib/features/statistics/presentation/widgets/category_chart_card.dart`

- **Changed connector lines from curved to straight**
  - Changed `ConnectorType.curve` to `ConnectorType.line`
  - Result: More professional and clean appearance
  - Location: `lib/features/statistics/presentation/widgets/category_chart_card.dart:102`

- **Compact single-line labels with reduced font size**
  - Previous: Two-line format "쇼핑\n25.5%" with 14pt font
  - New: Single-line format "쇼핑(25.5%)" with 11pt font
  - Result: All labels fit within container, no overflow issues
  - Location: `lib/features/statistics/presentation/widgets/category_chart_card.dart:85-99`

- **Reduced chart radius for better label visibility**
  - Changed radius from '120' to '100'
  - Provides more space for outside labels and connector lines
  - Location: `lib/features/statistics/presentation/widgets/category_chart_card.dart:110`

### Added

#### Category Detail Page
- **New category detail page with drill-down navigation**
  - Created new page: `lib/features/statistics/presentation/pages/category_detail_page.dart`
  - Shows all transactions for selected category in current month
  - Features:
    - Summary card with total spending, transaction count, and color-coded header
    - Filtered transaction list sorted by date (newest first)
    - Transaction details: date (with day of week), amount, memo
    - Empty state when no transactions exist
    - Back navigation to statistics page
  - Navigation: Tap any category in the category list to view details
  - Route: `/statistics/category-detail` (child route of statistics)

- **Made category list items tappable**
  - Wrapped category items with InkWell for touch feedback
  - Added chevron icon to indicate tappability
  - Passes category name, color, year, and month to detail page
  - Location: `lib/features/statistics/presentation/widgets/category_chart_card.dart:133-203`

- **Updated router configuration**
  - Added category detail route as child of statistics route
  - Accepts parameters: categoryName, categoryColor, year, month
  - Uses MaterialPage for standard page transition
  - Location: `lib/app/router/app_router.dart:64-79`

### Technical Details

#### Modified Files
1. `lib/features/statistics/presentation/widgets/category_chart_card.dart`
   - Added year/month parameters to CategoryChartCardSyncfusion
   - Removed touch interaction code
   - Updated label formatting and styling
   - Added InkWell with navigation to category list items

2. `lib/features/statistics/presentation/pages/statistics_page.dart`
   - Passed year/month parameters to CategoryChartCardSyncfusion
   - Location: Line 280-281

3. `lib/app/router/app_router.dart`
   - Added category detail child route under statistics branch
   - Added import for CategoryDetailPage

#### New Files
1. `lib/features/statistics/presentation/pages/category_detail_page.dart`
   - ConsumerWidget for category transaction details
   - Filters transactions by category, month, and expense type
   - Formatted date display with Korean day-of-week labels

---

## [Phase 12] - 2025-12-05

### Summary
Enhanced chart visualizations with dynamic y-axis scaling and refined pie chart appearance.

### Changed

#### Line Chart Y-Axis Enhancement
- **Implemented dynamic y-axis scaling for positive values**
  - Previous: Y-axis always started at 0 for positive values, making small variations appear flat
  - New: Y-axis zooms into actual data range (min * 0.8 to max * 1.2) when all values are positive
  - Impact: ~2.6x increase in visual impact for small budget variations
  - Example: Budget range ₩45K-₩50K now displays in y-axis ₩36K-₩60K instead of 0-₩60K
  - Preserves current behavior for negative/mixed values (centered at 0)
  - Location: `lib/features/daily_budget/presentation/widgets/daily_budget_trend_chart.dart:140`

#### Pie Chart Visual Refinement
- **Added subtle spacing between pie chart slices**
  - Implemented using `strokeWidth: 2` and `strokeColor: Colors.white`
  - Creates 2-pixel white border between slices for visual separation
  - Result: More refined and premium appearance without looking tacky
  - Matches the visual quality of the previous fl_chart implementation (`sectionsSpace: 2`)
  - Location: `lib/features/statistics/presentation/widgets/category_chart_card.dart:90-91`

---

## [Phase 11] - 2025-12-05

### Summary
Migrated from fl_chart to Syncfusion Flutter Charts to add connector lines and enhanced labels to pie chart while preserving all existing functionality.

### Changed

#### Chart Library Migration
- **Migrated from fl_chart to Syncfusion Flutter Charts**
  - Package: Added `syncfusion_flutter_charts: ^31.2.16` to dependencies
  - Reason: fl_chart lacks native support for connector lines (leader lines) from pie segments to labels
  - Scope: 2 chart files only (PieChart and LineChart)
  - License: Syncfusion Community License (free for <$1M revenue, no registration key required for v18.3.0+)

#### PieChart Enhancements (Priority 1)
- **Added curved connector lines** from pie segments to outside labels
  - Implemented with `ConnectorLineSettings(type: ConnectorType.curve, length: '20%')`
  - Improves visual clarity by connecting labels to their corresponding segments
- **Enhanced labels to show category name + percentage**
  - Previous: Labels showed only percentage (e.g., "45.3%")
  - New: Labels show category name and percentage (e.g., "식비\n45.3%")
  - More informative at a glance without needing to reference the legend
- **Preserved all existing features**
  - Touch interaction (tap to explode segment)
  - Color cycling for 10+ categories
  - Category list below chart with amounts and percentages
  - Location: `lib/features/statistics/presentation/widgets/category_chart_card.dart`

#### LineChart Migration (Priority 2)
- **Migrated to Syncfusion while preserving all features**
  - Changed from `LineChart` (fl_chart) to `SfCartesianChart` (Syncfusion)
  - Used `SplineAreaSeries` to maintain gradient fill below line
  - Korean Y-axis formatting preserved (만, 천 notation)
  - Color-coded markers maintained (green/red/grey for positive/negative/zero values)
  - Implemented via `onMarkerRender` callback for per-point marker colors
  - Smooth curve rendering with `splineType: SplineType.natural`
  - Location: `lib/features/daily_budget/presentation/widgets/daily_budget_trend_chart.dart`

#### Integration Updates
- **Updated widget references** in page files
  - Statistics page: Updated to `CategoryChartCardSyncfusion`
  - Home page: Updated to `DailyBudgetTrendChartSyncfusion`

---

## [Phase 10] - 2025-12-05

### Summary
Refined incentive structure for mosaic calendar and improved pie chart label readability.

### Changed

#### Mosaic Calendar Logic Refinement
- **Updated Perfect status threshold** from no spending to ≤50% of daily budget
  - Previous: Perfect status for net spending ≤ 0 (no spending or net income)
  - New: Perfect status for net spending ≤ 50% of daily budget
  - Rationale: Creates more granular incentive by rewarding low spending, not just zero spending
  - Days spending 51-100% of budget now show Safe (Indigo-300) instead of Perfect (Indigo-700)
  - Location: `lib/features/transaction/presentation/providers/monthly_mosaic_provider.dart:100`
  - Documentation: Updated `DayStatus.perfect` comment in `lib/features/transaction/domain/models/day_status.dart:6`

#### Pie Chart Label Improvements
- **Moved percentage labels outside pie segments** to prevent text overflow
  - Added `titlePositionPercentageOffset: 1.4` parameter (positions labels 40% beyond segment edge)
  - Changed label color from white to black87 for better visibility on white background
  - Increased decimal precision from 0 to 1 decimal place (e.g., "45.3%" instead of "45%")
  - Increased chart height from 480 to 520 pixels to accommodate outside labels
  - Fixes overflow issues with narrow segments (small percentages)
  - Location: `lib/features/statistics/presentation/widgets/category_chart_card.dart`

---

## [Phase 9] - 2025-12-04

### Summary
Added Monthly Pace Mosaic - a color-coded calendar visualization in Transactions tab that shows daily spending status vs daily budget. Users can tap dates to filter transactions, providing intuitive one-step date selection UX.

### Added

#### Monthly Pace Mosaic Feature
- **Added interactive monthly calendar** to Transactions page
  - 7-column grid layout (Sunday to Saturday)
  - Color-coded day tiles based on net spending vs daily budget:
    - **Perfect** (Indigo-700): Net income or break-even (net spending ≤ 0)
    - **Safe** (Indigo-300): Within daily budget (0 < spending ≤ budget)
    - **Warning** (Amber-500): Over budget but within 1.5x (budget < spending ≤ 1.5x budget)
    - **Danger** (Rose-500): Significantly over budget (spending > 1.5x budget)
    - **Future** (Grey): Days after today
    - **No Budget** (Light Grey): No budget set or budget ≤ 0
  - Location: `lib/features/transaction/presentation/widgets/monthly_pace_mosaic.dart`

#### Month Navigation
- **Added month navigation bar** with left/right arrows
  - Navigate between months with arrow buttons
  - Displays current month as "YYYY년 M월"
  - Month change automatically resets date selection
  - Location: `lib/features/transaction/presentation/widgets/month_navigation_bar.dart`

#### Interactive Date Filtering
- **Tap date to filter transactions** to that specific day
  - Single tap selects date and filters transaction list
  - Re-tapping same date deselects and shows all transactions
  - Selected tile highlighted with border and 1.05x scale
  - Other tiles fade to 50% opacity when date selected
  - Today indicator: subtle border on current date

#### Data Layer
- **Added `getIncomeForDate()` method** to DailyBudgetService
  - Calculates income for specific date (complementing existing `getSpentForDate`)
  - Used for net spending calculation: expenses - income
  - Location: `lib/features/daily_budget/domain/services/daily_budget_service.dart:46-51`

- **Created `DayStatus` enum** for day categorization
  - Values: future, perfect, safe, warning, danger, noBudget
  - Location: `lib/features/transaction/domain/models/day_status.dart`

- **Created `MonthlyMosaicData` model**
  - `DayData`: Individual day information (date, day, isToday, isFuture, netSpent, dailyBudget, status)
  - `MonthlyMosaicSummary`: Month statistics (perfect, safe, warning, danger counts)
  - Location: `lib/features/transaction/domain/models/monthly_mosaic_data.dart`

- **Created `monthlyMosaicProvider`** for mosaic data calculation
  - Calculates day-by-day status for entire month
  - Logic: For each day D, calculate daily budget based on previous day's net spending
  - Determines status by comparing day's net spending vs its daily budget
  - Reactive to budget/transaction/month changes via Riverpod
  - Location: `lib/features/transaction/presentation/providers/monthly_mosaic_provider.dart`

### Changed

#### Transactions Page Migration
- **Migrated from Column to Sliver-based layout** for better scrolling UX
  - Old: Column + Expanded ListView
  - New: CustomScrollView with multiple Sliver components
  - Mosaic scrolls naturally with transaction list
  - Better performance for long transaction lists
  - Location: `lib/features/transaction/presentation/pages/transactions_page.dart:85-170`

- **Removed date picker button** (replaced by mosaic tap interaction)
  - Removed `_buildDateFilterButton()` method
  - Removed `_showDatePickerDialog()` method
  - Simplified date selection to direct tap on calendar

- **Updated date selection state** from `DateTime?` to `String?` (YYYY-MM-DD format)
  - Matches transaction date format for efficient filtering
  - Added `_onMosaicDateTap()` handler for tap interactions

- **Enhanced empty state messages**
  - No date selected + no filters: "거래 내역 없음"
  - Date selected but no transactions: "이 날은 거래 내역이 없어요!"
  - Search with no results: "검색 결과가 없습니다."

#### Color Theme
- **Added mosaic-specific color palette** coordinated with existing Indigo theme
  - Perfect: #4338CA (Indigo-700) - consistent with app primary dark
  - Safe: #A5B4FC (Indigo-300) - light indigo for normal status
  - Warning: #F59E0B (Amber-500) - existing warning color
  - Danger: #F43F5E (Rose-500) - existing danger color
  - Future/NoBudget: Grey tones for inactive states
  - Location: `lib/features/transaction/presentation/widgets/mosaic_colors.dart`

#### Statistics Page
- **Updated expense icon** to minus symbol (Icons.remove_circle_outline)
  - Changed from trending_down to match symmetry with income's plus symbol
  - Income: Icons.add_circle_outline (+)
  - Expense: Icons.remove_circle_outline (-)
  - Location: `lib/features/statistics/presentation/pages/statistics_page.dart:140`

#### Mosaic Calendar Refinements
- **Adjusted calendar spacing and layout**
  - Increased container height from 320px to 350px for better visual balance
  - Increased spacing between weekday header and grid from 6px to 12px
  - Fixed scale animation overlap issue when selecting dates (1.05x scale no longer overlaps weekday headers)
  - Location: `lib/features/transaction/presentation/widgets/monthly_pace_mosaic.dart:24,30`

### Removed
- **Removed MosaicSummaryBar component** for cleaner, simplified UI
  - Removed summary text showing monthly statistics (perfect/warning/danger days)
  - Removed date-specific summary bar with reset button
  - Calendar now stands as primary interaction point without redundant summary
  - Location: `lib/features/transaction/presentation/widgets/mosaic_summary_bar.dart` (deleted)

### Technical Details

#### New Files (6)
1. `lib/features/transaction/domain/models/day_status.dart` - Day status enum
2. `lib/features/transaction/domain/models/monthly_mosaic_data.dart` - Data models
3. `lib/features/transaction/presentation/providers/monthly_mosaic_provider.dart` - Provider
4. `lib/features/transaction/presentation/widgets/mosaic_colors.dart` - Color constants
5. `lib/features/transaction/presentation/widgets/month_navigation_bar.dart` - Month nav widget
6. `lib/features/transaction/presentation/widgets/monthly_pace_mosaic.dart` - Calendar widget

#### Modified Files (3)
1. `lib/features/daily_budget/domain/services/daily_budget_service.dart` - Added getIncomeForDate
2. `lib/features/transaction/presentation/pages/transactions_page.dart` - Sliver migration + mosaic integration
3. `lib/core/providers/providers.dart` - Export monthlyMosaicProvider

#### Calculation Logic
For each day D in the month:
1. Calculate `dailyBudgetForDay` using net spending until day D-1
   - Formula: `(monthlyBudget - netSpentUntilPrevDay) / remainingDays`
2. Calculate `netSpentThatDay` = expenses - income for day D
3. Determine status:
   - Future: day > today
   - Perfect: netSpentThatDay ≤ 0
   - Safe: 0 < netSpentThatDay ≤ dailyBudgetForDay
   - Warning: dailyBudgetForDay < netSpentThatDay ≤ 1.5 × dailyBudgetForDay
   - Danger: netSpentThatDay > 1.5 × dailyBudgetForDay
   - NoBudget: no budget OR dailyBudgetForDay ≤ 0

#### UI Components Structure
```
CustomScrollView
├── SliverToBoxAdapter: MonthNavigationBar
├── SliverToBoxAdapter: MonthlyPaceMosaic (7×5 grid, 350px height)
├── SliverToBoxAdapter: Filter chips (search/type)
└── SliverList/SliverFillRemaining: Transaction list
```

#### State Management
- Month change listener: `ref.listen(currentMonthProvider)` resets date selection
- Date tap handler: Toggle selection on tap
- Provider reactivity: Mosaic recalculates on budget/transaction/month changes
- Filter pipeline: Month → Date → Search/Type → Display

### Benefits

**User Experience:**
- ✅ Visual overview of spending patterns at a glance
- ✅ One-tap date filtering (no popup dialogs)
- ✅ Color-coded status helps identify problematic days
- ✅ Summary statistics provide quick insights
- ✅ Smooth scrolling with mosaic integrated in content flow

**Technical:**
- ✅ Reactive calculation with Riverpod providers
- ✅ Efficient date filtering using string comparison
- ✅ Sliver-based layout for better performance
- ✅ Modular widget structure for maintainability
- ✅ Coordinated color scheme with existing theme

### Testing Checklist

- [x] Date tap selects and filters transaction list
- [x] Re-tap deselects and shows all transactions
- [x] Month navigation resets selection
- [x] Summary bar shows correct statistics
- [x] Selected date info displays net spending
- [x] Reset button clears selection
- [x] Status colors accurate vs daily budget
- [x] Today indicator visible
- [x] Future days show grey
- [x] No budget month shows grey tiles
- [x] Empty state messages appropriate
- [x] Search/type filters work with date filter
- [x] Sliver scrolling smooth

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
