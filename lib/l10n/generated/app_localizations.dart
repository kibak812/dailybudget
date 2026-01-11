import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_add;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_search;

  /// No description provided for @common_reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get common_reset;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get nav_transactions;

  /// No description provided for @nav_statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get nav_statistics;

  /// No description provided for @nav_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get nav_settings;

  /// No description provided for @home_todayBudget.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Available Budget'**
  String get home_todayBudget;

  /// No description provided for @home_setBudget.
  ///
  /// In en, this message translates to:
  /// **'Please set a budget'**
  String get home_setBudget;

  /// No description provided for @home_setBudgetDesc.
  ///
  /// In en, this message translates to:
  /// **'Set a budget to see\nyour daily available amount'**
  String get home_setBudgetDesc;

  /// No description provided for @home_setBudgetButton.
  ///
  /// In en, this message translates to:
  /// **'Set Budget'**
  String get home_setBudgetButton;

  /// No description provided for @home_previousMonth.
  ///
  /// In en, this message translates to:
  /// **'Previous month'**
  String get home_previousMonth;

  /// No description provided for @home_nextMonth.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get home_nextMonth;

  /// No description provided for @home_addTransaction.
  ///
  /// In en, this message translates to:
  /// **'Add transaction'**
  String get home_addTransaction;

  /// No description provided for @budget_monthlyBudget.
  ///
  /// In en, this message translates to:
  /// **'Monthly Budget'**
  String get budget_monthlyBudget;

  /// No description provided for @budget_daysRemaining.
  ///
  /// In en, this message translates to:
  /// **'{days} days left'**
  String budget_daysRemaining(int days);

  /// No description provided for @budget_budgetAmount.
  ///
  /// In en, this message translates to:
  /// **'Budget {amount}'**
  String budget_budgetAmount(String amount);

  /// No description provided for @budget_monthBudget.
  ///
  /// In en, this message translates to:
  /// **'{month} Budget'**
  String budget_monthBudget(int month);

  /// No description provided for @budget_budgetSettings.
  ///
  /// In en, this message translates to:
  /// **'Budget Settings'**
  String get budget_budgetSettings;

  /// No description provided for @budget_periodSettings.
  ///
  /// In en, this message translates to:
  /// **'Budget Period Settings'**
  String get budget_periodSettings;

  /// No description provided for @budget_startDay.
  ///
  /// In en, this message translates to:
  /// **'Budget Start Day'**
  String get budget_startDay;

  /// No description provided for @budget_startDayDesc.
  ///
  /// In en, this message translates to:
  /// **'Day {day} of each month'**
  String budget_startDayDesc(int day);

  /// No description provided for @budget_startDayHint.
  ///
  /// In en, this message translates to:
  /// **'Monthly budget resets on this day'**
  String get budget_startDayHint;

  /// No description provided for @budget_notSet.
  ///
  /// In en, this message translates to:
  /// **'Not Set'**
  String get budget_notSet;

  /// No description provided for @budget_enterNewAmount.
  ///
  /// In en, this message translates to:
  /// **'Enter new budget amount'**
  String get budget_enterNewAmount;

  /// No description provided for @budget_monthlyStartDay.
  ///
  /// In en, this message translates to:
  /// **'Monthly Start Day'**
  String get budget_monthlyStartDay;

  /// No description provided for @budget_dayDefault.
  ///
  /// In en, this message translates to:
  /// **'Day {day} (Default)'**
  String budget_dayDefault(int day);

  /// No description provided for @budget_dayFormat.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String budget_dayFormat(int day);

  /// No description provided for @budget_startDayExplain.
  ///
  /// In en, this message translates to:
  /// **'Set a budget start day (like payday) to calculate the budget period from that date to the day before next month\'s start.'**
  String get budget_startDayExplain;

  /// No description provided for @budget_selectStartDay.
  ///
  /// In en, this message translates to:
  /// **'Select Budget Start Day'**
  String get budget_selectStartDay;

  /// No description provided for @today_netIncome.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Net Income'**
  String get today_netIncome;

  /// No description provided for @today_netExpense.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Net Expense'**
  String get today_netExpense;

  /// No description provided for @today_overBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget today'**
  String get today_overBudget;

  /// No description provided for @today_remaining.
  ///
  /// In en, this message translates to:
  /// **'Remaining today'**
  String get today_remaining;

  /// No description provided for @yesterday_summary.
  ///
  /// In en, this message translates to:
  /// **'{month}/{day} Summary'**
  String yesterday_summary(int month, int day);

  /// No description provided for @yesterday_budget.
  ///
  /// In en, this message translates to:
  /// **'Budget'**
  String get yesterday_budget;

  /// No description provided for @yesterday_expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get yesterday_expense;

  /// No description provided for @yesterday_savingsRate.
  ///
  /// In en, this message translates to:
  /// **'Savings Rate'**
  String get yesterday_savingsRate;

  /// No description provided for @trend_title.
  ///
  /// In en, this message translates to:
  /// **'Daily Budget Trend'**
  String get trend_title;

  /// No description provided for @trend_1week.
  ///
  /// In en, this message translates to:
  /// **'1W'**
  String get trend_1week;

  /// No description provided for @trend_2weeks.
  ///
  /// In en, this message translates to:
  /// **'2W'**
  String get trend_2weeks;

  /// No description provided for @trend_1month.
  ///
  /// In en, this message translates to:
  /// **'1M'**
  String get trend_1month;

  /// No description provided for @transaction_addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Transaction'**
  String get transaction_addTitle;

  /// No description provided for @transaction_editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Transaction'**
  String get transaction_editTitle;

  /// No description provided for @transaction_detailTitle.
  ///
  /// In en, this message translates to:
  /// **'Transaction Details'**
  String get transaction_detailTitle;

  /// No description provided for @transaction_expense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get transaction_expense;

  /// No description provided for @transaction_income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transaction_income;

  /// No description provided for @transaction_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get transaction_amount;

  /// No description provided for @transaction_amountHint.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get transaction_amountHint;

  /// No description provided for @transaction_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get transaction_category;

  /// No description provided for @transaction_categoryOptional.
  ///
  /// In en, this message translates to:
  /// **'Category (Optional)'**
  String get transaction_categoryOptional;

  /// No description provided for @transaction_categorySelect.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get transaction_categorySelect;

  /// No description provided for @transaction_memo.
  ///
  /// In en, this message translates to:
  /// **'Memo (Optional)'**
  String get transaction_memo;

  /// No description provided for @transaction_memoHint.
  ///
  /// In en, this message translates to:
  /// **'Enter memo'**
  String get transaction_memoHint;

  /// No description provided for @transaction_date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get transaction_date;

  /// No description provided for @transaction_dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date: {date}'**
  String transaction_dateLabel(String date);

  /// No description provided for @transaction_createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created at'**
  String get transaction_createdAt;

  /// No description provided for @transaction_isRecurring.
  ///
  /// In en, this message translates to:
  /// **'Recurring Transaction'**
  String get transaction_isRecurring;

  /// No description provided for @transaction_addButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get transaction_addButton;

  /// No description provided for @transaction_editButton.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get transaction_editButton;

  /// No description provided for @transaction_uncategorized.
  ///
  /// In en, this message translates to:
  /// **'Uncategorized'**
  String get transaction_uncategorized;

  /// No description provided for @transaction_deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Transaction'**
  String get transaction_deleteTitle;

  /// No description provided for @transaction_deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this transaction?'**
  String get transaction_deleteMessage;

  /// No description provided for @calculator_title.
  ///
  /// In en, this message translates to:
  /// **'Calculator'**
  String get calculator_title;

  /// No description provided for @calculator_result.
  ///
  /// In en, this message translates to:
  /// **'{result} won'**
  String calculator_result(String result);

  /// No description provided for @category_title.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get category_title;

  /// No description provided for @category_expense.
  ///
  /// In en, this message translates to:
  /// **'Expense Categories'**
  String get category_expense;

  /// No description provided for @category_income.
  ///
  /// In en, this message translates to:
  /// **'Income Categories'**
  String get category_income;

  /// No description provided for @category_add.
  ///
  /// In en, this message translates to:
  /// **'Add new category'**
  String get category_add;

  /// No description provided for @category_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get category_edit;

  /// No description provided for @category_editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Category'**
  String get category_editTitle;

  /// No description provided for @category_name.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get category_name;

  /// No description provided for @category_empty.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get category_empty;

  /// No description provided for @category_deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Category'**
  String get category_deleteTitle;

  /// No description provided for @category_deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete \"{category}\"?'**
  String category_deleteMessage(String category);

  /// No description provided for @category_food.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get category_food;

  /// No description provided for @category_transport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get category_transport;

  /// No description provided for @category_shopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get category_shopping;

  /// No description provided for @category_living.
  ///
  /// In en, this message translates to:
  /// **'Living'**
  String get category_living;

  /// No description provided for @category_hobby.
  ///
  /// In en, this message translates to:
  /// **'Hobby'**
  String get category_hobby;

  /// No description provided for @category_medical.
  ///
  /// In en, this message translates to:
  /// **'Medical'**
  String get category_medical;

  /// No description provided for @category_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get category_other;

  /// No description provided for @category_salary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get category_salary;

  /// No description provided for @category_allowance.
  ///
  /// In en, this message translates to:
  /// **'Allowance'**
  String get category_allowance;

  /// No description provided for @category_bonus.
  ///
  /// In en, this message translates to:
  /// **'Bonus'**
  String get category_bonus;

  /// No description provided for @statistics_title.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics_title;

  /// No description provided for @statistics_totalExpense.
  ///
  /// In en, this message translates to:
  /// **'Total Expense'**
  String get statistics_totalExpense;

  /// No description provided for @statistics_categoryDetail.
  ///
  /// In en, this message translates to:
  /// **'{category} Expense History'**
  String statistics_categoryDetail(String category);

  /// No description provided for @statistics_yearMonth.
  ///
  /// In en, this message translates to:
  /// **'{year}.{month}'**
  String statistics_yearMonth(int year, int month);

  /// No description provided for @settings_title.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings_title;

  /// No description provided for @notification_title.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notification_title;

  /// No description provided for @notification_dailySummary.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary Notification'**
  String get notification_dailySummary;

  /// No description provided for @notification_dailySummaryDesc.
  ///
  /// In en, this message translates to:
  /// **'Get notified about yesterday\'s spending at your set time'**
  String get notification_dailySummaryDesc;

  /// No description provided for @notification_time.
  ///
  /// In en, this message translates to:
  /// **'Notification Time'**
  String get notification_time;

  /// No description provided for @notification_timeSelect.
  ///
  /// In en, this message translates to:
  /// **'Select notification time'**
  String get notification_timeSelect;

  /// No description provided for @notification_permissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Notification permission required. Please allow it in settings.'**
  String get notification_permissionRequired;

  /// No description provided for @notification_requestAgain.
  ///
  /// In en, this message translates to:
  /// **'Request Again'**
  String get notification_requestAgain;

  /// No description provided for @notification_am.
  ///
  /// In en, this message translates to:
  /// **'AM'**
  String get notification_am;

  /// No description provided for @notification_pm.
  ///
  /// In en, this message translates to:
  /// **'PM'**
  String get notification_pm;

  /// No description provided for @notification_hour.
  ///
  /// In en, this message translates to:
  /// **'Hour'**
  String get notification_hour;

  /// No description provided for @notification_minute.
  ///
  /// In en, this message translates to:
  /// **'Minute'**
  String get notification_minute;

  /// No description provided for @notification_channelName.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary'**
  String get notification_channelName;

  /// No description provided for @notification_channelDesc.
  ///
  /// In en, this message translates to:
  /// **'Daily spending summary notifications at your set time'**
  String get notification_channelDesc;

  /// No description provided for @notification_pushTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Summary'**
  String get notification_pushTitle;

  /// No description provided for @notification_pushBody.
  ///
  /// In en, this message translates to:
  /// **'Check yesterday\'s spending'**
  String get notification_pushBody;

  /// No description provided for @recurring_title.
  ///
  /// In en, this message translates to:
  /// **'Recurring'**
  String get recurring_title;

  /// No description provided for @recurring_addTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Recurring'**
  String get recurring_addTitle;

  /// No description provided for @recurring_editTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Recurring'**
  String get recurring_editTitle;

  /// No description provided for @recurring_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get recurring_add;

  /// No description provided for @recurring_empty.
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions'**
  String get recurring_empty;

  /// No description provided for @recurring_regenerate.
  ///
  /// In en, this message translates to:
  /// **'Regenerate recurring for current period'**
  String get recurring_regenerate;

  /// No description provided for @recurring_type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get recurring_type;

  /// No description provided for @recurring_amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get recurring_amount;

  /// No description provided for @recurring_dayOfMonth.
  ///
  /// In en, this message translates to:
  /// **'Day of Month'**
  String get recurring_dayOfMonth;

  /// No description provided for @recurring_dayOfMonthHint.
  ///
  /// In en, this message translates to:
  /// **'1-31'**
  String get recurring_dayOfMonthHint;

  /// No description provided for @recurring_memo.
  ///
  /// In en, this message translates to:
  /// **'Memo'**
  String get recurring_memo;

  /// No description provided for @recurring_enabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get recurring_enabled;

  /// No description provided for @recurring_deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Recurring'**
  String get recurring_deleteTitle;

  /// No description provided for @recurring_deleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this recurring transaction?'**
  String get recurring_deleteMessage;

  /// No description provided for @recurring_example.
  ///
  /// In en, this message translates to:
  /// **'e.g., Rent'**
  String get recurring_example;

  /// No description provided for @recurring_amountExample.
  ///
  /// In en, this message translates to:
  /// **'e.g., 500,000'**
  String get recurring_amountExample;

  /// No description provided for @recurring_monthly.
  ///
  /// In en, this message translates to:
  /// **'monthly'**
  String get recurring_monthly;

  /// No description provided for @recurring_active.
  ///
  /// In en, this message translates to:
  /// **'active'**
  String get recurring_active;

  /// No description provided for @recurring_inactive.
  ///
  /// In en, this message translates to:
  /// **'inactive'**
  String get recurring_inactive;

  /// No description provided for @data_title.
  ///
  /// In en, this message translates to:
  /// **'Data Management'**
  String get data_title;

  /// No description provided for @data_backup.
  ///
  /// In en, this message translates to:
  /// **'Backup Data'**
  String get data_backup;

  /// No description provided for @data_backupDesc.
  ///
  /// In en, this message translates to:
  /// **'Save current data to file'**
  String get data_backupDesc;

  /// No description provided for @data_restore.
  ///
  /// In en, this message translates to:
  /// **'Restore Data'**
  String get data_restore;

  /// No description provided for @data_restoreDesc.
  ///
  /// In en, this message translates to:
  /// **'Load backup file'**
  String get data_restoreDesc;

  /// No description provided for @data_deleteAll.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get data_deleteAll;

  /// No description provided for @data_deleteAllDesc.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone'**
  String get data_deleteAllDesc;

  /// No description provided for @data_hint.
  ///
  /// In en, this message translates to:
  /// **'Data is securely stored on device. Back up regularly as data is lost when app is deleted.'**
  String get data_hint;

  /// No description provided for @data_exportSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data exported successfully.'**
  String get data_exportSuccess;

  /// No description provided for @data_exportError.
  ///
  /// In en, this message translates to:
  /// **'Failed to export data: {error}'**
  String data_exportError(String error);

  /// No description provided for @data_importSuccess.
  ///
  /// In en, this message translates to:
  /// **'Data imported!\nBudgets: {budgets}, Transactions: {transactions}, Recurring: {recurring}'**
  String data_importSuccess(int budgets, int transactions, int recurring);

  /// No description provided for @data_importError.
  ///
  /// In en, this message translates to:
  /// **'Failed to import data: {error}'**
  String data_importError(String error);

  /// No description provided for @data_deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete All Data'**
  String get data_deleteConfirm;

  /// No description provided for @data_deleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete all data?\nThis action cannot be undone.'**
  String get data_deleteConfirmMessage;

  /// No description provided for @data_deleteDoubleConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm Again'**
  String get data_deleteDoubleConfirm;

  /// No description provided for @data_deleteDoubleConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Please confirm once more. Are you sure you want to delete?'**
  String get data_deleteDoubleConfirmMessage;

  /// No description provided for @data_deleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'All data has been deleted.'**
  String get data_deleteSuccess;

  /// No description provided for @data_deleteError.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete data: {error}'**
  String data_deleteError(String error);

  /// No description provided for @data_backupSubject.
  ///
  /// In en, this message translates to:
  /// **'DailyBudget Backup'**
  String get data_backupSubject;

  /// No description provided for @data_backupText.
  ///
  /// In en, this message translates to:
  /// **'Data backup file'**
  String get data_backupText;

  /// No description provided for @language_title.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language_title;

  /// No description provided for @language_system.
  ///
  /// In en, this message translates to:
  /// **'System Default'**
  String get language_system;

  /// No description provided for @language_korean.
  ///
  /// In en, this message translates to:
  /// **'Korean'**
  String get language_korean;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @error_invalidAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount'**
  String get error_invalidAmount;

  /// No description provided for @error_enterAmount.
  ///
  /// In en, this message translates to:
  /// **'Please enter an amount'**
  String get error_enterAmount;

  /// No description provided for @error_generic.
  ///
  /// In en, this message translates to:
  /// **'An error occurred: {error}'**
  String error_generic(String error);

  /// No description provided for @error_categoryExists.
  ///
  /// In en, this message translates to:
  /// **'Category already exists'**
  String get error_categoryExists;

  /// No description provided for @error_categoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a category name'**
  String get error_categoryEmpty;

  /// No description provided for @error_selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Please select a category'**
  String get error_selectCategory;

  /// No description provided for @error_invalidDay.
  ///
  /// In en, this message translates to:
  /// **'Day must be between 1 and 31'**
  String get error_invalidDay;

  /// No description provided for @transaction_dateTransactions.
  ///
  /// In en, this message translates to:
  /// **'{date} Transactions'**
  String transaction_dateTransactions(String date);

  /// No description provided for @transaction_viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get transaction_viewAll;

  /// No description provided for @transaction_noTransactionsDate.
  ///
  /// In en, this message translates to:
  /// **'No transactions on this day!'**
  String get transaction_noTransactionsDate;

  /// No description provided for @transaction_noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No search results.'**
  String get transaction_noSearchResults;

  /// No description provided for @transaction_noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions'**
  String get transaction_noTransactions;

  /// No description provided for @mosaic_noBudget.
  ///
  /// In en, this message translates to:
  /// **'Budget not set.'**
  String get mosaic_noBudget;

  /// No description provided for @mosaic_summary.
  ///
  /// In en, this message translates to:
  /// **'This period: Perfect {perfect} days, Overspent {overspent} days'**
  String mosaic_summary(int perfect, int overspent);

  /// No description provided for @mosaic_dateLabel.
  ///
  /// In en, this message translates to:
  /// **'{month}/{day} ({weekday})'**
  String mosaic_dateLabel(int month, int day, String weekday);

  /// No description provided for @weekday_sun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get weekday_sun;

  /// No description provided for @weekday_mon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get weekday_mon;

  /// No description provided for @weekday_tue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get weekday_tue;

  /// No description provided for @weekday_wed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get weekday_wed;

  /// No description provided for @weekday_thu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get weekday_thu;

  /// No description provided for @weekday_fri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get weekday_fri;

  /// No description provided for @weekday_sat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get weekday_sat;

  /// No description provided for @weekday_short_sun.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekday_short_sun;

  /// No description provided for @weekday_short_mon.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekday_short_mon;

  /// No description provided for @weekday_short_tue.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekday_short_tue;

  /// No description provided for @weekday_short_wed.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekday_short_wed;

  /// No description provided for @weekday_short_thu.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekday_short_thu;

  /// No description provided for @weekday_short_fri.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekday_short_fri;

  /// No description provided for @weekday_short_sat.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekday_short_sat;

  /// No description provided for @date_yearMonthDay.
  ///
  /// In en, this message translates to:
  /// **'{year}.{month}.{day}'**
  String date_yearMonthDay(int year, int month, int day);

  /// No description provided for @date_monthDay.
  ///
  /// In en, this message translates to:
  /// **'{month}/{day}'**
  String date_monthDay(int month, int day);

  /// No description provided for @date_yearMonth.
  ///
  /// In en, this message translates to:
  /// **'{year}.{month}'**
  String date_yearMonth(int year, int month);

  /// No description provided for @unit_won.
  ///
  /// In en, this message translates to:
  /// **''**
  String get unit_won;

  /// No description provided for @unit_man.
  ///
  /// In en, this message translates to:
  /// **'0K'**
  String get unit_man;

  /// No description provided for @unit_chun.
  ///
  /// In en, this message translates to:
  /// **'K'**
  String get unit_chun;

  /// No description provided for @format_currency.
  ///
  /// In en, this message translates to:
  /// **'{amount}'**
  String format_currency(String amount);

  /// No description provided for @status_perfect.
  ///
  /// In en, this message translates to:
  /// **'Great! You spent less than 50% of budget'**
  String get status_perfect;

  /// No description provided for @status_safe.
  ///
  /// In en, this message translates to:
  /// **'Good job! You stayed within budget'**
  String get status_safe;

  /// No description provided for @status_warning.
  ///
  /// In en, this message translates to:
  /// **'Be careful. You slightly exceeded budget'**
  String get status_warning;

  /// No description provided for @status_danger.
  ///
  /// In en, this message translates to:
  /// **'Budget management needed. Significantly exceeded'**
  String get status_danger;

  /// No description provided for @diff_increased.
  ///
  /// In en, this message translates to:
  /// **'{amount} more than yesterday'**
  String diff_increased(String amount);

  /// No description provided for @diff_decreased.
  ///
  /// In en, this message translates to:
  /// **'{amount} less than yesterday'**
  String diff_decreased(String amount);

  /// No description provided for @diff_same.
  ///
  /// In en, this message translates to:
  /// **'Same as yesterday'**
  String get diff_same;

  /// No description provided for @statistics_currentPeriodBudget.
  ///
  /// In en, this message translates to:
  /// **'Current Period Budget'**
  String get statistics_currentPeriodBudget;

  /// No description provided for @statistics_netIncome.
  ///
  /// In en, this message translates to:
  /// **'Net Income'**
  String get statistics_netIncome;

  /// No description provided for @statistics_netExpense.
  ///
  /// In en, this message translates to:
  /// **'Net Expense'**
  String get statistics_netExpense;

  /// No description provided for @statistics_remainingBudget.
  ///
  /// In en, this message translates to:
  /// **'Remaining Budget'**
  String get statistics_remainingBudget;

  /// No description provided for @statistics_totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get statistics_totalIncome;

  /// No description provided for @statistics_noBudget.
  ///
  /// In en, this message translates to:
  /// **'Please set a budget first.'**
  String get statistics_noBudget;

  /// No description provided for @statistics_noTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get statistics_noTransactions;

  /// No description provided for @statistics_budgetUsage.
  ///
  /// In en, this message translates to:
  /// **'Budget Usage'**
  String get statistics_budgetUsage;

  /// No description provided for @statistics_categoryExpense.
  ///
  /// In en, this message translates to:
  /// **'Expenses by Category'**
  String get statistics_categoryExpense;

  /// No description provided for @statistics_transactionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String statistics_transactionCount(int count);

  /// No description provided for @statistics_categoryNoTransactions.
  ///
  /// In en, this message translates to:
  /// **'No expense history in this category'**
  String get statistics_categoryNoTransactions;

  /// No description provided for @today_budgetDecreaseHint.
  ///
  /// In en, this message translates to:
  /// **'Daily budget decreases from tomorrow'**
  String get today_budgetDecreaseHint;

  /// No description provided for @trend_noData.
  ///
  /// In en, this message translates to:
  /// **'No budget data'**
  String get trend_noData;

  /// No description provided for @net_income.
  ///
  /// In en, this message translates to:
  /// **'Net Income'**
  String get net_income;

  /// No description provided for @net_expense.
  ///
  /// In en, this message translates to:
  /// **'Net Expense'**
  String get net_expense;

  /// No description provided for @net_income_amount.
  ///
  /// In en, this message translates to:
  /// **'Net Income {amount}'**
  String net_income_amount(String amount);

  /// No description provided for @net_expense_amount.
  ///
  /// In en, this message translates to:
  /// **'Net Expense {amount}'**
  String net_expense_amount(String amount);

  /// No description provided for @remaining_budget_amount.
  ///
  /// In en, this message translates to:
  /// **'Remaining {amount}'**
  String remaining_budget_amount(String amount);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
