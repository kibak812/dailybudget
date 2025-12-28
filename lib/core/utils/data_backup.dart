import 'dart:convert';
import 'package:isar_community/isar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:daily_pace/features/budget/data/models/budget_model.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/recurring/data/models/recurring_transaction_model.dart';

/// Utility class for backing up and restoring data
class DataBackup {
  /// SharedPreferences key for categories (matches categories_provider.dart)
  static const String _categoriesKey = 'categories';

  /// Export all data from Isar and SharedPreferences to JSON string
  static Future<String> exportData(Isar isar) async {
    // Get all data from Isar
    final budgets = await isar.budgetModels.where().findAll();
    final transactions = await isar.transactionModels.where().findAll();
    final recurring = await isar.recurringTransactionModels.where().findAll();

    // Get categories from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final categories = prefs.getStringList(_categoriesKey) ?? [];

    // Create JSON structure
    final data = {
      'version': '1.1.0',  // Updated version for categories support
      'exportDate': DateTime.now().toIso8601String(),
      'categories': categories,  // Include categories in backup
      'budgets': budgets
          .map((b) => {
                'year': b.year,
                'month': b.month,
                'amount': b.amount,
              })
          .toList(),
      'transactions': transactions
          .map((t) => {
                'type': t.type.name,
                'amount': t.amount,
                'date': t.date,
                'category': t.category,
                'memo': t.memo,
                'createdAt': t.createdAt.toIso8601String(),
                'updatedAt': t.updatedAt.toIso8601String(),
                'recurringId': t.recurringId,
              })
          .toList(),
      'recurringTransactions': recurring
          .map((r) => {
                'type': r.type.name,
                'amount': r.amount,
                'dayOfMonth': r.dayOfMonth,
                'category': r.category,
                'memo': r.memo,
                'isActive': r.isActive,
                'startMonth': r.startMonth,
                'endMonth': r.endMonth,
                'createdAt': r.createdAt.toIso8601String(),
                'updatedAt': r.updatedAt.toIso8601String(),
              })
          .toList(),
    };

    return jsonEncode(data);
  }

  /// Import data from JSON string and save to Isar and SharedPreferences
  /// Returns number of items imported
  static Future<Map<String, int>> importData(Isar isar, String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;

    int budgetCount = 0;
    int transactionCount = 0;
    int recurringCount = 0;
    int categoryCount = 0;

    // Import categories to SharedPreferences first
    if (data.containsKey('categories')) {
      final prefs = await SharedPreferences.getInstance();
      final categories = (data['categories'] as List<dynamic>)
          .map((e) => e as String)
          .toList();
      await prefs.setStringList(_categoriesKey, categories);
      categoryCount = categories.length;
    }

    await isar.writeTxn(() async {
      // Clear existing data
      await isar.budgetModels.clear();
      await isar.transactionModels.clear();
      await isar.recurringTransactionModels.clear();

      // Import budgets
      if (data.containsKey('budgets')) {
        final budgetList = data['budgets'] as List<dynamic>;
        for (final budgetData in budgetList) {
          final budget = BudgetModel(
            year: budgetData['year'] as int,
            month: budgetData['month'] as int,
            amount: budgetData['amount'] as int,
          );
          await isar.budgetModels.put(budget);
          budgetCount++;
        }
      }

      // Import transactions
      if (data.containsKey('transactions')) {
        final transactionList = data['transactions'] as List<dynamic>;
        for (final transactionData in transactionList) {
          final transaction = TransactionModel(
            type: TransactionType.values.firstWhere(
              (e) => e.name == transactionData['type'],
            ),
            amount: transactionData['amount'] as int,
            date: transactionData['date'] as String,
            category: transactionData['category'] as String?,
            memo: transactionData['memo'] as String?,
            createdAt: DateTime.parse(transactionData['createdAt'] as String),
            updatedAt: DateTime.parse(transactionData['updatedAt'] as String),
            recurringId: transactionData['recurringId'] as String?,
          );
          await isar.transactionModels.put(transaction);
          transactionCount++;
        }
      }

      // Import recurring transactions
      if (data.containsKey('recurringTransactions')) {
        final recurringList = data['recurringTransactions'] as List<dynamic>;
        for (final recurringData in recurringList) {
          final recurring = RecurringTransactionModel(
            type: RecurringTransactionType.values.firstWhere(
              (e) => e.name == recurringData['type'],
            ),
            amount: recurringData['amount'] as int,
            dayOfMonth: recurringData['dayOfMonth'] as int,
            category: recurringData['category'] as String?,
            memo: recurringData['memo'] as String?,
            isActive: recurringData['isActive'] as bool,
            startMonth: recurringData['startMonth'] as String,
            endMonth: recurringData['endMonth'] as String?,
            createdAt: DateTime.parse(recurringData['createdAt'] as String),
            updatedAt: DateTime.parse(recurringData['updatedAt'] as String),
          );
          await isar.recurringTransactionModels.put(recurring);
          recurringCount++;
        }
      }
    });

    return {
      'budgets': budgetCount,
      'transactions': transactionCount,
      'recurring': recurringCount,
      'categories': categoryCount,
    };
  }

  /// Clear all data from Isar database and reset categories to defaults
  static Future<void> clearAllData(Isar isar) async {
    // Clear Isar data
    await isar.writeTxn(() async {
      await isar.budgetModels.clear();
      await isar.transactionModels.clear();
      await isar.recurringTransactionModels.clear();
    });

    // Reset categories to defaults (clear SharedPreferences key so it reloads defaults)
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_categoriesKey);
  }
}
