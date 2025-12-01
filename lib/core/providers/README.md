# Riverpod Providers Documentation

This document describes the Riverpod provider structure for the Daily Pace app.

## Overview

The app uses Riverpod for state management with a clean architecture approach. Providers are organized by feature and follow a consistent pattern.

## Provider Structure

### 1. Core Providers

#### `isar_provider.dart`
- **Type**: `FutureProvider<Isar>`
- **Purpose**: Provides singleton Isar database instance
- **Collections**: BudgetModel, TransactionModel, RecurringTransactionModel
- **Usage**: `ref.read(isarProvider.future)` or `ref.watch(isarProvider)`

```dart
// Example usage
final isar = await ref.read(isarProvider.future);
```

### 2. Budget Providers

#### `budget_provider.dart`
- **Type**: `StateNotifierProvider<BudgetNotifier, List<BudgetModel>>`
- **State**: List of all budgets
- **Methods**:
  - `loadBudgets()`: Reload from database
  - `setBudget(year, month, amount)`: Create or update budget
  - `getBudget(year, month)`: Get specific budget (returns null if not found)
  - `deleteBudget(year, month)`: Delete budget

```dart
// Example usage
final budgets = ref.watch(budgetProvider);
await ref.read(budgetProvider.notifier).setBudget(2024, 12, 1000000);
```

#### `current_month_provider.dart`
- **Type**: `StateProvider<CurrentMonth>`
- **State**: Currently selected month/year
- **Default**: Current month
- **Model**: `CurrentMonth(year: int, month: int)`

```dart
// Example usage
final currentMonth = ref.watch(currentMonthProvider);
ref.read(currentMonthProvider.notifier).state = CurrentMonth(year: 2024, month: 12);
```

### 3. Transaction Providers

#### `transaction_provider.dart`
- **Type**: `StateNotifierProvider<TransactionNotifier, List<TransactionModel>>`
- **State**: List of all transactions (sorted by date descending)
- **Methods**:
  - `loadTransactions()`: Reload from database
  - `addTransaction(transaction)`: Add new transaction
  - `updateTransaction(id, updates)`: Update existing transaction
  - `deleteTransaction(id)`: Delete transaction
  - `getTransactionsForMonth(year, month)`: Filter by month
  - `getTransactionsForDate(date)`: Filter by date

```dart
// Example usage
final transactions = ref.watch(transactionProvider);
await ref.read(transactionProvider.notifier).addTransaction(newTransaction);

// Get filtered transactions
final monthTransactions = ref.read(transactionProvider.notifier)
    .getTransactionsForMonth(2024, 12);
```

### 4. Recurring Transaction Providers

#### `recurring_provider.dart`
- **Type**: `StateNotifierProvider<RecurringNotifier, List<RecurringTransactionModel>>`
- **State**: List of all recurring transactions
- **Methods**:
  - `loadRecurringTransactions()`: Reload from database
  - `addRecurringTransaction(recurring)`: Add new recurring transaction
  - `updateRecurringTransaction(id, updates)`: Update existing
  - `deleteRecurringTransaction(id)`: Delete recurring transaction
  - `toggleActive(id)`: Toggle isActive status
  - `generateForMonth(year, month)`: Generate transactions for month

```dart
// Example usage
final recurring = ref.watch(recurringProvider);
await ref.read(recurringProvider.notifier).generateForMonth(2024, 12);
await ref.read(recurringProvider.notifier).toggleActive(1);
```

### 5. Daily Budget Providers

#### `daily_budget_provider.dart`
- **Type**: `Provider<DailyBudgetData>` (computed)
- **Dependencies**:
  - `budgetProvider`
  - `transactionProvider`
  - `currentMonthProvider`
- **Returns**: `DailyBudgetData` with calculated values
- **Auto-updates**: When any dependency changes

```dart
// Example usage
final dailyBudget = ref.watch(dailyBudgetProvider);
print('Daily budget: ${dailyBudget.dailyBudgetNow}');
print('Spent today: ${dailyBudget.spentToday}');
```

#### `dailyBudgetHistoryProvider`
- **Type**: `Provider<List<DailyBudgetHistoryItem>>` (computed)
- **Returns**: Daily budget history from day 1 to current day
- **Usage**: For displaying charts

