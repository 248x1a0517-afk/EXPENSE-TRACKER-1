# Flutter Expense Tracker

A clean, production-grade Flutter application built with Flutter 3.35+, Dart null-safety, Provider state management, and Material Design 3.

## Architectural Structure
```
lib/
├── main.dart
├── models/
│   ├── expense.dart
│   └── expense_category.dart
├── services/
│   ├── storage_service.dart
│   └── expense_provider.dart
├── screens/
│   ├── expense_list_screen.dart
│   ├── expense_form_screen.dart
│   ├── expense_detail_screen.dart
│   └── expense_summary_screen.dart
└── widgets/
    ├── category_chip.dart
    ├── empty_state_view.dart
    ├── error_state_view.dart
    ├── expense_card.dart
    └── summary_chart_card.dart
test/
└── widget_test.dart
```

## Key Features
1. **Four Core Connected Screens**:
   - **Expense List**: Search, category filters, top aggregate banner, pull-to-refresh, dismiss-to-delete with Undo snackbar.
   - **Expense Form**: Complete input validation with inline errors (positive numeric amount, category selector, date picker, notes).
   - **Expense Detail**: Full metadata overview, hero card, edit and delete dialogs.
   - **Summary & Analytics**: Financial metrics and category progress breakdown.
2. **Four List States**: Loading spinner, Error with Retry, Empty state with illustration and CTA, and Populated list view.
3. **Provider State Management**: Centralized `ExpenseProvider` extending `ChangeNotifier`.
4. **Local Data Persistence**: `StorageService` backed by `shared_preferences` preserving records across app restarts.
5. **Material 3 Theming**: Single seed color (`ColorScheme.fromSeed`) generating light and dark themes consistently without hardcoded colors.

## Getting Started
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run automated tests
flutter test

# 3. Launch application
flutter run
```
