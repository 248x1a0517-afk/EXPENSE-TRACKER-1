import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/expense_provider.dart';
import '../widgets/summary_chart_card.dart';

/// Screen presenting aggregate financial totals and per-category spending breakdowns.
class ExpenseSummaryScreen extends StatelessWidget {
  const ExpenseSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<ExpenseProvider>();
    final currencyFormatter = NumberFormat.simpleCurrency(decimalDigits: 2);

    final totalSpent = provider.totalExpenseAmount;
    final avgExpense = provider.averageExpenseAmount;
    final count = provider.allExpenses.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Summary & Analytics'),
      ),
      body: provider.allExpenses.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.insert_chart_outlined,
                    size: 64,
                    color: colorScheme.outline,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Data Available',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add expenses first to view aggregate summaries.',
                    style: TextStyle(color: colorScheme.outline),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Top Aggregate Stat Cards
                Row(
                  children: [
                    Expanded(
                      child: _SummaryMetricTile(
                        icon: Icons.payments_outlined,
                        title: 'Total Spent',
                        value: currencyFormatter.format(totalSpent),
                        accentColor: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryMetricTile(
                        icon: Icons.calculate_outlined,
                        title: 'Average / Item',
                        value: currencyFormatter.format(avgExpense),
                        accentColor: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _SummaryMetricTile(
                        icon: Icons.receipt_long,
                        title: 'Transactions',
                        value: '$count items',
                        accentColor: colorScheme.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Category Breakdown Chart Card
                SummaryChartCard(
                  categoryTotals: provider.categoryTotals,
                  totalAmount: totalSpent,
                ),
              ],
            ),
    );
  }
}

class _SummaryMetricTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;

  const _SummaryMetricTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      color: colorScheme.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: accentColor, size: 24),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
