import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/providers/isar_provider.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/transaction/domain/repositories/transaction_repository.dart';
import 'package:daily_pace/features/transaction/data/repositories/isar_transaction_repository.dart';

/// Provider for TransactionRepository
/// Separated for better testability - can be overridden with mock in tests
final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final isar = ref.watch(isarProvider).value;
  if (isar == null) {
    throw Exception('Isar database not initialized');
  }
  return IsarTransactionRepository(isar);
});

/// StateNotifierProvider for managing transaction data
/// Manages CRUD operations for transactions and maintains state
final transactionProvider =
    StateNotifierProvider<TransactionNotifier, List<TransactionModel>>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  return TransactionNotifier(repository);
});

/// Notifier for managing transaction state
class TransactionNotifier extends StateNotifier<List<TransactionModel>> {
  final TransactionRepository _repository;

  TransactionNotifier(this._repository) : super([]) {
    loadTransactions();
  }

  /// Load all transactions from database
  Future<void> loadTransactions() async {
    try {
      state = await _repository.getTransactions();
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      rethrow;
    }
  }

  /// Add a new transaction
  Future<void> addTransaction(TransactionModel transaction) async {
    try {
      await _repository.addTransaction(transaction);
      state = [...state, transaction];
    } catch (e) {
      debugPrint('Error adding transaction: $e');
      rethrow;
    }
  }

  /// Update an existing transaction
  Future<void> updateTransaction(TransactionModel updatedTransaction) async {
    try {
      await _repository.updateTransaction(updatedTransaction);
      state = [
        for (final transaction in state)
          if (transaction.id == updatedTransaction.id)
            updatedTransaction
          else
            transaction,
      ];
    } catch (e) {
      debugPrint('Error updating transaction: $e');
      rethrow;
    }
  }

  /// Delete a transaction by ID
  Future<void> deleteTransaction(int id) async {
    try {
      await _repository.deleteTransaction(id);
      state = state.where((transaction) => transaction.id != id).toList();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
      rethrow;
    }
  }

  /// Get transactions for a specific month
  List<TransactionModel> getTransactionsForMonth(int year, int month) {
    final monthPrefix = '$year-${month.toString().padLeft(2, '0')}';
    return state
        .where((transaction) => transaction.date.startsWith(monthPrefix))
        .toList();
  }

  /// Get transactions for a specific date
  List<TransactionModel> getTransactionsForDate(String date) {
    return state.where((transaction) => transaction.date == date).toList();
  }
}
