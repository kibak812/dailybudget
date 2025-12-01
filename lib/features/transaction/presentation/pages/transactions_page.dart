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
  String _searchKeyword = '';
  TransactionType? _typeFilter;

  @override
  Widget build(BuildContext context) {
    final currentMonth = ref.watch(currentMonthProvider);
    final transactions = ref.watch(transactionProvider);

    // Filter transactions for current month
    final monthTransactions = _filterByMonth(transactions, currentMonth);
    final filteredTransactions = _applyFilters(monthTransactions);

    // Group by date
    final grouped = _groupByDate(filteredTransactions);

    // Calculate total spent
    final totalSpent = _calculateTotalSpent(filteredTransactions);

    return Scaffold(
      appBar: _buildAppBar(context, totalSpent),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(transactionProvider.notifier).loadTransactions();
        },
        child: _buildBody(context, grouped, filteredTransactions),
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
          onPressed: () => _showSearchDialog(context),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () => _showFilterSheet(context),
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
      itemCount: sortedDates.length + (_hasActiveFilters ? 1 : 0),
      itemBuilder: (context, index) {
        if (_hasActiveFilters) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_searchKeyword.isNotEmpty)
                    InputChip(
                      label: Text('검색: $_searchKeyword'),
                      onDeleted: () => setState(() => _searchKeyword = ''),
                    ),
                  if (_typeFilter != null)
                    InputChip(
                      label: Text(_typeFilter == TransactionType.expense ? '필터: 지출' : '필터: 수입'),
                      onDeleted: () => setState(() => _typeFilter = null),
                    ),
                ],
              ),
            );
          }
          index -= 1;
        }

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
              onTap: () => _showEditModalDirectly(context, transaction),
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

  /// Show transaction edit modal directly (improved UX)
  void _showEditModalDirectly(
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
      builder: (context) => TransactionEditModalSheet(transaction: transaction),
    );
  }

  /// Show transaction detail sheet (kept for future extensibility)
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

  /// Apply search keyword and type filters
  List<TransactionModel> _applyFilters(List<TransactionModel> transactions) {
    return transactions.where((t) {
      final matchesType = _typeFilter == null || t.type == _typeFilter;
      final matchesSearch = _searchKeyword.isEmpty || _matchesSearch(t, _searchKeyword);
      return matchesType && matchesSearch;
    }).toList();
  }

  bool get _hasActiveFilters => _searchKeyword.isNotEmpty || _typeFilter != null;

  bool _matchesSearch(TransactionModel transaction, String keyword) {
    final query = keyword.toLowerCase();
    final numericQuery = query.replaceAll(RegExp(r'[^0-9]'), '');

    if ((transaction.memo ?? '').toLowerCase().contains(query)) return true;
    if ((transaction.category ?? '').toLowerCase().contains(query)) return true;
    if (numericQuery.isNotEmpty && transaction.amount.toString().contains(numericQuery)) return true;

    return false;
  }

  /// Open search dialog and save keyword
  Future<void> _showSearchDialog(BuildContext context) async {
    final controller = TextEditingController(text: _searchKeyword);

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('거래 검색'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: '메모, 카테고리, 금액으로 검색',
          ),
          autofocus: true,
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(''),
            child: const Text('초기화'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('검색'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _searchKeyword = result;
      });
    }
  }

  /// Open filter chooser (all/expense/income)
  Future<void> _showFilterSheet(BuildContext context) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: const Text('전체 보기'),
              onTap: () => Navigator.of(context).pop('all'),
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: const Text('지출만 보기'),
              onTap: () => Navigator.of(context).pop('expense'),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('수입만 보기'),
              onTap: () => Navigator.of(context).pop('income'),
            ),
          ],
        ),
      ),
    );

    if (!mounted || selected == null) return;

    setState(() {
      switch (selected) {
        case 'expense':
          _typeFilter = TransactionType.expense;
          break;
        case 'income':
          _typeFilter = TransactionType.income;
          break;
        default:
          _typeFilter = null;
      }
    });
  }
}
