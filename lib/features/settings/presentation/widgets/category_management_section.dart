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
          // Category chips
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
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                return Container(
                  decoration: BoxDecoration(
                    color: widget.iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: widget.iconColor.withOpacity(0.2)),
                  ),
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 8,
                    top: 8,
                    bottom: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        category,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: widget.iconColor,
                            ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _handleDeleteCategory(category),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: widget.iconColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}
