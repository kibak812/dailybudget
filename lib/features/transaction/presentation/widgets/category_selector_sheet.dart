import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/providers/providers.dart';

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카테고리가 추가되었습니다')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미 존재하는 카테고리입니다'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleDeleteCategory(String category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카테고리 삭제'),
        content: Text('"$category" 카테고리를 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(categoriesProvider.notifier).deleteCategory(
        category,
        widget.type,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('카테고리가 삭제되었습니다')),
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
                    widget.type == CategoryType.expense ? '지출 카테고리' : '수입 카테고리',
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
                  tooltip: _isEditMode ? '완료' : '편집',
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
                        hintText: '새 카테고리 추가',
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
                        '카테고리가 없습니다',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
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

                      return ReorderableDragStartListener(
                        key: ValueKey('${widget.type.name}_$category'),
                        index: index,
                        child: InkWell(
                          onTap: () => _handleSelect(category),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 16,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? iconColor.withOpacity(0.08)
                                  : null,
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                  width: 1,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Check icon for selected
                                if (isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(right: 12),
                                    child: Icon(
                                      Icons.check,
                                      color: iconColor,
                                      size: 20,
                                    ),
                                  )
                                else
                                  const SizedBox(width: 32),

                                // Category name
                                Expanded(
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

                                // Delete button (edit mode only)
                                if (_isEditMode)
                                  IconButton(
                                    onPressed: () => _handleDeleteCategory(category),
                                    icon: const Icon(Icons.close, size: 20),
                                    color: Colors.grey[600],
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
