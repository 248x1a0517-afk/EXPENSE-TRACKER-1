import 'package:intl/intl.dart';
import 'expense_category.dart';

/// Immutable domain model representing a recorded financial expense.
class Expense {
  final String id;
  final String title;
  final double amount;
  final ExpenseCategory category;
  final DateTime date;
  final String note;
  final DateTime createdAt;

  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.note,
    required this.createdAt,
  });

  /// Currency formatted string (e.g., "$45.50")
  String get formattedAmount {
    final currencyFormatter = NumberFormat.simpleCurrency(decimalDigits: 2);
    return currencyFormatter.format(amount);
  }

  /// Friendly human-readable date (e.g., "Nov 7, 2026")
  String get formattedDate {
    return DateFormat.yMMMd().format(date);
  }

  /// Detailed date & time for detail screen (e.g., "Saturday, Nov 7, 2026")
  String get formattedFullDate {
    return DateFormat.yMMMMEEEEd().format(date);
  }

  /// Creates a copy of this Expense with given fields replaced
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    ExpenseCategory? category,
    DateTime? date,
    String? note,
    DateTime? createdAt,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Deserializes a JSON map into an Expense object
  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == (json['category'] as String),
        orElse: () => ExpenseCategory.other,
      ),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String? ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] as String? ?? json['date'] as String,
      ),
    );
  }

  /// Serializes this Expense object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'category': category.name,
      'date': date.toIso8601String(),
      'note': note,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Expense &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
