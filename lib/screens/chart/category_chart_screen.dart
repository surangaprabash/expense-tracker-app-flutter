import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/expense.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/empty_state.dart';

class CategoryChartScreen extends StatelessWidget {
  const CategoryChartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final totals = expenseProvider.categoryTotalsForSelectedMonth;
    final monthExpenses = expenseProvider.expensesForSelectedMonth;
    final grandTotal = totals.values.fold(0.0, (a, b) => a + b);
    final monthLabel = DateFormat('MMMM yyyy').format(expenseProvider.selectedMonth);

    Expense? snapshotFor(String categoryId) {
      for (final e in monthExpenses) {
        if (e.categoryId == categoryId) return e;
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Category Breakdown')),
      body: SafeArea(
        child: totals.isEmpty
            ? EmptyState(
                message: 'No expenses in $monthLabel yet.',
                icon: Icons.pie_chart_outline,
              )
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(monthLabel, style: Theme.of(context).textTheme.titleMedium),
                  ),
                  AspectRatio(
                    aspectRatio: 1.3,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: totals.entries.map((entry) {
                          final category = categoryProvider.byId(entry.key);
                          final fallback = snapshotFor(entry.key);
                          final color = category?.color ??
                              (fallback?.categoryColorValue != null
                                  ? Color(fallback!.categoryColorValue!)
                                  : Colors.grey);
                          final percent = grandTotal == 0 ? 0 : (entry.value / grandTotal) * 100;
                          return PieChartSectionData(
                            color: color,
                            value: entry.value,
                            title: '${percent.toStringAsFixed(0)}%',
                            radius: 60,
                            titleStyle: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: ListView(
                      children: totals.entries.map((entry) {
                        final category = categoryProvider.byId(entry.key);
                        final fallback = snapshotFor(entry.key);
                        final name = category?.name ?? fallback?.categoryName ?? 'Uncategorized';
                        final color = category?.color ??
                            (fallback?.categoryColorValue != null
                                ? Color(fallback!.categoryColorValue!)
                                : Colors.grey);
                        final icon = category?.icon ??
                            (fallback?.categoryIconCodePoint != null
                                ? IconData(fallback!.categoryIconCodePoint!, fontFamily: 'MaterialIcons')
                                : Icons.category);
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: color.withOpacity(0.15),
                            child: Icon(icon, color: color),
                          ),
                          title: Text(name),
                          trailing: Text('LKR ${entry.value.toStringAsFixed(2)}'),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}