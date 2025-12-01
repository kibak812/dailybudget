import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:daily_pace/features/budget/data/models/budget_model.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/recurring/data/models/recurring_transaction_model.dart';

/// Provider for the Isar database instance
/// Initializes the database with all required collections
/// This provider is asynchronous and cached - Isar instance is created only once
final isarProvider = FutureProvider<Isar>((ref) async {
  // Get the application documents directory
  final dir = await getApplicationDocumentsDirectory();

  // Open Isar database with all collections
  final isar = await Isar.open(
    [
      BudgetModelSchema,
      TransactionModelSchema,
      RecurringTransactionModelSchema,
    ],
    directory: dir.path,
    name: 'daily_pace_db',
    inspector: true, // Enable Isar Inspector for debugging
  );

  return isar;
});
