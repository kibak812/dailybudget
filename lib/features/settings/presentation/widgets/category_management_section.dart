import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:daily_pace/core/providers/providers.dart';

/// Category Management Section Widget
/// Allows users to add and delete categories for both expense and income
class CategoryManagementSection extends ConsumerWidget {
  const CategoryManagementSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            '카테고리',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 1.2,
                ),
          ),
        ),
        const SizedBox(height: 12),
        _CategorySection(
          title: '지출 카테고리',
          type: CategoryType.expense,
          icon: Icons.remove_circle_outline,
          iconColor: Theme.of(context).colorScheme.error,
        ),
        const SizedBox(height: 16),
        _CategorySection(
          title: '수입 카테고리',
          type: CategoryType.income,
          icon: Icons.add_circle_outline,
          iconColor: Theme.of(context).colorScheme.primary,
        ),
      ],
    );
  }
}

/// Individual category section widget for expense or income
class _CategorySection extends ConsumerStatefulWidget {
  final String title;
  final CategoryType type;
  final IconData icon;
  final Color iconColor;

  const _CategorySection({
    required this.title,
    required this.type,
    required this.icon,
    required this.iconColor,
  });

  @override
  ConsumerState<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends ConsumerState<_CategorySection> {
  final TextEditingController _categoryController = TextEditingController();

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _handleAddCategory() async {
    final name = _categoryController.text.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('카테고리 이름을 입력해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final success =
        await ref.read(categoriesProvider.notifier).addCategory(name, widget.type);

    if (!success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미 존재하는 카테고리입니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('카테고리가 추가되었습니다.'),
          backgroundColor: Colors.green,
        ),
      );
    }

    _categoryController.clear();
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('카테고리가 수정되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('이미 존재하는 카테고리 이름입니다.'),
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
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('삭제'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(categoriesProvider.notifier).deleteCategory(category, widget.type);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('카테고리가 삭제되었습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(categoriesProvider);
    final categories = ref.read(categoriesProvider.notifier).getCategoriesByType(widget.type);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title with icon
          Row(
            children: [
              Icon(
                widget.icon,
                size: 20,
                color: widget.iconColor,
              ),
              const SizedBox(width: 8),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: widget.iconColor,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Add category input
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    hintText: '새 카테고리 추가',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: widget.iconColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _handleAddCategory(),
                  onChanged: (value) {
                    setState(() {}); // Rebuild to enable/disable button
                  },
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _categoryController.text.isEmpty
                    ? null
                    : _handleAddCategory,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: widget.iconColor.withOpacity(0.1),
                  foregroundColor: widget.iconColor,
                ),
                child: const Icon(Icons.add, size: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Category list with drag & drop
          if (categories.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  '카테고리가 없습니다',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[500],
                      ),
                ),
              ),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              buildDefaultDragHandles: false,
              itemCount: categories.length,
              onReorder: (oldIndex, newIndex) {
                ref.read(categoriesProvider.notifier).reorderCategory(
                      widget.type,
                      oldIndex,
                      newIndex,
                    );
              },
              proxyDecorator: (child, index, animation) {
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    final elevation = Tween<double>(begin: 0, end: 6).animate(animation).value;
                    return Material(
                      elevation: elevation,
                      borderRadius: BorderRadius.circular(12),
                      child: child,
                    );
                  },
                  child: child,
                );
              },
              itemBuilder: (context, index) {
                final category = categories[index];
                return Container(
                  key: ValueKey('${widget.type.name}_$category'),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: widget.iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.iconColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      ReorderableDelayedDragStartListener(
                        index: index,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          child: Icon(
                            Icons.drag_handle,
                            size: 20,
                            color: widget.iconColor.withOpacity(0.6),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _handleEditCategory(category),
                          child: Text(
                            category,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: widget.iconColor,
                                ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _handleEditCategory(category),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: widget.iconColor.withOpacity(0.6),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => _handleDeleteCategory(category),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.close,
                            size: 18,
                            color: widget.iconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
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
      title: const Text('카테고리 수정'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(
          hintText: '카테고리 이름',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onSubmitted: (value) => Navigator.pop(context, value.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, null),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('저장'),
        ),
      ],
    );
  }
}
