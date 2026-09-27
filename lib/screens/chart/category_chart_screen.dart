import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
    final grandTotal = totals.values.fold(0.0, (a, b) => a + b);
    final monthLabel = DateFormat('MMMM yyyy').format(expenseProvider.selectedMonth);

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
                          final percent = grandTotal == 0 ? 0 : (entry.value / grandTotal) * 100;
                          return PieChartSectionData(
                            color: category?.color ?? Colors.grey,
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
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: (category?.color ?? Colors.grey).withOpacity(0.15),
                            child: Icon(category?.icon ?? Icons.category,
                                color: category?.color ?? Colors.grey),
                          ),
                          title: Text(category?.name ?? 'Deleted category'),
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