// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get common_save => 'Save';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_add => 'Add';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_close => 'Close';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_ok => 'OK';

  @override
  String get common_search => 'Search';

  @override
  String get common_reset => 'Reset';

  @override
  String get filter_all => 'All';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_transactions => 'Transactions';

  @override
  String get nav_statistics => 'Statistics';

  @override
  String get nav_settings => 'Settings';

  @override
  String get home_todayBudget => 'Today\'s Available Budget';

  @override
  String get home_setBudget => 'Please set a budget';

  @override
  String get home_setBudgetDesc =>
      'Set a budget to see\nyour daily available amount';

  @override
  String get home_setBudgetButton => 'Set Budget';

  @override
  String get home_previousMonth => 'Previous month';

  @override
  String get home_nextMonth => 'Next month';

  @override
  String get home_addTransaction => 'Add transaction';

  @override
  String get budget_monthlyBudget => 'Monthly Budget';

  @override
  String budget_daysRemaining(int days) {
    return '$days days left';
  }

  @override
  String budget_budgetAmount(String amount) {
    return 'Budget $amount';
  }

  @override
  String budget_monthBudget(int month) {
    return '$month Budget';
  }

  @override
  String get budget_budgetSettings => 'Budget Settings';

  @override
  String get budget_periodSettings => 'Budget Period Settings';

  @override
  String get budget_startDay => 'Budget Start Day';

  @override
  String budget_startDayDesc(int day) {
    return 'Day $day of each month';
  }

  @override
  String get budget_startDayHint => 'Monthly budget resets on this day';

  @override
  String get budget_notSet => 'Not Set';

  @override
  String get budget_enterNewAmount => 'Enter new budget amount';

  @override
  String get budget_monthlyStartDay => 'Monthly Start Day';

  @override
  String budget_dayDefault(int day) {
    return 'Day $day (Default)';
  }

  @override
  String budget_dayFormat(int day) {
    return 'Day $day';
  }

  @override
  String get budget_startDayExplain =>
      'Set a budget start day (like payday) to calculate the budget period from that date to the day before next month\'s start.';

  @override
  String get budget_selectStartDay => 'Select Budget Start Day';

  @override
  String get today_netIncome => 'Today\'s Net Income';

  @override
  String get today_netExpense => 'Today\'s Net Expense';

  @override
  String get today_overBudget => 'Over budget today';

  @override
  String get today_remaining => 'Remaining today';

  @override
  String yesterday_summary(String date) {
    return '$date Summary';
  }

  @override
  String get yesterday_budget => 'Budget';

  @override
  String get yesterday_expense => 'Expense';

  @override
  String get yesterday_savingsRate => 'Savings Rate';

  @override
  String get trend_title => 'Daily Budget Trend';

  @override
  String get trend_1week => '1W';

  @override
  String get trend_2weeks => '2W';

  @override
  String get trend_1month => '1M';

  @override
  String get transaction_addTitle => 'Add Transaction';

  @override
  String get transaction_editTitle => 'Edit Transaction';

  @override
  String get transaction_detailTitle => 'Transaction Details';

  @override
  String get transaction_expense => 'Expense';

  @override
  String get transaction_income => 'Income';

  @override
  String get transaction_amount => 'Amount';

  @override
  String get transaction_amountHint => '0';

  @override
  String get transaction_category => 'Category';

  @override
  String get transaction_categoryOptional => 'Category (Optional)';

  @override
  String get transaction_categorySelect => 'Select';

  @override
  String get transaction_memo => 'Memo (Optional)';

  @override
  String get transaction_memoHint => 'Enter memo';

  @override
  String get transaction_date => 'Date';

  @override
  String transaction_dateLabel(String date) {
    return 'Date: $date';
  }

  @override
  String get transaction_createdAt => 'Created at';

  @override
  String get transaction_isRecurring => 'Recurring Transaction';

  @override
  String get transaction_addButton => 'Add';

  @override
  String get transaction_editButton => 'Save Changes';

  @override
  String get transaction_uncategorized => 'Uncategorized';

  @override
  String get transaction_deleteTitle => 'Delete Transaction';

  @override
  String get transaction_deleteMessage =>
      'Are you sure you want to delete this transaction?';

  @override
  String get calculator_title => 'Calculator';

  @override
  String calculator_result(String result) {
    return '$result won';
  }

  @override
  String get category_title => 'Categories';

  @override
  String get category_expense => 'Expense Categories';

  @override
  String get category_income => 'Income Categories';

  @override
  String get category_add => 'Add new category';

  @override
  String get category_edit => 'Edit Category';

  @override
  String get category_editTitle => 'Edit Category';

  @override
  String get category_name => 'Category Name';

  @override
  String get category_empty => 'No categories';

  @override
  String get category_deleteTitle => 'Delete Category';

  @override
  String category_deleteMessage(String category) {
    return 'Are you sure you want to delete \"$category\"?';
  }

  @override
  String get category_food => 'Food';

  @override
  String get category_transport => 'Transport';

  @override
  String get category_shopping => 'Shopping';

  @override
  String get category_living => 'Living';

  @override
  String get category_hobby => 'Hobby';

  @override
  String get category_medical => 'Medical';

  @override
  String get category_other => 'Other';

  @override
  String get category_salary => 'Salary';

  @override
  String get category_allowance => 'Allowance';

  @override
  String get category_bonus => 'Bonus';

  @override
  String get statistics_title => 'Statistics';

  @override
  String get statistics_totalExpense => 'Total Expense';

  @override
  String statistics_categoryDetail(String category) {
    return '$category Expense History';
  }

  @override
  String statistics_yearMonth(int year, int month) {
    return '$year.$month';
  }

  @override
  String get settings_title => 'Settings';

  @override
  String get notification_title => 'Notification Settings';

  @override
  String get notification_dailySummary => 'Daily Summary Notification';

  @override
  String get notification_dailySummaryDesc =>
      'Get notified about yesterday\'s spending at your set time';

  @override
  String get notification_time => 'Notification Time';

  @override
  String get notification_timeSelect => 'Select notification time';

  @override
  String get notification_permissionRequired =>
      'Notification permission required. Please allow it in settings.';

  @override
  String get notification_requestAgain => 'Request Again';

  @override
  String get notification_am => 'AM';

  @override
  String get notification_pm => 'PM';

  @override
  String get notification_hour => 'Hour';

  @override
  String get notification_minute => 'Minute';

  @override
  String get notification_channelName => 'Daily Summary';

  @override
  String get notification_channelDesc =>
      'Daily spending summary notifications at your set time';

  @override
  String get notification_pushTitle => 'Daily Summary';

  @override
  String get notification_pushBody => 'Check yesterday\'s spending';

  @override
  String get recurring_title => 'Recurring';

  @override
  String get recurring_addTitle => 'Add Recurring';

  @override
  String get recurring_editTitle => 'Edit Recurring';

  @override
  String get recurring_add => 'Add';

  @override
  String get recurring_empty => 'No recurring transactions';

  @override
  String get recurring_regenerate => 'Regenerate recurring for current period';

  @override
  String get recurring_type => 'Type';

  @override
  String get recurring_amount => 'Amount';

  @override
  String get recurring_dayOfMonth => 'Day of Month';

  @override
  String get recurring_dayOfMonthHint => '1-31';

  @override
  String get recurring_memo => 'Memo';

  @override
  String get recurring_enabled => 'Enabled';

  @override
  String get recurring_deleteTitle => 'Delete Recurring';

  @override
  String get recurring_deleteMessage =>
      'Are you sure you want to delete this recurring transaction?';

  @override
  String get recurring_example => 'e.g., Rent';

  @override
  String get recurring_amountExample => 'e.g., 500,000';

  @override
  String get recurring_monthly => 'monthly';

  @override
  String get recurring_active => 'active';

  @override
  String get recurring_inactive => 'inactive';

  @override
  String get data_title => 'Data Management';

  @override
  String get data_backup => 'Backup Data';

  @override
  String get data_backupDesc => 'Save current data to file';

  @override
  String get data_restore => 'Restore Data';

  @override
  String get data_restoreDesc => 'Load backup file';

  @override
  String get data_deleteAll => 'Delete All Data';

  @override
  String get data_deleteAllDesc => 'This action cannot be undone';

  @override
  String get data_hint =>
      'Data is securely stored on device. Back up regularly as data is lost when app is deleted.';

  @override
  String get data_exportSuccess => 'Data exported successfully.';

  @override
  String data_exportError(String error) {
    return 'Failed to export data: $error';
  }

  @override
  String data_importSuccess(int budgets, int transactions, int recurring) {
    return 'Data imported!\nBudgets: $budgets, Transactions: $transactions, Recurring: $recurring';
  }

  @override
  String data_importError(String error) {
    return 'Failed to import data: $error';
  }

  @override
  String get data_deleteConfirm => 'Delete All Data';

  @override
  String get data_deleteConfirmMessage =>
      'Are you sure you want to delete all data?\nThis action cannot be undone.';

  @override
  String get data_deleteDoubleConfirm => 'Confirm Again';

  @override
  String get data_deleteDoubleConfirmMessage =>
      'Please confirm once more. Are you sure you want to delete?';

  @override
  String get data_deleteSuccess => 'All data has been deleted.';

  @override
  String data_deleteError(String error) {
    return 'Failed to delete data: $error';
  }

  @override
  String get data_backupSubject => 'DailyBudget Backup';

  @override
  String get data_backupText => 'Data backup file';

  @override
  String get language_title => 'Language';

  @override
  String get language_system => 'System Default';

  @override
  String get language_korean => 'Korean';

  @override
  String get language_english => 'English';

  @override
  String get language_changeWarningTitle => 'Change Language';

  @override
  String get language_changeWarningMessage =>
      'Changing languages may affect how existing transaction amounts are displayed.\n\nKorean uses whole numbers (won), while English uses dollars with cents.\n\nExisting data will remain but may display differently.';

  @override
  String get language_changeConfirm => 'Change Anyway';

  @override
  String get error_invalidAmount => 'Please enter a valid amount';

  @override
  String get error_enterAmount => 'Please enter an amount';

  @override
  String error_generic(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get error_categoryExists => 'Category already exists';

  @override
  String get error_categoryEmpty => 'Please enter a category name';

  @override
  String get error_selectCategory => 'Please select a category';

  @override
  String get error_invalidDay => 'Day must be between 1 and 31';

  @override
  String transaction_dateTransactions(String date) {
    return '$date Transactions';
  }

  @override
  String get transaction_viewAll => 'View All';

  @override
  String get transaction_noTransactionsDate => 'No transactions on this day!';

  @override
  String get transaction_noSearchResults => 'No search results.';

  @override
  String get transaction_noTransactions => 'No transactions';

  @override
  String get mosaic_noBudget => 'Budget not set.';

  @override
  String mosaic_summary(int perfect, int overspent) {
    return 'This period: Perfect $perfect days, Overspent $overspent days';
  }

  @override
  String mosaic_dateLabel(int month, int day, String weekday) {
    return '$month/$day ($weekday)';
  }

  @override
  String get weekday_sun => 'Sun';

  @override
  String get weekday_mon => 'Mon';

  @override
  String get weekday_tue => 'Tue';

  @override
  String get weekday_wed => 'Wed';

  @override
  String get weekday_thu => 'Thu';

  @override
  String get weekday_fri => 'Fri';

  @override
  String get weekday_sat => 'Sat';

  @override
  String get weekday_short_sun => 'S';

  @override
  String get weekday_short_mon => 'M';

  @override
  String get weekday_short_tue => 'T';

  @override
  String get weekday_short_wed => 'W';

  @override
  String get weekday_short_thu => 'T';

  @override
  String get weekday_short_fri => 'F';

  @override
  String get weekday_short_sat => 'S';

  @override
  String date_yearMonthDay(int year, int month, int day) {
    return '$year.$month.$day';
  }

  @override
  String date_monthDay(int month, int day) {
    return '$month/$day';
  }

  @override
  String date_yearMonth(int year, int month) {
    return '$year.$month';
  }

  @override
  String get unit_won => '';

  @override
  String get unit_man => '0K';

  @override
  String get unit_chun => 'K';

  @override
  String format_currency(String amount) {
    return '$amount';
  }

  @override
  String get status_perfect => 'Great! You spent less than 50% of budget';

  @override
  String get status_safe => 'Good job! You stayed within budget';

  @override
  String get status_warning => 'Be careful. You slightly exceeded budget';

  @override
  String get status_danger =>
      'Budget management needed. Significantly exceeded';

  @override
  String diff_increased(String amount) {
    return '$amount more than yesterday';
  }

  @override
  String diff_decreased(String amount) {
    return '$amount less than yesterday';
  }

  @override
  String get diff_same => 'Same as yesterday';

  @override
  String get statistics_currentPeriodBudget => 'Current Period Budget';

  @override
  String get statistics_netIncome => 'Net Income';

  @override
  String get statistics_netExpense => 'Net Expense';

  @override
  String get statistics_remainingBudget => 'Remaining Budget';

  @override
  String get statistics_totalIncome => 'Total Income';

  @override
  String get statistics_noBudget => 'Please set a budget first.';

  @override
  String get statistics_noTransactions => 'No transactions yet';

  @override
  String get statistics_budgetUsage => 'Budget Usage';

  @override
  String get statistics_categoryExpense => 'Expenses by Category';

  @override
  String statistics_transactionCount(int count) {
    return '$count transactions';
  }

  @override
  String get statistics_categoryNoTransactions =>
      'No expense history in this category';

  @override
  String get today_budgetDecreaseHint => 'Daily budget decreases from tomorrow';

  @override
  String get trend_noData => 'No budget data';

  @override
  String get net_income => 'Net Income';

  @override
  String get net_expense => 'Net Expense';

  @override
  String net_income_amount(String amount) {
    return 'Net Income $amount';
  }

  @override
  String net_expense_amount(String amount) {
    return 'Net Expense $amount';
  }

  @override
  String remaining_budget_amount(String amount) {
    return 'Remaining $amount';
  }

  @override
  String get category_expense_food => 'Food';

  @override
  String get category_expense_transport => 'Transport';

  @override
  String get category_expense_shopping => 'Shopping';

  @override
  String get category_expense_living => 'Living';

  @override
  String get category_expense_hobby => 'Hobby';

  @override
  String get category_expense_medical => 'Medical';

  @override
  String get category_expense_other => 'Other';

  @override
  String get category_income_salary => 'Salary';

  @override
  String get category_income_allowance => 'Allowance';

  @override
  String get category_income_bonus => 'Bonus';

  @override
  String get category_income_other => 'Other';
}
