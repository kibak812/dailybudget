import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:daily_pace/core/providers/isar_provider.dart';
import 'package:daily_pace/features/recurring/data/models/recurring_transaction_model.dart';
import 'package:daily_pace/features/recurring/domain/services/recurring_service.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/transaction/presentation/providers/transaction_provider.dart';

/// StateNotifierProvider for managing recurring transaction data
/// Manages CRUD operations for recurring transactions and maintains state
final recurringProvider = StateNotifierProvider<RecurringNotifier, List<RecurringTransactionModel>>((ref) {
  return RecurringNotifier(ref);
});

/// Notifier for managing recurring transaction state
class RecurringNotifier extends StateNotifier<List<RecurringTransactionModel>> {
  RecurringNotifier(this.ref) : super([]) {
    // Load recurring transactions when notifier is created
    loadRecurringTransactions();
  }

  final Ref ref;

  /// Load all recurring transactions from Isar database
  Future<void> loadRecurringTransactions() async {
    try {
      final isar = await ref.read(isarProvider.future);
      final recurring = await isar.recurringTransactionModels.where().findAll();
      state = recurring;
    } catch (e) {
      debugPrint('Error loading recurring transactions: $e');
      state = [];
    }
  }

  /// Add a new recurring transaction
  Future<void> addRecurringTransaction(RecurringTransactionModel recurring) async {
    try {
      final isar = await ref.read(isarProvider.future);

      await isar.writeTxn(() async {
        await isar.recurringTransactionModels.put(recurring);
      });

      // Reload recurring transactions to update state
      await loadRecurringTransactions();
    } catch (e) {
      debugPrint('Error adding recurring transaction: $e');
    }
  }

  /// Update an existing recurring transaction
  /// Accepts the full updated RecurringTransactionModel for type safety
  Future<void> updateRecurringTransaction(RecurringTransactionModel transaction) async {
    try {
      final isar = await ref.read(isarProvider.future);

      await isar.writeTxn(() async {
        transaction.updatedAt = DateTime.now();
        await isar.recurringTransactionModels.put(transaction);
      });

      // Reload recurring transactions to update state
      await loadRecurringTransactions();
    } catch (e) {
      debugPrint('Error updating recurring transaction: $e');
      rethrow;
    }
  }

  /// Delete a recurring transaction by ID
  Future<void> deleteRecurringTransaction(int id) async {
    try {
      final isar = await ref.read(isarProvider.future);

      await isar.writeTxn(() async {
        await isar.recurringTransactionModels.delete(id);
      });

      // Reload recurring transactions to update state
      await loadRecurringTransactions();
    } catch (e) {
      debugPrint('Error deleting recurring transaction: $e');
    }
  }

  /// Toggle the isActive status of a recurring transaction
  Future<void> toggleActive(int id) async {
    try {
      final isar = await ref.read(isarProvider.future);

      await isar.writeTxn(() async {
        final recurring = await isar.recurringTransactionModels.get(id);
        if (recurring != null) {
          recurring.isActive = !recurring.isActive;
          recurring.updatedAt = DateTime.now();
          await isar.recurringTransactionModels.put(recurring);
        }
      });

      // Reload recurring transactions to update state
      await loadRecurringTransactions();
    } catch (e) {
      debugPrint('Error toggling recurring transaction active status: $e');
    }
  }

  /// Generate transactions for all active recurring transactions for a specific month
  /// Uses RecurringService to generate transactions
  /// Only generates transactions that don't already exist
  Future<void> generateForMonth(int year, int month) async {
    try {
      // Get existing transactions
      final transactionNotifier = ref.read(transactionProvider.notifier);
      final existingTransactions = ref.read(transactionProvider);

      // Generate new transactions using RecurringService
      final newTransactions = RecurringService.generateRecurringTransactions(
        state,
        existingTransactions,
        year,
        month,
      );

      // Add each new transaction
      final isar = await ref.read(isarProvider.future);
      await isar.writeTxn(() async {
        for (final transaction in newTransactions) {
          await isar.transactionModels.put(transaction);
        }
      });

      // Reload transactions to update the transaction provider
      await transactionNotifier.loadTransactions();

      debugPrint('Generated ${newTransactions.length} recurring transactions for $year-$month');
    } catch (e) {
      debugPrint('Error generating recurring transactions: $e');
    }
  }
}
