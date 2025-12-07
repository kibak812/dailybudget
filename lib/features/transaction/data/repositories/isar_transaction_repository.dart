import 'package:isar/isar.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/transaction/domain/repositories/transaction_repository.dart';

class IsarTransactionRepository implements TransactionRepository {
  final Isar isar;

  IsarTransactionRepository(this.isar);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    return await isar.transactionModels.where().sortByDateDesc().findAll();
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
