import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:daily_pace/core/providers/isar_provider.dart';
import 'package:daily_pace/features/budget/data/models/budget_model.dart';

/// StateNotifierProvider for managing budget data
/// Manages CRUD operations for budgets and maintains state
final budgetProvider = StateNotifierProvider<BudgetNotifier, List<BudgetModel>>((ref) {
  return BudgetNotifier(ref);
});

/// Notifier for managing budget state
class BudgetNotifier extends StateNotifier<List<BudgetModel>> {
  BudgetNotifier(this.ref) : super([]) {
    // Load budgets when notifier is created
    loadBudgets();
  }

  final Ref ref;

  /// Load all budgets from Isar database
  Future<void> loadBudgets() async {
    try {
      final isar = await ref.read(isarProvider.future);
      final budgets = await isar.budgetModels.where().findAll();
      state = budgets;
    } catch (e) {
      // Handle error - could use error state management here
      debugPrint('Error loading budgets: $e');
      state = [];
    }
  }

  /// Set or update budget for a specific month
  /// If a budget exists for the year/month, it will be updated
  /// Otherwise, a new budget will be created
  Future<void> setBudget(int year, int month, int amount) async {
    try {
      final isar = await ref.read(isarProvider.future);

      await isar.writeTxn(() async {
        // Check if budget already exists
        final existing = await isar.budgetModels
            .filter()
            .yearEqualTo(year)
            .and()
            .monthEqualTo(month)
            .findFirst();

        if (existing != null) {
          // Update existing budget
          existing.amount = amount;
          await isar.budgetModels.put(existing);
        } else {
          // Create new budget
          final newBudget = BudgetModel(
            year: year,
            month: month,
            amount: amount,
          );
          await isar.budgetModels.put(newBudget);
        }
      });

      // Reload budgets to update state
      await loadBudgets();
    } catch (e) {
      debugPrint('Error setting budget: $e');
    }
  }

  /// Get budget for a specific month
  /// Returns null if no budget exists for the given year/month
  BudgetModel? getBudget(int year, int month) {
    try {
      return state.firstWhere(
        (budget) => budget.year == year && budget.month == month,
      );
    } catch (e) {
      return null;
    }
  }

  /// Delete budget for a specific month
  Future<void> deleteBudget(int year, int month) async {
    try {
      final isar = await ref.read(isarProvider.future);

      await isar.writeTxn(() async {
        final budget = await isar.budgetModels
            .filter()
            .yearEqualTo(year)
            .and()
            .monthEqualTo(month)
            .findFirst();

        if (budget != null) {
          await isar.budgetModels.delete(budget.id);
        }
      });

      // Reload budgets to update state
      await loadBudgets();
    } catch (e) {
      debugPrint('Error deleting budget: $e');
    }
  }
}
