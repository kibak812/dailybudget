import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/extensions/localization_extension.dart';
import 'package:daily_pace/core/providers/providers.dart';
import 'package:daily_pace/app/theme/app_colors.dart';

/// Bottom sheet for selecting and managing categories
/// Supports: selection, add, delete, reorder (drag & drop)
class CategorySelectorSheet extends ConsumerStatefulWidget {
  final CategoryType type;
  final String? selectedCategory;
  final Function(String?) onSelected;

  const CategorySelectorSheet({
    super.key,
    required this.type,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  ConsumerState<CategorySelectorSheet> createState() => _CategorySelectorSheetState();
}

class _CategorySelectorSheetState extends ConsumerState<CategorySelectorSheet> {
  bool _isEditMode = false;
  final _addController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _addController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _handleAddCategory() async {
    final name = _addController.text.trim();
    if (name.isEmpty) return;

    final success = await ref.read(categoriesProvider.notifier).addCategory(
      name,
      widget.type,
    );

    if (success) {
      _addController.clear();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.error_categoryExists),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteCategory(String category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.category_deleteTitle),
        content: Text(ctx.l10n.category_deleteMessage(category)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(ctx.l10n.common_delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(categoriesProvider.notifier).deleteCategory(
        category,
        widget.type,
      );
    }
  }

  Future<void> _handleEditCategory(String category) async {
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => _CategoryEditDialog(initialName: category),
    );

    if (newName != null && newName.isNotEmpty && newName != category) {
      // Wait for dialog dispose to complete before modifying state
      await Future.delayed(const Duration(milliseconds: 50));

      if (!mounted) return;

      final success = await ref.read(categoriesProvider.notifier).updateCategory(
            category,
            newName,
            widget.type,
          );

      if (!mounted) return;

      if (success) {
        // Refresh transaction provider to reflect category name changes
        ref.invalidate(transactionProvider);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.error_categoryExists),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _handleReorder(int oldIndex, int newIndex) {
    ref.read(categoriesProvider.notifier).reorderCategory(
      widget.type,
      oldIndex,
      newIndex,
    );
  }

  void _handleSelect(String category) {
    if (_isEditMode) return; // Don't select in edit mode
    widget.onSelected(category);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = widget.type == CategoryType.expense
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    ref.watch(categoriesProvider);
    final categories = ref.read(categoriesProvider.notifier).getCategoriesByType(widget.type);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 16, 8),
            child: Row(
              children: [
                Icon(
                  widget.type == CategoryType.expense
                      ? Icons.remove_circle_outline
                      : Icons.add_circle_outline,
                  color: iconColor,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.type == CategoryType.expense ? context.l10n.category_expense : context.l10n.category_income,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                // Edit mode toggle
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditMode = !_isEditMode;
                      if (!_isEditMode) {
                        _addController.clear();
                      }
                    });
                  },
                  icon: Icon(
                    _isEditMode ? Icons.check : Icons.edit,
                    color: _isEditMode ? theme.colorScheme.primary : null,
                  ),
                  tooltip: _isEditMode ? context.l10n.common_confirm : context.l10n.common_edit,
                ),
              ],
            ),
          ),

          // Add category input (edit mode only)
          if (_isEditMode)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _addController,
                      focusNode: _focusNode,
                      decoration: InputDecoration(
                        hintText: context.l10n.category_add,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: iconColor, width: 2),
                        ),
                      ),
                      onSubmitted: (_) => _handleAddCategory(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _handleAddCategory,
                    icon: const Icon(Icons.add),
                    style: IconButton.styleFrom(
                      backgroundColor: iconColor.withOpacity(0.1),
                      foregroundColor: iconColor,
                    ),
                  ),
                ],
              ),
            ),

          const Divider(height: 1),

          // Category list
          Flexible(
            child: categories.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        context.l10n.category_empty,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                : ReorderableListView.builder(
                    shrinkWrap: true,
                    buildDefaultDragHandles: false,
                    itemCount: categories.length,
                    onReorder: _handleReorder,
                    proxyDecorator: (child, index, animation) {
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (context, child) {
                          final elevation = Tween<double>(begin: 0, end: 4)
                              .animate(animation)
                              .value;
                          return Material(
                            elevation: elevation,
                            color: theme.colorScheme.surface,
                            child: child,
                          );
                        },
                        child: child,
                      );
                    },
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      final isSelected = category == widget.selectedCategory;

                      return Container(
                        key: ValueKey('${widget.type.name}_$category'),
                        child: InkWell(
                          onTap: () => _handleSelect(category),
                          child: Container(
                            padding: EdgeInsets.only(
                              left: _isEditMode ? 0 : 24,
                              right: 8,
                              top: 8,
                              bottom: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? iconColor.withOpacity(0.08)
                                  : null,
                              border: Border(
                                bottom: BorderSide(
                                  color: AppColors.border,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Drag handle (edit mode only)
                                if (_isEditMode)
                                  ReorderableDelayedDragStartListener(
                                    index: index,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      child: Icon(
                                        Icons.drag_handle,
                                        size: 20,
                                        color: AppColors.textTertiary,
                                      ),
                                    ),
                                  ),

                                // Check icon for selected
                                if (!_isEditMode && isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Icon(
                                      Icons.check,
                                      color: iconColor,
                                      size: 20,
                                    ),
                                  )
                                else if (!_isEditMode)
                                  const SizedBox(width: 32),

                                // Category name
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    child: Text(
                                      category,
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                        color: isSelected ? iconColor : null,
                                      ),
                                    ),
                                  ),
                                ),

                                // Edit button (edit mode only)
                                if (_isEditMode)
                                  IconButton(
                                    onPressed: () => _handleEditCategory(category),
                                    icon: const Icon(Icons.edit_outlined, size: 18),
                                    color: AppColors.textSecondary,
                                    visualDensity: VisualDensity.compact,
                                  ),

                                // Delete button (edit mode only)
                                if (_isEditMode)
                                  IconButton(
                                    onPressed: () => _handleDeleteCategory(category),
                                    icon: const Icon(Icons.close, size: 20),
                                    color: AppColors.textSecondary,
                                    visualDensity: VisualDensity.compact,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Bottom padding
          SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
        ],
      ),
    );
  }
}

/// Separate dialog widget to properly manage TextEditingController lifecycle
class _CategoryEditDialog extends StatefulWidget {
  final String initialName;

  const _CategoryEditDialog({required this.initialName});

  @override
  State<_CategoryEditDialog> createState() => _CategoryEditDialogState();
}

class _CategoryEditDialogState extends State<_CategoryEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.category_editTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: context.l10n.category_name,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onSubmitted: (value) => Navigator.pop(context, value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: Text(context.l10n.common_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: Text(context.l10n.common_save),
        ),
      ],
    );
  }
}
