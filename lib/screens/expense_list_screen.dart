import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../services/expense_provider.dart';
import '../widgets/expense_card.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_state_view.dart';
import 'expense_form_screen.dart';
import 'expense_detail_screen.dart';
import 'expense_summary_screen.dart';

/// Main screen displaying the list of all recorded expenses with search and filtering.
class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToForm(BuildContext context, {Expense? existingExpense}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseFormScreen(expenseToEdit: existingExpense),
      ),
    );
  }

  void _navigateToDetail(BuildContext context, String expenseId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ExpenseDetailScreen(expenseId: expenseId),
      ),
    );
  }

  void _navigateToSummary(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ExpenseSummaryScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<ExpenseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Expense Tracker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          // Quick navigation to Summary & Analytics
          IconButton(
            icon: const Icon(Icons.pie_chart_outline),
            tooltip: 'View Summary',
            onPressed: () => _navigateToSummary(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
      body: Builder(
        builder: (context) {
          // 1. Loading State
          if (provider.status == ExpenseListStatus.loading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading your expenses...'),
                ],
              ),
            );
          }

          // 2. Error State with Retry Button
          if (provider.status == ExpenseListStatus.error) {
            return ErrorStateView(
              errorMessage: provider.errorMessage ?? 'An unexpected error occurred.',
              onRetry: () => provider.loadExpenses(),
            );
          }

          // 3. Empty State (when completely no expenses exist in storage)
          if (provider.allExpenses.isEmpty) {
            return EmptyStateView(
              onAddPressed: () => _navigateToForm(context),
            );
          }

          // 4. Populated State
          final items = provider.filteredExpenses;

          return RefreshIndicator(
            onRefresh: () => provider.loadExpenses(),
            child: CustomScrollView(
              slivers: [
                // Top Summary Banner
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Spent',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimary.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${provider.totalExpenseAmount.toStringAsFixed(2)}',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                        FilledButton.tonal(
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.onPrimary,
                            foregroundColor: colorScheme.primary,
                          ),
                          onPressed: () => _navigateToSummary(context),
                          child: const Text('Analytics'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search expenses or notes...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  provider.setSearchQuery('');
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) => provider.setSearchQuery(value),
                    ),
                  ),
                ),

                // Category Filter Horizontal List
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 52,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('All'),
                            selected: provider.selectedFilterCategory == null,
                            onSelected: (_) => provider.setCategoryFilter(null),
                          ),
                        ),
                        ...ExpenseCategory.values.map(
                          (cat) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              avatar: Icon(cat.icon, size: 16),
                              label: Text(cat.displayName),
                              selected: provider.selectedFilterCategory == cat,
                              onSelected: (selected) {
                                provider.setCategoryFilter(selected ? cat : null);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // List Items or Search Empty
                if (items.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No expenses matching filter',
                            style: TextStyle(color: colorScheme.outline),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final expense = items[index];
                        return ExpenseCard(
                          expense: expense,
                          onTap: () => _navigateToDetail(context, expense.id),
                          onDelete: () async {
                            final deleted = await provider.deleteExpense(expense.id);
                            if (deleted != null && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Removed "${deleted.title}"'),
                                  action: SnackBarAction(
                                    label: 'Undo',
                                    onPressed: () {
                                      provider.restoreExpense(deleted);
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                      childCount: items.length,
                    ),
                  ),

                // Bottom padding to clear floating action button
                const SliverToBoxAdapter(
                  child: SizedBox(height: 80),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
