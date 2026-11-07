import 'package:flutter/material.dart';
import '../models/expense_category.dart';

/// Reusable filter or display chip for an expense category.
class CategoryChip extends StatelessWidget {
  final ExpenseCategory category;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FilterChip(
      selected: isSelected,
      showCheckmark: false,
      avatar: Icon(
        category.icon,
        size: 16,
        color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
      ),
      label: Text(category.displayName),
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
      ),
      selectedColor: colorScheme.primary,
      backgroundColor: colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      onSelected: onSelected,
    );
  }
}