```dart
// Example usage
final history = ref.watch(dailyBudgetHistoryProvider);
// Use for chart rendering
```

### 6. Settings Providers

#### `categories_provider.dart`
- **Type**: `StateNotifierProvider<CategoriesNotifier, List<String>>`
- **State**: List of category names
- **Storage**: SharedPreferences
- **Default Categories**: ['식비', '교통', '쇼핑', '생활', '취미', '의료', '기타']
- **Methods**:
  - `loadCategories()`: Load from SharedPreferences
  - `addCategory(name)`: Add new category (returns bool)
  - `deleteCategory(name)`: Delete category (returns bool)
  - `updateCategory(oldName, newName)`: Rename category (returns bool)
  - `resetToDefaults()`: Reset to default categories

```dart
// Example usage
final categories = ref.watch(categoriesProvider);
await ref.read(categoriesProvider.notifier).addCategory('새 카테고리');
```

## Provider Usage Patterns

### Reading Data (One-time)
Use `ref.read()` when you need to access data once without rebuilding on changes:

```dart
final budget = ref.read(budgetProvider.notifier).getBudget(2024, 12);
```

### Watching Data (Reactive)
Use `ref.watch()` when you want the widget to rebuild when data changes:

```dart
final transactions = ref.watch(transactionProvider);
```

### Calling Methods
Use `.notifier` to access methods on StateNotifier:

```dart
await ref.read(transactionProvider.notifier).addTransaction(transaction);
```

### Async Providers
For FutureProvider, use `.future` to await or `.when()` to handle states:

```dart
// Await
final isar = await ref.read(isarProvider.future);

// Handle states in UI
ref.watch(isarProvider).when(
  data: (isar) => Text('Database ready'),
  loading: () => CircularProgressIndicator(),
  error: (error, stack) => Text('Error: $error'),
)
```

## Initialization Order

1. `isarProvider` - Database initialized first
2. Data providers load automatically in their constructors:
   - `budgetProvider`
   - `transactionProvider`
   - `recurringProvider`
   - `categoriesProvider`
3. Computed providers calculate on-demand:
   - `dailyBudgetProvider`
   - `dailyBudgetHistoryProvider`

## Error Handling

All providers include basic error handling with console logging. In production, you may want to:
- Use a dedicated error state
- Show user-friendly error messages
- Implement retry logic
- Log errors to analytics service

## Best Practices

1. **Always await database operations**: Use `await` when calling notifier methods
2. **Use computed providers**: For derived data (like `dailyBudgetProvider`)
3. **Minimize rebuilds**: Use `ref.read()` when you don't need reactivity
4. **Keep state immutable**: Always create new lists/objects when updating state
5. **Load data early**: Providers load their data in constructors for immediate availability

## Integration Example

```dart
class MyHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch providers for reactive updates
    final dailyBudget = ref.watch(dailyBudgetProvider);
    final transactions = ref.watch(transactionProvider);
    final currentMonth = ref.watch(currentMonthProvider);

    return Scaffold(
      body: Column(
        children: [
          Text('Daily Budget: ${dailyBudget.dailyBudgetNow}'),
          Text('Spent Today: ${dailyBudget.spentToday}'),
          ElevatedButton(
            onPressed: () async {
              // Call methods using .notifier
              await ref.read(transactionProvider.notifier)
                  .addTransaction(newTransaction);
            },
            child: Text('Add Transaction'),
          ),
        ],
      ),
    );
  }
}
```

## File Structure

```
lib/
├── core/
│   └── providers/
│       ├── isar_provider.dart
│       ├── providers.dart (central export)
│       └── README.md (this file)
├── features/
    ├── budget/
    │   └── presentation/
    │       └── providers/
    │           ├── budget_provider.dart
    │           └── current_month_provider.dart
    ├── transaction/
    │   └── presentation/
    │       └── providers/
    │           └── transaction_provider.dart
    ├── recurring/
    │   └── presentation/
    │       └── providers/
    │           └── recurring_provider.dart
    ├── daily_budget/
    │   └── presentation/
    │       └── providers/
    │           └── daily_budget_provider.dart
    └── settings/
        └── presentation/
            └── providers/
                └── categories_provider.dart
```

## Quick Import

To import all providers at once:

```dart
import 'package:daily_pace/core/providers/providers.dart';
```

This gives you access to all providers without individual imports.
