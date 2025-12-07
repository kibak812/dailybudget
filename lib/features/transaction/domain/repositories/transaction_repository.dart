import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';

/// Abstract repository interface for transaction data access.
///
/// Note: This interface uses TransactionModel directly for pragmatic reasons.
/// In a larger project, you might want to create separate domain entities
/// and map between them in the repository implementation.
abstract class TransactionRepository {
  /// Get all transactions, sorted by date descending
  Future<List<TransactionModel>> getTransactions();

  /// Get transactions for a specific month
  Future<List<TransactionModel>> getTransactionsForMonth(int year, int month);

  /// Get transactions within a date range (inclusive)
  Future<List<TransactionModel>> getTransactionsForDateRange(
    String startDate,
    String endDate,
  );

  /// Add a new transaction
  Future<void> addTransaction(TransactionModel transaction);

  /// Update an existing transaction
  Future<void> updateTransaction(TransactionModel transaction);

  /// Delete a transaction by ID
  Future<void> deleteTransaction(int id);
}
