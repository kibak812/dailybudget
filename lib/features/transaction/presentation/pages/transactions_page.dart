import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/transaction_list_item.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/transaction_edit_sheet.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/add_transaction_sheet.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/transaction_calendar.dart';

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
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final currentMonth = ref.watch(currentMonthProvider);
    final transactions = ref.watch(transactionProvider);

    // Filter transactions for current month
    final monthTransactions = _filterByMonth(transactions, currentMonth);

    // Filter by selected date
    final selectedDateStr = Formatters.formatDateISO(_selectedDay);
    final dateTransactions = monthTransactions
        .where((t) => t.date == selectedDateStr)
        .toList();

    // Apply additional filters
    final filteredTransactions = _applyFilters(dateTransactions);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(transactionProvider.notifier).loadTransactions();
        },
        child: _buildBody(context, monthTransactions, filteredTransactions),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionSheet(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('거래 내역'),
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
    List<TransactionModel> monthTransactions,
    List<TransactionModel> filteredTransactions,
  ) {
    return Column(
      children: [
        // Calendar widget
        TransactionCalendar(
          focusedDay: _focusedDay,
          selectedDay: _selectedDay,
          transactions: monthTransactions,
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
            });
          },
          onPageChanged: (focusedDay) {
            setState(() {
              _focusedDay = focusedDay;
            });
          },
        ),

        // Active filters chips
        if (_hasActiveFilters)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
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
          ),

        // Selected date header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Text(
            '${Formatters.formatDate(Formatters.formatDateISO(_selectedDay))} (${_getDayOfWeek(Formatters.formatDateISO(_selectedDay))})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Transaction list for selected date
        Expanded(
          child: filteredTransactions.isEmpty
              ? _buildEmptyDateState(context)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filteredTransactions.length,
                  itemBuilder: (context, index) {
                    final transaction = filteredTransactions[index];
                    return TransactionListItem(
                      transaction: transaction,
                      onTap: () => _showEditModalDirectly(context, transaction),
                      onDismissed: () => _handleDelete(transaction),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyDateState(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 64,
              color: theme.colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              '이 날짜에 거래 내역이 없습니다',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '+ 버튼을 눌러 거래를 추가해보세요',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.outline,
              ),
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
      builder: (context) => AddTransactionSheet(
        initialDate: _selectedDay,
      ),
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
