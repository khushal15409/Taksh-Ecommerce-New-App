import 'package:flutter/material.dart';
import 'package:taksh_e_commerce/features/categories/presentation/widgets/category_sidebar_item.dart';
import 'package:taksh_e_commerce/features/product/domain/entities/category.dart';

/// Sidebar displaying the list of categories
class CategoriesSidebar extends StatelessWidget {
  final List<Category> categories;
  final int selectedIndex;
  final ValueChanged<int> onCategorySelected;

  const CategoriesSidebar({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(8, 12, 4, 12),
        itemCount: categories.length,
        itemBuilder: (context, index) => CategorySidebarItem(
          category: categories[index],
          isSelected: selectedIndex == index,
          onTap: () => onCategorySelected(index),
        ),
      ),
    );
  }
}
