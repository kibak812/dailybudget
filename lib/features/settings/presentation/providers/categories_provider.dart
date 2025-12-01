import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// StateNotifierProvider for managing categories
/// Categories are stored in SharedPreferences
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

  /// Default categories
  static const List<String> _defaultCategories = [
    '식비',
    '교통',
    '쇼핑',
    '생활',
    '취미',
    '의료',
    '기타',
  ];

  /// Load categories from SharedPreferences
  /// If no categories exist, use default categories
  Future<void> loadCategories() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCategories = prefs.getStringList(_categoriesKey);

      if (savedCategories != null && savedCategories.isNotEmpty) {
        state = savedCategories;
      } else {
        // Initialize with default categories
        state = List.from(_defaultCategories);
        await _saveCategories();
      }
    } catch (e) {
      print('Error loading categories: $e');
      // Fall back to default categories on error
      state = List.from(_defaultCategories);
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

  /// Add a new category
  /// Returns true if successful, false if category already exists
  Future<bool> addCategory(String name) async {
    if (name.trim().isEmpty) {
      return false;
    }

    final trimmedName = name.trim();

    // Check if category already exists
    if (state.contains(trimmedName)) {
      return false;
    }

    // Add category
    state = [...state, trimmedName];
    await _saveCategories();
    return true;
  }

  /// Delete a category
  /// Returns true if successful, false if category doesn't exist
  Future<bool> deleteCategory(String name) async {
    if (!state.contains(name)) {
      return false;
    }

    // Remove category
    state = state.where((category) => category != name).toList();
    await _saveCategories();
    return true;
  }

  /// Update a category name
  /// Returns true if successful
  Future<bool> updateCategory(String oldName, String newName) async {
    if (!state.contains(oldName) || newName.trim().isEmpty) {
      return false;
    }

    final trimmedNewName = newName.trim();

    // Check if new name already exists (and it's not the same as old name)
    if (oldName != trimmedNewName && state.contains(trimmedNewName)) {
      return false;
    }

    // Update category
    state = state.map((category) {
      return category == oldName ? trimmedNewName : category;
    }).toList();

    await _saveCategories();
    return true;
  }

  /// Reset categories to default
  Future<void> resetToDefaults() async {
    state = List.from(_defaultCategories);
    await _saveCategories();
  }
}
