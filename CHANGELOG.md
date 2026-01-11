# Changelog

All notable changes to the DailyBudget project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Phase 31] - 2026-01-11

### Summary
Complete internationalization (i18n) support for Korean and English locales. The app now supports full multilingual UI with Flutter's official l10n system, locale-aware date/currency formatting, and YNAB-style dollar input for US users.

### Added

#### Localization Infrastructure
- `l10n.yaml` - Flutter l10n configuration
- `lib/l10n/app_en.arb` - English translations (150+ strings)
- `lib/l10n/app_ko.arb` - Korean translations (150+ strings)
- `lib/core/extensions/localization_extension.dart` - `context.l10n` helper
- `lib/core/services/locale_service.dart` - Locale access for background services
- `lib/features/settings/presentation/providers/language_provider.dart` - Language state management
- `lib/features/settings/presentation/widgets/language_section.dart` - Language selector UI

#### YNAB-Style Currency Input (USD)
- Decimal input support for English locale (e.g., `$50.50`)
- Cents-based storage for USD (50.50 dollars → 5050 stored)
- Dollar prefix display in input fields (`$ `)
- Keyboard type switches to decimal for English

#### Localized Default Categories
- New English users: Food, Transport, Shopping, Living, Hobby, Medical, Other
- New Korean users: 식비, 교통, 쇼핑, 생활, 취미, 의료, 기타
- Existing users' categories remain unchanged

### Changed

#### Locale-Aware Formatting (`formatters.dart`)
- `formatCurrency()`: KRW `123,456원` / USD `$1,234.56`
- `formatCurrencyNumber()`: Handles cents-to-dollars conversion for USD
- `formatNumberInput()`: Allows decimal input for English locale
- `parseFormattedNumber()`: Parses dollars and converts to cents for USD
- `formatDate()`: `12월 1일` / `Dec 1`
- `formatDateFull()`: `2026년 1월 11일` / `January 11, 2026`
- `formatYearMonthDisplay()`: `2026.1` / `Jan 2026`
- Added `isEnglishLocale()` public helper

#### Background Services (`locale_service.dart`)
- Notification channel names: `하루 결산` / `Daily Summary`
- Notification messages localized for both languages
- Status messages (`perfect`, `safe`, `warning`, `danger`) translated
- Currency and date formatting without BuildContext

#### UI Components Updated
All input sheets now support locale-aware formatting:
- `add_transaction_sheet.dart` - $ prefix, decimal keyboard for English
- `transaction_edit_sheet.dart` - Same updates
- `budget_settings_section.dart` - Budget input with locale support
- `recurring_modal.dart` - Recurring transaction input

#### All UI Text Localized
- Home page, Statistics, Transactions, Settings
- All dialogs, sheets, and error messages
- Category names remain user-defined (not translated)

### Technical Details

#### Dependencies Added
- `flutter_localizations` (SDK)
- `intl: ^0.20.2`

#### Key Architecture Decisions
- **Storage**: Korean stores as-is (50000), English stores cents (5050)
- **Display**: Both convert to locale-appropriate format
- **Input**: Korean integer-only, English allows decimals
- **Background**: `LocaleService` reads from SharedPreferences

#### Files Created (7)
- `l10n.yaml`
- `lib/l10n/app_en.arb`
- `lib/l10n/app_ko.arb`
- `lib/core/extensions/localization_extension.dart`
- `lib/core/services/locale_service.dart`
- `lib/features/settings/presentation/providers/language_provider.dart`
- `lib/features/settings/presentation/widgets/language_section.dart`

#### Files Modified (30+)
- `pubspec.yaml` - Added l10n dependencies
- `lib/main.dart` - MaterialApp localization setup
- `lib/core/utils/formatters.dart` - Locale-aware formatting
- `lib/core/services/notification_service.dart` - Localized notifications
- `lib/core/services/daily_summary_service.dart` - Localized summaries
- All presentation widgets updated with `context.l10n.*` calls

