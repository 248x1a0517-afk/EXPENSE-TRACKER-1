import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expense_tracker/models/expense.dart';
import 'package:expense_tracker/models/expense_category.dart';
import 'package:expense_tracker/services/storage_service.dart';
import 'package:expense_tracker/services/expense_provider.dart';
import 'package:expense_tracker/screens/expense_list_screen.dart';
import 'package:expense_tracker/widgets/empty_state_view.dart';
import 'package:expense_tracker/widgets/error_state_view.dart';

void main() {
  group('Expense Model Unit Tests', () {
    test('Expense model serialization and deserialization', () {
      final now = DateTime(2026, 11, 7, 12, 0);
      final expense = Expense(
        id: 'test-123',
        title: 'Team Lunch',
        amount: 45.50,
        category: ExpenseCategory.foodAndDining,
        date: now,
        note: 'Mexican burritos',
        createdAt: now,
      );

      final json = expense.toJson();
      expect(json['id'], 'test-123');
      expect(json['amount'], 45.50);
      expect(json['category'], 'foodAndDining');

      final reconstructed = Expense.fromJson(json);
      expect(reconstructed.id, expense.id);
      expect(reconstructed.title, expense.title);
      expect(reconstructed.amount, expense.amount);
      expect(reconstructed.category, expense.category);
      expect(reconstructed.formattedAmount, contains('45.50'));
    });
  });

  group('Expense List Screen Widget Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Displays EmptyStateView when no expenses exist in storage',
        (WidgetTester tester) async {
      final storage = StorageService();
      await storage.init();
      final provider = ExpenseProvider(storageService: storage);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExpenseProvider>.value(
            value: provider,
            child: const ExpenseListScreen(),
          ),
        ),
      );

      // Trigger initial load
      await provider.loadExpenses();
      await tester.pumpAndSettle();

      // Verify EmptyStateView is rendered
      expect(find.byType(EmptyStateView), findsOneWidget);
      expect(find.text('No Expenses Recorded'), findsOneWidget);
      expect(find.text('Add Expense'), findsWidgets);
    });

    testWidgets('Displays ErrorStateView with retry button on failure',
        (WidgetTester tester) async {
      final storage = StorageService();
      await storage.init();
      final provider = ExpenseProvider(storageService: storage);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExpenseProvider>.value(
            value: provider,
            child: const ExpenseListScreen(),
          ),
        ),
      );

      // Force simulated error
      await provider.loadExpenses(simulateError: true);
      await tester.pumpAndSettle();

      // Verify ErrorStateView appears
      expect(find.byType(ErrorStateView), findsOneWidget);
      expect(find.text('Failed to Load Expenses'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('Populated state displays expense cards and total amount',
        (WidgetTester tester) async {
      final storage = StorageService();
      await storage.init();
      final provider = ExpenseProvider(storageService: storage);

      await provider.addExpense(
        Expense(
          id: 'exp-1',
          title: 'Train Ticket',
          amount: 15.00,
          category: ExpenseCategory.transportation,
          date: DateTime.now(),
          note: 'Metro commute',
          createdAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<ExpenseProvider>.value(
            value: provider,
            child: const ExpenseListScreen(),
          ),
        ),
      );

      await provider.loadExpenses();
      await tester.pumpAndSettle();

      // Verify populated view
      expect(find.text('Train Ticket'), findsOneWidget);
      expect(find.text('Total Spent'), findsOneWidget);
      expect(find.text(r'$15.00'), findsWidgets);
    });
  });
}
