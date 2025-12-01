import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Category type enum
enum CategoryType {
  expense,
  income,
}

/// StateNotifierProvider for managing categories
/// Categories are stored in SharedPreferences with type prefix (expense:/income:)
final categoriesProvider = StateNotifierProvider<CategoriesNotifier, List<String>>((ref) {
  return CategoriesNotifier();
});

/// Notifier for managing category state
class CategoriesNotifier extends StateNotifier<List<String>> {
  CategoriesNotifier() : super([]) {
    // Load categories when notifier is created
    loadCategories();
  }

  /// SharedPreferences key for storing categories
  static const String _categoriesKey = 'categories';

  /// Prefix for expense categories
  static const String _expensePrefix = 'expense:';

  /// Prefix for income categories
  static const String _incomePrefix = 'income:';

  /// Default expense categories
  static const List<String> _defaultExpenseCategories = [
    '식비',
    '교통',
    '쇼핑',
    '생활',
    '취미',
    '의료',
    '기타',
  ];

  /// Default income categories
  static const List<String> _defaultIncomeCategories = [
    '급여',
    '용돈',
    '보너스',
    '기타',
  ];

  /// Get categories by type
  List<String> getCategoriesByType(CategoryType type) {
    final prefix = type == CategoryType.expense ? _expensePrefix : _incomePrefix;
    return state
        .where((cat) => cat.startsWith(prefix))
        .map((cat) => cat.substring(prefix.length))
        .toList();
  }

  /// Get display name from full category name (removes prefix)
  String getDisplayName(String fullName) {
    if (fullName.startsWith(_expensePrefix)) {
      return fullName.substring(_expensePrefix.length);
    } else if (fullName.startsWith(_incomePrefix)) {
      return fullName.substring(_incomePrefix.length);
    }
    return fullName;
  }

  /// Get full category name with prefix
  String getFullName(String displayName, CategoryType type) {
    final prefix = type == CategoryType.expense ? _expensePrefix : _incomePrefix;
    return '$prefix$displayName';
  }

  /// Load categories from SharedPreferences
  /// If no categories exist, use default categories
  /// Also handles migration of old categories without prefix
  Future<void> loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCategories = prefs.getStringList(_categoriesKey);

      if (savedCategories != null && savedCategories.isNotEmpty) {
        // Migrate old categories without prefix
        final migratedCategories = savedCategories.map((cat) {
          if (!cat.startsWith(_expensePrefix) && !cat.startsWith(_incomePrefix)) {
            // Old category without prefix - add expense prefix
            return '$_expensePrefix$cat';
          }
          return cat;
        }).toList();

        // Save migrated categories if any changes were made
        if (migratedCategories.join(',') != savedCategories.join(',')) {
          state = migratedCategories;
          await _saveCategories();
        } else {
          state = savedCategories;
        }
      } else {
        // Initialize with default categories
        final defaultCategories = [
          ..._defaultExpenseCategories.map((cat) => '$_expensePrefix$cat'),
          ..._defaultIncomeCategories.map((cat) => '$_incomePrefix$cat'),
        ];
        state = defaultCategories;
        await _saveCategories();
      }
    } catch (e) {
      print('Error loading categories: $e');
      // Fall back to default categories on error
      final defaultCategories = [
        ..._defaultExpenseCategories.map((cat) => '$_expensePrefix$cat'),
        ..._defaultIncomeCategories.map((cat) => '$_incomePrefix$cat'),
      ];
      state = defaultCategories;
    }
  }

  /// Save categories to SharedPreferences
  Future<void> _saveCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_categoriesKey, state);
    } catch (e) {
      print('Error saving categories: $e');
    }
  }

  /// Add a new category with type
  /// Returns true if successful, false if category already exists
  Future<bool> addCategory(String name, CategoryType type) async {
    if (name.trim().isEmpty) {
      return false;
    }

    final trimmedName = name.trim();
    final fullName = getFullName(trimmedName, type);

    // Check if category already exists
    if (state.contains(fullName)) {
      return false;
    }

    // Add category
    state = [...state, fullName];
    await _saveCategories();
    return true;
  }

  /// Delete a category by display name and type
  /// Returns true if successful, false if category doesn't exist
  Future<bool> deleteCategory(String displayName, CategoryType type) async {
    final fullName = getFullName(displayName, type);

    if (!state.contains(fullName)) {
      return false;
    }

    // Remove category
    state = state.where((category) => category != fullName).toList();
    await _saveCategories();
    return true;
  }

  /// Update a category name
  /// Returns true if successful
  Future<bool> updateCategory(String oldDisplayName, String newDisplayName, CategoryType type) async {
    final oldFullName = getFullName(oldDisplayName, type);

    if (!state.contains(oldFullName) || newDisplayName.trim().isEmpty) {
      return false;
    }

    final trimmedNewName = newDisplayName.trim();
    final newFullName = getFullName(trimmedNewName, type);

    // Check if new name already exists (and it's not the same as old name)
    if (oldFullName != newFullName && state.contains(newFullName)) {
      return false;
    }

    // Update category
    state = state.map((category) {
      return category == oldFullName ? newFullName : category;
    }).toList();

    await _saveCategories();
    return true;
  }

  /// Reset categories to default
  Future<void> resetToDefaults() async {
    final defaultCategories = [
      ..._defaultExpenseCategories.map((cat) => '$_expensePrefix$cat'),
      ..._defaultIncomeCategories.map((cat) => '$_incomePrefix$cat'),
    ];
    state = defaultCategories;
    await _saveCategories();
  }
}
