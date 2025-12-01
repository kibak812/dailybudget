import 'package:daily_pace/features/recurring/data/models/recurring_transaction_model.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/daily_budget/domain/services/daily_budget_service.dart';

/// Service for managing recurring transactions
/// Ported from TypeScript recurring.ts
class RecurringService {
  RecurringService._();

  /// Check if recurring transaction is valid for a specific month
  static bool isRecurringValidForMonth(
    RecurringTransactionModel recurring,
    int year,
    int month,
  ) {
    if (!recurring.isActive) return false;

    final targetMonth = '$year-${month.toString().padLeft(2, '0')}';

    // Check start month
    if (recurring.startMonth.compareTo(targetMonth) > 0) return false;

    // Check end month
    if (recurring.endMonth != null && recurring.endMonth!.compareTo(targetMonth) < 0) {
      return false;
    }

    return true;
  }

  /// Create transaction from recurring transaction
  static TransactionModel createTransactionFromRecurring(
    RecurringTransactionModel recurring,
    int year,
    int month,
  ) {
    final daysInMonth = DailyBudgetService.getDaysInMonth(year, month);
    final actualDay = recurring.dayOfMonth > daysInMonth ? daysInMonth : recurring.dayOfMonth;

    final dateStr = '$year-${month.toString().padLeft(2, '0')}-${actualDay.toString().padLeft(2, '0')}';
    final now = DateTime.now();

    return TransactionModel(
      type: recurring.type == RecurringTransactionType.expense
          ? TransactionType.expense
          : TransactionType.income,
      amount: recurring.amount,
      date: dateStr,
      category: recurring.category,
      memo: recurring.memo,
      createdAt: now,
      updatedAt: now,
      recurringId: recurring.id.toString(),
    );
  }

  /// Check if recurring transaction already exists for a month
  static bool hasRecurringTransactionForMonth(
    List<TransactionModel> transactions,
    String recurringId,
    int year,
    int month,
  ) {
    final monthPrefix = '$year-${month.toString().padLeft(2, '0')}';

    return transactions.any(
      (t) => t.recurringId == recurringId && t.date.startsWith(monthPrefix),
    );
  }

  /// Generate transactions for all active recurring transactions in a month
  static List<TransactionModel> generateRecurringTransactions(
    List<RecurringTransactionModel> recurringTransactions,
    List<TransactionModel> existingTransactions,
    int year,
    int month,
  ) {
    final newTransactions = <TransactionModel>[];

    for (final recurring in recurringTransactions) {
      // Check if valid for this month
      if (!isRecurringValidForMonth(recurring, year, month)) {
        continue;
      }

      // Check if already generated
      final recurringIdStr = recurring.id.toString();
      if (hasRecurringTransactionForMonth(existingTransactions, recurringIdStr, year, month)) {
        continue;
      }

      // Create transaction
      final transaction = createTransactionFromRecurring(recurring, year, month);
      newTransactions.add(transaction);
    }

    return newTransactions;
  }
}
