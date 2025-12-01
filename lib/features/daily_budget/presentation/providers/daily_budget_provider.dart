import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/features/budget/presentation/providers/budget_provider.dart';
import 'package:daily_pace/features/budget/presentation/providers/current_month_provider.dart';
import 'package:daily_pace/features/transaction/presentation/providers/transaction_provider.dart';
import 'package:daily_pace/features/daily_budget/domain/services/daily_budget_service.dart';
import 'package:daily_pace/features/daily_budget/domain/models/daily_budget_data.dart';

/// Provider for calculating daily budget data
/// This is a computed provider that depends on:
/// - budgetProvider: for the monthly budget
/// - transactionProvider: for all transactions
/// - currentMonthProvider: for the selected month/year
///
/// Returns DailyBudgetData with all calculated values
final dailyBudgetProvider = Provider<DailyBudgetData>((ref) {
  // Watch all dependencies - provider will recalculate when any of these change
  final budgets = ref.watch(budgetProvider);
  final transactions = ref.watch(transactionProvider);
  final currentMonth = ref.watch(currentMonthProvider);

  // Get budget for current month
  final budget = budgets.where((b) =>
    b.year == currentMonth.year && b.month == currentMonth.month
  ).firstOrNull;

  // Filter transactions for current month
  final monthPrefix = '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}';
  final monthTransactions = transactions
      .where((t) => t.date.startsWith(monthPrefix))
      .toList();

  // Calculate daily budget data using the service
  final currentDate = DateTime(currentMonth.year, currentMonth.month, DateTime.now().day);

  return DailyBudgetService.calculateDailyBudgetData(
    budget,
    monthTransactions,
    currentDate,
  );
});

/// Provider for daily budget history (from day 1 to current day)
/// Returns a list of DailyBudgetHistoryItem
final dailyBudgetHistoryProvider = Provider<List<DailyBudgetHistoryItem>>((ref) {
  final budgets = ref.watch(budgetProvider);
  final transactions = ref.watch(transactionProvider);
  final currentMonth = ref.watch(currentMonthProvider);

  // Get budget for current month
  final budget = budgets.where((b) =>
    b.year == currentMonth.year && b.month == currentMonth.month
  ).firstOrNull;

  // Filter transactions for current month
  final monthPrefix = '${currentMonth.year}-${currentMonth.month.toString().padLeft(2, '0')}';
  final monthTransactions = transactions
      .where((t) => t.date.startsWith(monthPrefix))
      .toList();

  // Calculate history using the service
  final currentDate = DateTime(currentMonth.year, currentMonth.month, DateTime.now().day);

  return DailyBudgetService.getDailyBudgetHistory(
    budget,
    monthTransactions,
    currentDate,
  );
});