### References
- [YNAB Currency Entry](https://www.eshmoneycoach.com/ynab-toolkit/pos-style-currency-entry-mode/)
- [Flutter Internationalization](https://docs.flutter.dev/ui/accessibility-and-internationalization/internationalization)

---

## [Phase 30] - 2026-01-10

### Summary
Custom budget start day UX improvements and toast notification cleanup. App now properly initializes to today's budget period on startup, auto-transitions when start day changes, and displays periods (e.g., "12/25 ~ 1/24") instead of month names when start day ≠ 1. Removed unnecessary success toasts throughout the app for a cleaner UX.

### Added

#### Period-based Initialization
- `getLabelMonthForDate()` helper function in `current_month_provider.dart`
  - Calculates which "label month" a given date belongs to based on start day
  - Example: With start day 25, date 1/15 belongs to "1월" (12/25~1/24)
- `todayLabelMonthProvider` - computed provider for today's label month
- App now initializes to correct period based on configured start day

#### Auto-transition on Start Day Change
- When user changes budget start day in settings, app automatically navigates to today's period
- Eliminates confusion of viewing wrong period after changing start day

### Changed

#### UI: Period Display (Banksalad Style)
- **Home page AppBar**: Shows period instead of month when startDay ≠ 1
  - Example: "2025.12.25 ~ 1.24" instead of "2025년 1월"
- **Month navigation bar**: Same period display logic
- When startDay = 1, shows traditional "YYYY년 M월" format

#### Terminology: "월" → "기간"
- `budget_settings_section.dart`: "현재 월 예산" → Dynamic period label (e.g., "1/9~2/8 예산")
- `mosaic_summary_bar.dart`: "이번 달: 퍼펙트..." → "이번 기간: 퍼펙트..."
- `statistics_page.dart`: "이번 달 예산" → "현재 기간 예산"
- `daily_summary_service.dart`: "이번 달 진행률" → "기간 진행률"
- `recurring_section.dart`: "이번 달 반복 지출..." → "현재 기간 반복 지출..."

#### Toast Notification Cleanup
Removed unnecessary success toasts for cleaner UX. FAB button no longer covered by toasts.

**Notifications** (`notification_section.dart`):
- Removed "정확한 시간에 받으려면 알람 권한을 허용해주세요" message (exact alarm not used)
- Removed non-functional "설정" button
- Notification toggle now works silently (UI toggle feedback sufficient)
- Only shows toast when notification permission is denied

**Transactions** (`add_transaction_sheet.dart`, `transaction_edit_sheet.dart`, `transactions_page.dart`):
- Removed "거래가 추가되었습니다" toast
- Removed "거래가 수정되었습니다" toast
- Removed "거래가 삭제되었습니다" toast (confirmation dialog sufficient)

**Categories** (`category_management_section.dart`, `category_selector_sheet.dart`):
- Removed success toasts for add/edit/delete operations

**Recurring** (`recurring_modal.dart`, `recurring_section.dart`):
- Removed success toasts for add/edit/delete/toggle/regenerate operations

**Budget** (`budget_settings_section.dart`):
- Removed "예산이 수정되었습니다" toast
- Removed "예산 시작일이 N일로 변경되었습니다" toast

#### Toast Color Standardization
- Error/validation toasts: `AppColors.danger` (Rose)
- Important success toasts (data backup/restore/delete): `Theme.of(context).colorScheme.primary` (Indigo)
- General success: No toast (removed)

### Technical Details

#### Files Modified
- `lib/features/budget/presentation/providers/current_month_provider.dart`
  - Added `getLabelMonthForDate()` function
  - Added `todayLabelMonthProvider`
  - Updated `currentMonthProvider` to watch `todayLabelMonthProvider`
- `lib/features/settings/presentation/widgets/budget_settings_section.dart`
  - Auto-transition on start day change
  - Dynamic period label for budget display
  - Removed success toasts
- `lib/features/daily_budget/presentation/pages/home_page.dart`
  - Period-only display in AppBar
- `lib/features/transaction/presentation/widgets/month_navigation_bar.dart`
  - Period-only display
- `lib/features/transaction/presentation/widgets/mosaic_summary_bar.dart`
  - Terminology change
- `lib/features/statistics/presentation/pages/statistics_page.dart`
  - Terminology change
- `lib/core/services/daily_summary_service.dart`
  - Terminology change
- `lib/features/settings/presentation/widgets/recurring_section.dart`
  - Terminology change, removed success toasts
- `lib/features/settings/presentation/widgets/notification_section.dart`
  - Simplified notification enable flow, removed _showInfoSnackBar
- `lib/features/transaction/presentation/widgets/add_transaction_sheet.dart`
  - Removed success toast, error toast uses AppColors.danger
- `lib/features/transaction/presentation/widgets/transaction_edit_sheet.dart`
  - Removed success toasts for edit/delete
- `lib/features/transaction/presentation/pages/transactions_page.dart`
  - Removed delete success toast
- `lib/features/settings/presentation/widgets/category_management_section.dart`
  - Removed success toasts, error toasts use AppColors.danger
- `lib/features/transaction/presentation/widgets/category_selector_sheet.dart`
  - Removed success toasts
- `lib/features/settings/presentation/widgets/recurring_modal.dart`
  - Removed success toasts, error toasts use AppColors.danger
- `lib/features/settings/presentation/widgets/data_management_section.dart`
  - Changed success toast color to primary, error to AppColors.danger

#### New Files
- `lib/core/utils/date_range_extension.dart` - Period calculation utilities
- `lib/features/settings/presentation/providers/budget_start_day_provider.dart` - Start day state management
- `test/core/utils/date_range_extension_test.dart` - Unit tests for period calculations

### Fixed

#### Daily Budget Trend Chart for Custom Periods
- **Problem**: When period spans two months (e.g., 12/25~1/24), X-axis showed non-sequential values (25, 26, ..., 31, 1, 2, ...) causing chart rendering issues
- **Solution**: Separated internal ordering from display
  - `dayIndex`: Sequential period index (1, 2, 3, ...) for X-axis ordering
  - `dateLabel`: Actual date display (e.g., "1/9", "12/25") for labels and tooltips
- `DailyBudgetHistoryItem` model updated with both fields
- Chart now correctly shows date labels like "1/3", "1/4", ..., "1/9" for 1-week view
- Tooltips show actual dates with amounts (e.g., "1/9\n32,000원")

#### Chart X-axis Rendering for 2-week+ Views
- **Problem**: NumericAxis with non-zero starting dayIndex (e.g., 17-30 for 2-week view) caused chart to render incorrectly ("spread out")
- **Solution**: Changed from `NumericAxis` to `CategoryAxis`
  - Data points now evenly distributed regardless of dayIndex values
  - X-axis uses `dateLabel` strings directly
  - Works correctly for all period lengths (1-week, 2-week, 1-month)

### Testing
- All 19 unit tests pass for date range extension
- Build successful (arm64-v8a: 24.4MB)

---

## [Phase 29.2] - 2026-01-09

### Summary
Android Play Store v1.0.4+7 release - removed exact alarm permissions and fixed app size issue.

### Fixed

#### USE_EXACT_ALARM Permission Removal
- Removed `SCHEDULE_EXACT_ALARM` and `USE_EXACT_ALARM` permissions
- Added `tools:node="remove"` to prevent flutter_local_notifications from re-adding them
- Fixes Play Store policy compliance issue

#### App Bundle Size Optimization
- Removed `keepDebugSymbols` packaging option that was inflating bundle size
- Reduced bundle size from ~133MB to ~52MB

### Changed

#### Version Update
- Updated to v1.0.4+7 for Play Store release

### Developer Environment (macOS)
- Added Android Studio installation via Homebrew
- Configured ANDROID_HOME and JAVA_HOME in ~/.zshrc
- Set up release keystore for signing

### Files Modified
- `android/app/src/main/AndroidManifest.xml` - Added tools:node="remove" for exact alarm permissions
- `android/app/build.gradle.kts` - Removed keepDebugSymbols packaging option
- `android/local.properties` - Updated version code to 7
- `android/key.properties` - Release signing configuration
- `pubspec.yaml` - Updated to 1.0.4+7

---

## [Phase 29.1] - 2026-01-04

### Summary
iOS App Store release preparation - platform-specific AdMob configuration and iPhone-only build.

### Fixed

#### iOS AdMob Banner Ads (v1.0.3+1)
- Added iOS-specific banner ad unit ID
- iOS: `ca-app-pub-1068771440265964/2807336510`
- Android: `ca-app-pub-1068771440265964/1240692725`
- Uses `Platform.isIOS` to select correct ad unit

### Changed

#### iPhone Only Build (v1.0.2+8)
- Changed `TARGETED_DEVICE_FAMILY` from `1,2` to `1` (iPhone only)
- Removed iPad orientation settings from Info.plist
- Eliminates iPad screenshot requirement for App Store submission

### Files Modified
- `lib/core/services/ad_service.dart`
- `ios/Runner.xcodeproj/project.pbxproj`
- `ios/Runner/Info.plist`
- `docs/index.html` (updated support page)

---

## [Phase 29] - 2026-01-02

### Summary
iOS App Store submission preparation - fixed iOS-specific UX issues and added required privacy descriptions.

### Fixed

#### iOS Keyboard Dismiss (v1.0.2+6)
- Added `GestureDetector` to dismiss keyboard when tapping outside text fields
- Applied to: Settings page (budget input), Add transaction sheet, Recurring modal
- iOS doesn't have a native keyboard dismiss button like Android

#### iOS Share Sheet Error (v1.0.2+7)
- Added `sharePositionOrigin` parameter to `Share.shareXFiles`
- Required for iOS (especially iPad) where share sheet displays as popover
- Fixed error: "sharePositionOrigin: argument must be set"

### Added

#### App Store Compliance
- Added `NSPhotoLibraryUsageDescription` to iOS Info.plist for App Store requirements
- Added iOS CI/CD pipeline with Codemagic for automated builds
- Added iOS AdMob App ID configuration

### Files Modified
- `lib/features/settings/presentation/pages/settings_page.dart`
- `lib/features/settings/presentation/widgets/recurring_modal.dart`
- `lib/features/transaction/presentation/widgets/add_transaction_sheet.dart`
- `lib/features/settings/presentation/widgets/data_management_section.dart`
- `ios/Runner/Info.plist`
- `codemagic.yaml`

---

## [Phase 28] - 2025-12-28

### Summary
Migration to isar_community for Android 16KB page size support (Google Play requirement).

### Changed

#### Database Migration (v1.0.2+4)
- Migrated from `isar` 3.1.0+1 to `isar_community` 3.3.0
- Migrated from `isar_flutter_libs` to `isar_community_flutter_libs`
- Migrated from `isar_generator` to `isar_community_generator`

#### Why This Migration
- Google Play requires 16KB page size support starting November 2025
- Original Isar package has open issue (#1699) for 16KB support
- isar_community fork provides 16KB-aligned native libraries

#### Files Modified
- `pubspec.yaml`: Updated dependencies
- 9 Dart files: Updated imports from `package:isar/isar.dart` to `package:isar_community/isar.dart`
  - `lib/core/providers/isar_provider.dart`
  - `lib/core/utils/data_backup.dart`
  - `lib/features/budget/data/models/budget_model.dart`
  - `lib/features/budget/presentation/providers/budget_provider.dart`
  - `lib/features/recurring/data/models/recurring_transaction_model.dart`
  - `lib/features/recurring/presentation/providers/recurring_provider.dart`
  - `lib/features/settings/presentation/providers/categories_provider.dart`
  - `lib/features/transaction/data/models/transaction_model.dart`
  - `lib/features/transaction/data/repositories/isar_transaction_repository.dart`

### Technical Notes
- All APKs pass `zipalign -c -P 16 -v 4` verification
- AAB size: 51.3MB (slight reduction from previous)
- No API changes - isar_community maintains full compatibility with original Isar

### Verification
```bash
# 16KB alignment check (all passed)
zipalign -c -P 16 -v 4 app-arm64-v8a-release.apk  # Verification successful
zipalign -c -P 16 -v 4 app-armeabi-v7a-release.apk  # Verification successful
zipalign -c -P 16 -v 4 app-x86_64-release.apk  # Verification successful
```

---

## [Phase 27.1] - 2025-12-13

### Summary
AdMob banner ad placement optimization for better viewability and revenue.

### Changed

#### Banner Ad Placement (v1.0.1+3)
- Moved banner from scroll content to fixed bottom position on all tabs
- Banner now visible without scrolling (improves Active View metrics)
- Added banner to all 4 tabs: Home, Transactions, Statistics, Settings

#### Files Modified
- `lib/features/daily_budget/presentation/pages/home_page.dart`
- `lib/features/transaction/presentation/pages/transactions_page.dart`
- `lib/features/statistics/presentation/pages/statistics_page.dart`
- `lib/features/settings/presentation/pages/settings_page.dart`

### Technical Notes
- Used `Column` + `Expanded` + `SafeArea` pattern for fixed bottom banner
- Each tab loads its own banner (new impression on tab switch)
- AdMob auto-refresh (60s) handles same-tab impressions

---

## [Phase 27] - 2025-12-12

### Summary
Architecture review and P0 refactoring: DRY principle compliance, centralized constants, and DayStatus enum enhancement.

### Added

#### Architecture Review Documents (PR #11)
- `docs/ARCHITECTURE_REVIEW_ERICH_GAMMA.md`: GoF patterns and SOLID principles analysis
- `docs/ARCHITECTURE_REVIEW_MARTIN_FOWLER.md`: Code smells and pragmatic refactoring approach
- `docs/ARCHITECTURE_REVIEW_REMI_ROUSSELET.md`: Riverpod creator's Flutter-specific perspective

#### New Files
- `lib/core/constants/budget_constants.dart`: Centralized `BudgetThresholds` (0.5, 1.0, 1.5) and `CategoryConstants`

### Changed

#### DayStatus Enum Enhancement (PR #11)
- Added properties directly to `DayStatus` enum: `backgroundColor`, `textColor`, `cardColor`, `icon`, `message`
- `MosaicColors` now delegates to `DayStatus` properties (backward compatible)
- `YesterdaySummary` now delegates to `DayStatus` for color/icon/message

#### Centralized Status Calculation (PR #11)
- `DailySummaryService.calculateStatus()` now uses `BudgetThresholds` constants
- Removed ~20 lines of duplicate status logic from `monthly_mosaic_provider.dart`
- Removed ~12 lines of duplicate status logic from `yesterday_summary_card.dart`

#### Formatters Utility (PR #11)
- Added `Formatters.formatYearMonth(year, month)` for YYYY-MM formatting
- Applied to 5 files: `monthly_mosaic_provider`, `yesterday_summary_card`, `isar_transaction_repository`, `transaction_provider`, `recurring_service`

### Results
- ~80 lines of duplicate code removed
- ~40 lines of utilities/constants added
- Net reduction: ~40 lines
- Single source of truth for status thresholds and date formatting

---

## [Phase 26] - 2025-12-12

### Summary
Calculator button design refinement for clearer visual separation.

### Changed

#### Calculator Button Border
- Added 1px border to all calculator buttons for clear edge definition
- Border color uses theme's outline color with 25% opacity
- Reduced border radius from 14 to 12 for cleaner appearance
- Adjusted button padding from 5 to 4 for slightly larger buttons
- Removed shadow effect (now using border instead)

---

## [Phase 25.4] - 2025-12-11

### Summary
UI consistency improvements for colors and symbols across the app.

### Changed

#### Standardize UI Colors and Symbols (PR #10)
- Income items now display in green (was indigo/primary)
- Added minus sign (-) to daily net spending total for symmetry with income (+)
- Follows standard finance app pattern: expense=red(-), income=green(+)

#### Calculator Design Review (PR #9)
- Enhanced visibility: white text on AC/operator buttons, larger font sizes
- Unified 4-column grid layout (added %, . buttons)
- Adjusted info hierarchy: toned down = button, emphasized confirm button
- Replaced backspace character with filled rounded icon
- Applied soft shadows (6% opacity, 8px blur)
- Increased padding for better spacing

---

## [Phase 25.3] - 2025-12-11

### Summary
Calculator feature and AdMob integration for monetization.

### Added

#### Calculator Feature (PR #8)
- New `CalculatorSheet` widget with basic arithmetic operations (+, -, ×, ÷)
- Support AC (clear all), backspace, and equals functions
- Display running calculation with formatted numbers
- Calculator button added to `AddTransactionSheet` amount field
- Calculator button added to `TransactionEditModalSheet` amount field
- Calculator opens with current amount as initial value
- Calculated result automatically applied to amount field

#### AdMob Integration (PR #7)
- Added `google_mobile_ads` package (v5.3.1)
- Added AdMob App ID to AndroidManifest.xml
- Created `AdService` class for ad management
- Created `BannerAdWidget` for displaying banner ads
- Initialized AdMob SDK in main.dart
- Added banner ad to home page bottom
- Uses test ad ID in debug mode for account safety

---

## [Phase 25.2] - 2025-12-10

### Summary
Unified net spending display across all screens for consistency.

### Changed

#### Unify Spending Display (PR #6)
- Home tab: "오늘 지출" card now shows net spending (expenses - income)
- Transactions tab: Daily totals now show net spending instead of total expenses
- Statistics tab: Budget usage card now based on net spending
- Added `getNetSpentForDate()` helper method in `DailyBudgetService`
- All screens handle negative net spending (income > expenses) with green color, + sign, and "순수입" label

---

## [Phase 25.1] - 2025-12-10

### Summary
Korean localization for date picker calendar.

### Added

#### Korean Locale Support (PR #5)
- Added `flutter_localizations` package to pubspec.yaml
- Configured MaterialApp with Korean locale (ko_KR)
- Added localization delegates for Material, Widgets, and Cupertino
- Date picker calendar now displays in Korean

---

## [Phase 25] - 2025-12-09

### Summary
Backup/restore now includes category data. App refresh logic improved for notification time check.

### Fixed

#### Backup/Restore Category Data (PR #3)
- Categories stored in SharedPreferences were not included in backup/restore
- Added categories to backup JSON export (version bumped to 1.1.0)
- Restores categories from backup file to SharedPreferences
- Resets categories to defaults when clearing all data
- Shows category count in restore success message

#### App Refresh on Resume (PR #4)
- Invalidate `shouldShowYesterdaySummaryProvider` when app resumes from background
- Ensures yesterday summary card appears after configured notification time

---

## [Phase 24] - 2025-12-09

### Summary
Daily notification feature with yesterday's spending summary. Fixed critical bug in flutter_local_notifications v17.x causing scheduled notifications to fail on real devices.

### Added

#### Daily Summary Notification
- Scheduled notifications at user-configured time
- Yesterday's spending summary card on home page
- Notification settings UI in settings page
  - Toggle to enable/disable notifications
  - Time picker for notification time
- Automatic permission handling (Android 13+ notification permission, Android 12+ exact alarm permission)

#### Date Change Detection
- App automatically refreshes data when date changes
- Detects date change when app resumes from background
- Uses `WidgetsBindingObserver` lifecycle hooks

### Fixed

#### Critical: flutter_local_notifications v17.x Bug
- **Problem**: "Missing type parameter" error on real Samsung devices
- **Symptom**: `zonedSchedule()`, `cancel()`, `pendingNotificationRequests()` all failed
- **Root Cause**: Bug in flutter_local_notifications v17.x
- **Solution**: Upgraded to v19.5.0

### Changed

#### Dependencies
- `flutter_local_notifications`: ^17.2.2 → ^19.0.0
- `timezone`: ^0.9.4 → ^0.10.0
- `desugar_jdk_libs`: 2.0.4 → 2.1.4 (Android)

#### API Updates for v19
- Removed deprecated `uiLocalNotificationDateInterpretation` parameter from `zonedSchedule()`

### Technical Details
- **New files**:
  - `lib/core/services/notification_service.dart` - Notification scheduling
  - `lib/core/services/daily_summary_service.dart` - Summary data model
  - `lib/features/settings/presentation/providers/notification_settings_provider.dart`
  - `lib/features/settings/presentation/widgets/notification_section.dart`
  - `lib/features/daily_budget/presentation/widgets/yesterday_summary_card.dart`
  - `lib/core/providers/date_provider.dart` - Date change detection
- **Modified files**:
  - `android/app/src/main/AndroidManifest.xml` - Notification permissions & receivers
  - `android/app/build.gradle.kts` - desugar_jdk_libs version
  - `lib/main.dart` - Lifecycle observer
  - `pubspec.yaml` - Updated dependencies

---

## [Phase 23] - 2025-12-07

### Summary
Code quality improvements based on AI-assisted codebase diagnosis (Gemini + Codex + Claude Opus cross-validation). Enhanced type safety, fixed async handling, and removed dead code.

### Fixed

#### Async Handling Bug in RecurringModal
- `_handleSave()` was not awaiting async operations
- Success snackbar could show before operation completed
- Error handling was not catching failures
- Now properly uses `async/await` with try/catch

### Changed

#### Type Safety Improvements
- **RecurringNotifier.updateRecurringTransaction**:
  - Changed from `Map<String, dynamic>` to `RecurringTransactionModel`
  - Compile-time type checking instead of runtime casting
  - Added `rethrow` for proper error propagation

- **TransactionEditSheet._handleUpdate**:
  - Changed from `Map<String, dynamic>` to `TransactionModel`
  - Consistent with existing `TransactionNotifier` API

### Removed

#### Dead Code
- `quick_add_card.dart` - Widget was never imported or used in codebase
- Unused import in `transaction_provider.dart`

### Technical Details
- **Files modified**: 4 files
  - `lib/features/recurring/presentation/providers/recurring_provider.dart`
  - `lib/features/settings/presentation/widgets/recurring_modal.dart`
  - `lib/features/transaction/presentation/widgets/transaction_edit_sheet.dart`
  - `lib/features/transaction/presentation/providers/transaction_provider.dart`
- **Files deleted**: 1 file
  - `lib/features/daily_budget/presentation/widgets/quick_add_card.dart`

---

## [Phase 22] - 2025-12-07

### Summary
Comprehensive codebase review and cleanup. Fixed critical bug in daily budget calculation, removed unused dependencies, improved theme consistency, and enhanced error handling.

### Fixed

#### Daily Budget Provider Date Calculation Bug
- **Past month viewing**: Now correctly uses last day of the month instead of current day
- **Future month viewing**: Now uses first day of the month
- **Current month**: Correctly uses today's date
- Previously: Viewing November on Dec 31 would create invalid date `DateTime(2025, 11, 31)` → Dec 1

### Removed

#### Unused Dependencies
- **fl_chart**: Removed from `pubspec.yaml` (Syncfusion migration completed in Phase 11)

#### Orphaned Files
- `daily_budget_trend_chart_original.dart` - fl_chart backup
- `daily_budget_trend_chart_flchart.dart.bak` - fl_chart backup
- `category_chart_card_original.dart` - fl_chart backup

### Changed

#### App Title
- Updated from "Daily Pace" to "DailyBudget" in `main.dart`

#### Theme Consistency (13 files, 65+ instances)
- Replaced hardcoded `Colors.grey[xxx]` with `AppColors` constants
- `Colors.grey[400]` → `AppColors.textTertiary`
- `Colors.grey[500-700]` → `AppColors.textSecondary`
- `Colors.grey[200-300]` → `AppColors.border`
- `Colors.grey[50-100]` → `AppColors.surfaceVariant` / `AppColors.borderLight`

#### Error Handling
- Changed `print()` to `debugPrint()` in 4 provider files
- `debugPrint()` is automatically stripped in release builds

### Technical Details
- **Files modified**: ~25 files
- **Dependencies removed**: fl_chart (APK size reduced)
- **Build verified**: `flutter analyze` (0 errors), `flutter build apk --release` (success)

### Files Modified
- `lib/features/daily_budget/presentation/providers/daily_budget_provider.dart`
- `lib/main.dart`
- `pubspec.yaml`
- `lib/features/settings/presentation/widgets/*.dart`
- `lib/features/daily_budget/presentation/widgets/*.dart`
- `lib/features/transaction/presentation/widgets/*.dart`
- `lib/features/statistics/presentation/**/*.dart`
- `lib/features/budget/presentation/providers/budget_provider.dart`
- `lib/features/transaction/presentation/providers/transaction_provider.dart`
- `lib/features/recurring/presentation/providers/recurring_provider.dart`

---

## [Phase 21] - 2025-12-07

### Summary
Added custom app icon using flutter_launcher_icons package.

### Added

#### App Icon
- **Custom app icon**: Chart/graph icon with indigo background matching app theme
- **flutter_launcher_icons**: Added package for automatic icon generation
- **Multi-platform support**: Icons generated for Android (all densities + adaptive icon), iOS, and Windows

### Technical Details
- Package: `flutter_launcher_icons: ^0.14.3`
- Source image: `assets/icon/app_icon.png`
- Adaptive icon background: `#5C6BC0` (Indigo-400)

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
