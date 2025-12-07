import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:daily_pace/core/providers/isar_provider.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';

/// StateNotifierProvider for managing transaction data
/// Manages CRUD operations for transactions and maintains state
final transactionProvider = StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  return TransactionNotifier(ref);
});

/// Notifier for managing transaction state
class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  TransactionNotifier(this.ref) : super([]) {
    // Load transactions when notifier is created
    loadTransactions();
  }

  final Ref ref;

  /// Load all transactions from Isar database
  /// Sorted by date descending (newest first)
  Future<void> loadTransactions() async {
    try {
      final isar = await ref.read(isarProvider.future);
      final transactions = await isar.transactionModels
          .where()
          .sortByDateDesc()
          .findAll();
      state = transactions;
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      state = [];
    }
  }

  /// Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      final isar = await ref.read(isarProvider.future);

      await isar.writeTxn(() async {
        await isar.transactionModels.put(transaction);
      });

      // Reload transactions to update state
      await loadTransactions();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  /// Update an existing transaction
  /// The updates map can contain any of the transaction fields
  Future<void> updateTransaction(int id, Map<String, dynamic> updates) async {
    try {
      final isar = await ref.read(isarProvider.future);

      await isar.writeTxn(() async {
        final transaction = await isar.transactionModels.get(id);
        if (transaction != null) {
          // Update fields based on the updates map
          if (updates.containsKey('type')) {
            transaction.type = updates['type'] as TransactionType;
          }
          if (updates.containsKey('amount')) {
            transaction.amount = updates['amount'] as int;
          }
          if (updates.containsKey('date')) {
            transaction.date = updates['date'] as String;
          }
          if (updates.containsKey('category')) {
            transaction.category = updates['category'] as String?;
          }
          if (updates.containsKey('memo')) {
            transaction.memo = updates['memo'] as String?;
          }

          // Always update the updatedAt timestamp
          transaction.updatedAt = DateTime.now();

          await isar.transactionModels.put(transaction);
        }
      });

      // Reload transactions to update state
      await loadTransactions();
    } catch (e) {
      debugPrint('Error updating transaction: $e');
    }
  }

  /// Delete a transaction by ID
  Future<void> deleteTransaction(int id) async {
    try {
      final isar = await ref.read(isarProvider.future);

      await isar.writeTxn(() async {
        await isar.transactionModels.delete(id);
      });

      // Reload transactions to update state
      await loadTransactions();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

  /// Get transactions for a specific month
  /// Returns filtered list without modifying state
  List<TransactionModel> getTransactionsForMonth(int year, int month) {
    final monthPrefix = '$year-${month.toString().padLeft(2, '0')}';
    return state
        .where((transaction) => transaction.date.startsWith(monthPrefix))
        .toList();
  }

  /// Get transactions for a specific date
  /// Returns filtered list without modifying state
  List<TransactionModel> getTransactionsForDate(String date) {
    return state
        .where((transaction) => transaction.date == date)
        .toList();
  }
}
