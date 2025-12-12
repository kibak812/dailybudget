import 'package:isar/isar.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/transaction/domain/repositories/transaction_repository.dart';

/// Isar implementation of TransactionRepository
class IsarTransactionRepository implements TransactionRepository {
  final Isar isar;

  IsarTransactionRepository(this.isar);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    return await isar.transactionModels.where().sortByDateDesc().findAll();
  }

  @override
  Future<List<TransactionModel>> getTransactionsForMonth(
    int year,
    int month,
  ) async {
    final monthPrefix = Formatters.formatYearMonth(year, month);
    return await isar.transactionModels
        .where()
        .filter()
        .dateStartsWith(monthPrefix)
        .sortByDateDesc()
        .findAll();
  }

  @override
  Future<List<TransactionModel>> getTransactionsForDateRange(
    String startDate,
    String endDate,
  ) async {
    return await isar.transactionModels
        .where()
        .filter()
        .dateGreaterThan(startDate, include: true)
        .dateLessThan(endDate, include: true)
        .sortByDateDesc()
        .findAll();
  }

  @override
  Future<void> addTransaction(TransactionModel transaction) async {
    await isar.writeTxn(() async {
      await isar.transactionModels.put(transaction);
    });
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    await isar.writeTxn(() async {
      await isar.transactionModels.put(transaction);
    });
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await isar.writeTxn(() async {
      await isar.transactionModels.delete(id);
    });
  }
}
