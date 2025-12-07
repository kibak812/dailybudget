import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/providers/isar_provider.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:daily_pace/features/transaction/data/repositories/isar_transaction_repository.dart';

/// StateNotifierProvider for managing transaction data
/// Manages CRUD operations for transactions and maintains state
final transactionProvider = StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  final isar = ref.watch(isarProvider).value; // Access the Isar instance from the FutureProvider
  if (isar == null) {
    throw Exception('Isar database not initialized');
  }
  final repository = IsarTransactionRepository(isar);
  return TransactionNotifier(repository);
});

/// Notifier for managing transaction state
class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  final TransactionRepository _repository;

  TransactionNotifier(this._repository) : super([]) {
    // Load transactions when notifier is created
    loadTransactions();
  }

  /// Load all transactions from Isar database
  /// Sorted by date descending (newest first)
  Future<void> loadTransactions() async {
    try {
      state = await _repository.getTransactions();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      rethrow; // Re-throw to allow UI to handle
    }
  }

  /// Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _repository.addTransaction(transaction);
      // Optimistically update state instead of reloading all
      state = [...state, transaction];
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow; // Re-throw to allow UI to handle
    }
  }

  /// Update an existing transaction
  /// The updates map can contain any of the transaction fields
  Future<void> updateTransaction(TransactionModel updatedTransaction) async {
    try {
      await _repository.updateTransaction(updatedTransaction);
      // Optimistically update state instead of reloading all
      state = [
        for (final transaction in state)
          if (transaction.id == updatedTransaction.id) updatedTransaction else transaction,
      ];
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow; // Re-throw to allow UI to handle
    }
  }

  /// Delete a transaction by ID
  Future<void> deleteTransaction(int id) async {
    try {
      await _repository.deleteTransaction(id);
      // Optimistically update state instead of reloading all
      state = state.where((transaction) => transaction.id != id).toList();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow; // Re-throw to allow UI to handle
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
