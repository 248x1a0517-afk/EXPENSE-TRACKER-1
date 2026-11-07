import 'package:flutter/material.dart';

/// Predefined expense categories with display labels and Material icons.
enum ExpenseCategory {
  foodAndDining,
  transportation,
  shopping,
  entertainment,
  utilities,
  health,
  education,
  other;

  /// User-friendly display title
  String get displayName {
    switch (this) {
      case ExpenseCategory.foodAndDining:
        return 'Food & Dining';
      case ExpenseCategory.transportation:
        return 'Transportation';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.entertainment:
        return 'Entertainment';
      case ExpenseCategory.utilities:
        return 'Bills & Utilities';
      case ExpenseCategory.health:
        return 'Health & Fitness';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  /// Corresponding Material design icon
  IconData get icon {
    switch (this) {
      case ExpenseCategory.foodAndDining:
        return Icons.restaurant;
      case ExpenseCategory.transportation:
        return Icons.directions_car;
      case ExpenseCategory.shopping:
        return Icons.shopping_bag;
      case ExpenseCategory.entertainment:
        return Icons.movie;
      case ExpenseCategory.utilities:
        return Icons.receipt_long;
      case ExpenseCategory.health:
        return Icons.fitness_center;
      case ExpenseCategory.education:
        return Icons.school;
      case ExpenseCategory.other:
        return Icons.more_horiz;
    }
  }
}
