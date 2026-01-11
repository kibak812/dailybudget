import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/core/utils/formatters.dart';
import 'package:daily_pace/core/widgets/banner_ad_widget.dart';
import 'package:daily_pace/features/transaction/data/models/transaction_model.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/transaction_list_item.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/transaction_edit_sheet.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/add_transaction_sheet.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/month_navigation_bar.dart';
import 'package:daily_pace/features/transaction/presentation/widgets/monthly_pace_mosaic.dart';

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
  String? _selectedDate;  // null = show all dates (YYYY-MM-DD format)

  // Breakpoint for wide layout (Galaxy Fold inner display)
  static const double _wideBreakpoint = 600.0;

  @override
  Widget build(BuildContext context) {
    final currentMonth = ref.watch(currentMonthProvider);
    final transactions = ref.watch(transactionProvider);
    final mosaicData = ref.watch(monthlyMosaicProvider);

    // Listen for month changes and reset date selection
    ref.listen(currentMonthProvider, (previous, next) {
      if (previous != next && _selectedDate != null) {
        setState(() => _selectedDate = null);
      }
    });

    // Filter transactions for current month
    final monthTransactions = _filterByMonth(transactions, currentMonth);

    // Filter by selected date (if any)
    final dateFilteredTransactions = _selectedDate == null
      ? monthTransactions
      : monthTransactions.where((t) => t.date == _selectedDate).toList();

    // Apply search/type filters
    final filteredTransactions = _applyFilters(dateFilteredTransactions);

    // Group by date
    final grouped = _groupByDate(filteredTransactions);

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= _wideBreakpoint;

                if (isWide) {
                  return _buildWideLayout(context, mosaicData, grouped, filteredTransactions);
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(transactionProvider.notifier).loadTransactions();
                  },
                  child: _buildBody(context, mosaicData, grouped, filteredTransactions),
                );
              },
            ),
          ),
          const SafeArea(
            top: false,
            child: BannerAdWidget(),
          ),
        ],
      ),
      // FAB only shown in narrow layout (wide layout has FAB in left panel)
      floatingActionButton: LayoutBuilder(
        builder: (context, constraints) {
          // Check if we're in wide mode by getting the parent constraints
          final screenWidth = MediaQuery.of(context).size.width;
          if (screenWidth >= _wideBreakpoint) {
            return const SizedBox.shrink();
          }
          return FloatingActionButton(
            onPressed: () => _showAddTransactionSheet(context),
            child: const Icon(Icons.add),
          );
        },
      ),
    );
  }

  /// Wide layout for foldable devices (2-column split)
  Widget _buildWideLayout(
    BuildContext context,
    dynamic mosaicData,
    Map<String, List<TransactionModel>> grouped,
    List<TransactionModel> filteredTransactions,
  ) {
    return Row(
      children: [
        // Left panel: Calendar with FAB
        SizedBox(
          width: 380,
          child: Stack(
            children: [
              Column(
                children: [
                  const MonthNavigationBar(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: MonthlyPaceMosaic(
                        data: mosaicData,
                        selectedDate: _selectedDate,
                        onDateTap: _onMosaicDateTap,
                      ),
                    ),
                  ),
                ],
              ),
              // FAB positioned at bottom-left of left panel
              Positioned(
                left: 16,
                bottom: 16,
                child: FloatingActionButton(
                  onPressed: () => _showAddTransactionSheet(context),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
        // Vertical divider
        const VerticalDivider(width: 1, thickness: 1),
        // Right panel: Transaction list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(transactionProvider.notifier).loadTransactions();
            },
            child: _buildTransactionList(context, grouped, filteredTransactions),
          ),
        ),
      ],
    );
  }

  /// Transaction list for right panel in wide layout
  Widget _buildTransactionList(
    BuildContext context,
    Map<String, List<TransactionModel>> grouped,
    List<TransactionModel> filteredTransactions,
  ) {
    // Sort dates in descending order (newest first)
    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return CustomScrollView(
      slivers: [
        // Active filters chips
        if (_hasActiveFilters)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_searchKeyword.isNotEmpty)
                    InputChip(
                      label: Text('${context.l10n.common_search}: $_searchKeyword'),
                      onDeleted: () => setState(() => _searchKeyword = ''),
                    ),
                  if (_typeFilter != null)
                    InputChip(
                      label: Text(_typeFilter == TransactionType.expense
                          ? context.l10n.transaction_expense
                          : context.l10n.transaction_income),
                      onDeleted: () => setState(() => _typeFilter = null),
                    ),
                ],
              ),
            ),
          ),

        // Selected date indicator
        if (_selectedDate != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.transaction_dateTransactions(Formatters.formatDate(_selectedDate!, context)),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => setState(() => _selectedDate = null),
                    child: Text(context.l10n.transaction_viewAll),
                  ),
                ],
              ),
            ),
          ),

        // Transaction list
        if (filteredTransactions.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(context),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final date = sortedDates[index];
                final dateTransactions = grouped[date]!;
                final dayTotal = _calculateDayTotal(dateTransactions);

                return _buildDateSection(
                    context, date, dateTransactions, dayTotal);
              },
              childCount: sortedDates.length,
            ),
          ),
      ],
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(context.l10n.nav_transactions),
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
    dynamic mosaicData,
    Map<String, List<TransactionModel>> grouped,
    List<TransactionModel> filteredTransactions,
  ) {
    // Sort dates in descending order (newest first)
    final sortedDates = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return CustomScrollView(
      slivers: [
        // Month navigation
        const SliverToBoxAdapter(
          child: MonthNavigationBar(),
        ),

        // Monthly pace mosaic
        SliverToBoxAdapter(
          child: MonthlyPaceMosaic(
            data: mosaicData,
            selectedDate: _selectedDate,
            onDateTap: _onMosaicDateTap,
          ),
        ),

        // Active filters chips
        if (_hasActiveFilters)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_searchKeyword.isNotEmpty)
                    InputChip(
                      label: Text('${context.l10n.common_search}: $_searchKeyword'),
                      onDeleted: () => setState(() => _searchKeyword = ''),
                    ),
                  if (_typeFilter != null)
                    InputChip(
                      label: Text(_typeFilter == TransactionType.expense
                          ? context.l10n.transaction_expense
                          : context.l10n.transaction_income),
                      onDeleted: () => setState(() => _typeFilter = null),
                    ),
                ],
              ),
            ),
          ),

        // Transaction list
        if (filteredTransactions.isEmpty)
          SliverFillRemaining(
            child: _buildEmptyState(context),
          )
        else
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final date = sortedDates[index];
                final dateTransactions = grouped[date]!;
                final dayTotal = _calculateDayTotal(dateTransactions);

                return _buildDateSection(
                    context, date, dateTransactions, dayTotal);
              },
              childCount: sortedDates.length,
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);

    String message;
    if (_selectedDate != null) {
      message = context.l10n.transaction_noTransactionsDate;
    } else if (_hasActiveFilters) {
      message = context.l10n.transaction_noSearchResults;
    } else {
      message = context.l10n.transaction_noTransactions;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.outline,
          ),
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

  /// Get day of week localized
  String _getDayOfWeek(BuildContext context, String dateStr) {
    final date = DateTime.parse(dateStr);
    final weekdays = [
      context.l10n.weekday_mon,
      context.l10n.weekday_tue,
      context.l10n.weekday_wed,
      context.l10n.weekday_thu,
      context.l10n.weekday_fri,
      context.l10n.weekday_sat,
      context.l10n.weekday_sun,
    ];
    return weekdays[date.weekday - 1];
  }

  /// Group transactions by date
  Map<String, List<TransactionModel>> _groupByDate(List<TransactionModel> transactions) {
    final Map<String, List<TransactionModel>> grouped = {};
    for (final transaction in transactions) {
      if (!grouped.containsKey(transaction.date)) {
        grouped[transaction.date] = [];
      }
      grouped[transaction.date]!.add(transaction);
    }
    return grouped;
  }

  /// Calculate total spent (expenses only)
  int _calculateTotalSpent(List<TransactionModel> transactions) {
    return transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<int>(0, (sum, t) => sum + t.amount);
  }

  /// Calculate day total (net: expenses - income)
  int _calculateDayTotal(List<TransactionModel> transactions) {
    final expenses = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<int>(0, (sum, t) => sum + t.amount);
    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<int>(0, (sum, t) => sum + t.amount);
    return expenses - income;
  }

  /// Build date section with transactions
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
        // Date header with total
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
          child: Row(
            children: [
              Text(
                '${Formatters.formatDate(date, context)} (${_getDayOfWeek(context, date)})',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              if (dayTotal != 0)
                Text(
                  dayTotal < 0
                      ? '+${Formatters.formatCurrency(dayTotal.abs(), context)}'
                      : '-${Formatters.formatCurrency(dayTotal, context)}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: dayTotal < 0 ? Colors.green[700] : theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ),

        // Transactions for this date
        ...transactions.map((transaction) => TransactionListItem(
          transaction: transaction,
          onTap: () => _showEditModalDirectly(context, transaction),
          onDismissed: () => _handleDelete(transaction),
        )),
      ],
    );
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
        initialDate: _selectedDate != null
            ? DateTime.parse(_selectedDate!)
            : DateTime.now(),
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

  void _onMosaicDateTap(String dateStr) {
    setState(() {
      if (_selectedDate == dateStr) {
        // Re-tapping same date - deselect
        _selectedDate = null;
      } else {
        // Select new date
        _selectedDate = dateStr;
      }
    });
  }

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
      builder: (dialogContext) => AlertDialog(
        title: Text(dialogContext.l10n.common_search),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: dialogContext.l10n.transaction_memoHint,
          ),
          autofocus: true,
          onSubmitted: (value) => Navigator.of(dialogContext).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(''),
            child: Text(dialogContext.l10n.common_reset),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text.trim()),
            child: Text(dialogContext.l10n.common_search),
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
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive),
              title: Text(sheetContext.l10n.common_confirm),
              onTap: () => Navigator.of(sheetContext).pop('all'),
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline),
              title: Text(sheetContext.l10n.transaction_expense),
              onTap: () => Navigator.of(sheetContext).pop('expense'),
            ),
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: Text(sheetContext.l10n.transaction_income),
              onTap: () => Navigator.of(sheetContext).pop('income'),
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
