import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/transaction_list_item.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/transaction_edit_sheet.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/add_transaction_sheet.dart';

/// Transactions page
/// Displays list of all transactions grouped by date with filtering and management
class TransactionsPage extends ConsumerStatefulWidget {
  const TransactionsPage({super.key});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    final currentMonth = ref.watch(currentMonthProvider);
    final transactions = ref.watch(transactionProvider);

    // Filter transactions for current month
    final monthTransactions = _filterByMonth(transactions, currentMonth);

    // Group by date
    final grouped = _groupByDate(monthTransactions);

    // Calculate total spent
    final totalSpent = _calculateTotalSpent(monthTransactions);

    return Scaffold(
      appBar: _buildAppBar(context, totalSpent),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(transactionProvider.notifier).loadTransactions();
        },
        child: _buildBody(context, grouped, monthTransactions),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, int totalSpent) {
    final theme = Theme.of(context);

    return AppBar(
      title: const Text('거래 내역'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(
            '이번 달 총 지출: ${Formatters.formatCurrency(totalSpent)}',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implement search
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('검색 기능은 추후 구현 예정입니다')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // TODO: Implement filters
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('필터 기능은 추후 구현 예정입니다')),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    Map<String, List<TransactionModel>> grouped,
    List<TransactionModel> monthTransactions,
  ) {
    if (monthTransactions.isEmpty) {
      return _buildEmptyState(context);
    }

    // Sort dates in descending order (newest first)
    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, index) {
        final date = sortedDates[index];
        final dateTransactions = grouped[date]!;
        final dayTotal = _calculateDayTotal(dateTransactions);

        return _buildDateSection(
          context,
          date,
          dateTransactions,
          dayTotal,
        );
      },
    );
  }

  Widget _buildDateSection(
    BuildContext context,
    String date,
    List<TransactionModel> transactions,
    int dayTotal,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${Formatters.formatDate(date)} (${_getDayOfWeek(date)})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                Formatters.formatCurrency(dayTotal),
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Transaction list for this date
        ...transactions.map((transaction) => TransactionListItem(
              transaction: transaction,
              onTap: () => _showTransactionEditSheet(context, transaction),
              onDismissed: () => _handleDelete(transaction),
            )),

        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 80,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 거래 내역이 없습니다',
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '홈 화면에서 지출을 기록해보세요',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => _showAddTransactionSheet(context),
              icon: const Icon(Icons.add),
              label: const Text('거래 추가하기'),
            ),
          ],
        ),
      ),
    );
  }

  /// Filter transactions by month
  List<TransactionModel> _filterByMonth(
    List<TransactionModel> transactions,
    CurrentMonth month,
  ) {
    return transactions.where((t) {
      return t.year == month.year && t.month == month.month;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Newest first
  }

  /// Group transactions by date
  Map<String, List<TransactionModel>> _groupByDate(
    List<TransactionModel> transactions,
  ) {
    final Map<String, List<TransactionModel>> grouped = {};
    for (final t in transactions) {
      if (!grouped.containsKey(t.date)) {
        grouped[t.date] = [];
      }
      grouped[t.date]!.add(t);
    }
    return grouped;
  }

  /// Calculate total spent (expenses only)
  int _calculateTotalSpent(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  /// Calculate day total (expenses only)
  int _calculateDayTotal(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  /// Get day of week in Korean
  String _getDayOfWeek(String dateStr) {
    final date = DateTime.parse(dateStr);
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[date.weekday - 1];
  }

  /// Show add transaction bottom sheet
  void _showAddTransactionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => const AddTransactionSheet(),
    );
  }

  /// Show transaction edit bottom sheet
  void _showTransactionEditSheet(
    BuildContext context,
    TransactionModel transaction,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => TransactionEditSheet(transaction: transaction),
    );
  }

  /// Handle transaction deletion
  Future<void> _handleDelete(TransactionModel transaction) async {
    await ref.read(transactionProvider.notifier).deleteTransaction(transaction.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('거래가 삭제되었습니다')),
      );
    }
  }
}
