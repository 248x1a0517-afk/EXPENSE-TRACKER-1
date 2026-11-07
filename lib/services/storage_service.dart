import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';

/// Service responsible for persisting and retrieving expenses on local device storage.
class StorageService {
  static const String _storageKey = 'stored_user_expenses_v1';
  SharedPreferences? _prefs;

  /// Initializes SharedPreferences instance
  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  /// Loads all stored expenses, returning an empty list if none exist or on parse error
  Future<List<Expense>> loadExpenses() async {
    try {
      if (_prefs == null) {
        await init();
      }
      final rawData = _prefs?.getString(_storageKey);
      if (rawData == null || rawData.isEmpty) {
        return [];
      }

      final List<dynamic> decodedList = jsonDecode(rawData) as List<dynamic>;
      return decodedList
          .map((item) => Expense.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list on corrupted storage and let provider handle or surface error
      return [];
    }
  }

  /// Saves the complete list of expenses to local storage
  Future<bool> saveExpenses(List<Expense> expenses) async {
    try {
      if (_prefs == null) {
        await init();
      }
      final jsonList = expenses.map((e) => e.toJson()).toList();
      final rawString = jsonEncode(jsonList);
      return await _prefs?.setString(_storageKey, rawString) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Clears all stored expense records from the device
  Future<bool> clearAll() async {
    if (_prefs == null) {
      await init();
    }
    return await _prefs?.remove(_storageKey) ?? false;
  }
}
