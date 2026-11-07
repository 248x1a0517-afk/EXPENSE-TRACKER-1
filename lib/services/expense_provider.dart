import 'package:flutter/foundation.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import 'storage_service.dart';

/// Status of the expense list data operation
enum ExpenseListStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Central state management for the Expense Tracker application.
class ExpenseProvider extends ChangeNotifier {
  final StorageService _storageService;

  ExpenseProvider({required StorageService storageService})
      : _storageService = storageService;

  List<Expense> _expenses = [];
  ExpenseListStatus _status = ExpenseListStatus.initial;
  String? _errorMessage;
  ExpenseCategory? _selectedFilterCategory;
  String _searchQuery = '';

  // Getters
  List<Expense> get allExpenses => List.unmodifiable(_expenses);
  ExpenseListStatus get status => _status;
  String? get errorMessage => _errorMessage;
  ExpenseCategory? get selectedFilterCategory => _selectedFilterCategory;
  String get searchQuery => _searchQuery;

  /// Returns filtered and sorted expenses based on category and search query
  List<Expense> get filteredExpenses {
    var result = List<Expense>.from(_expenses);

    if (_selectedFilterCategory != null) {
      result = result.where((e) => e.category == _selectedFilterCategory).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.toLowerCase().trim();
      result = result.where((e) {
        return e.title.toLowerCase().contains(query) ||
            e.note.toLowerCase().contains(query) ||
            e.category.displayName.toLowerCase().contains(query);
      }).toList();
    }

    // Sort newest date first
    result.sort((a, b) => b.date.compareTo(a.date));
    return result;
  }

  /// Total sum of all recorded expenses
  double get totalExpenseAmount {
    return _expenses.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Average amount per expense
  double get averageExpenseAmount {
    if (_expenses.isEmpty) return 0.0;
    return totalExpenseAmount / _expenses.length;
  }

  /// Map of totals per category for summary analytics
  Map<ExpenseCategory, double> get categoryTotals {
    final map = <ExpenseCategory, double>{};
    for (final category in ExpenseCategory.values) {
      map[category] = 0.0;
    }
    for (final expense in _expenses) {
      map[expense.category] = (map[expense.category] ?? 0.0) + expense.amount;
    }
    return map;
  }

  /// Fetch all expenses with loading and error state handling
  Future<void> loadExpenses({bool simulateError = false}) async {
    _status = ExpenseListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Small delay for clean UI transition and realistic async feel
      await Future.delayed(const Duration(milliseconds: 350));

      if (simulateError) {
        throw Exception('Failed to load expenses from storage. Please try again.');
      }

      _expenses = await _storageService.loadExpenses();
      _status = ExpenseListStatus.loaded;
    } catch (e) {
      _status = ExpenseListStatus.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
    } finally {
      notifyListeners();
    }
  }

  /// Adds a new expense and saves to local storage
  Future<bool> addExpense(Expense expense) async {
    _expenses.add(expense);
    notifyListeners();
    final success = await _storageService.saveExpenses(_expenses);
    if (!success) {
      _errorMessage = 'Could not save expense locally.';
      notifyListeners();
    }
    return success;
  }

  /// Updates an existing expense and persists changes
  Future<bool> updateExpense(Expense updatedExpense) async {
    final index = _expenses.indexWhere((e) => e.id == updatedExpense.id);
    if (index == -1) return false;

    _expenses[index] = updatedExpense;
    notifyListeners();
    return await _storageService.saveExpenses(_expenses);
  }

  /// Deletes an expense by its ID and returns the removed item (for undo)
  Future<Expense?> deleteExpense(String id) async {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index == -1) return null;

    final removed = _expenses.removeAt(index);
    notifyListeners();
    await _storageService.saveExpenses(_expenses);
    return removed;
  }

  /// Re-inserts a previously removed expense (used for Undo action)
  Future<void> restoreExpense(Expense expense) async {
    _expenses.add(expense);
    notifyListeners();
    await _storageService.saveExpenses(_expenses);
  }

  /// Finds an individual expense by its unique identifier
  Expense? getExpenseById(String id) {
    try {
      return _expenses.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Updates the active category filter
  void setCategoryFilter(ExpenseCategory? category) {
    _selectedFilterCategory = category;
    notifyListeners();
  }

  /// Updates search keyword query
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
