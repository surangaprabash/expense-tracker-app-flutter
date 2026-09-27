import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../add_edit_expense/add_edit_expense_screen.dart';
import '../manage_categories/manage_categories_screen.dart';
import 'widgets/expense_list_item.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/month_summary_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final categoryProvider = context.watch<CategoryProvider>();

    final hasActiveFilters =
        expenseProvider.filterCategoryId != null || expenseProvider.filterDate != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        actions: [
          IconButton(
            tooltip: 'Manage categories',
            icon: const Icon(Icons.category_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()),
            ),
          ),
          IconButton(
            tooltip: 'Filter',
            icon: Icon(hasActiveFilters ? Icons.filter_alt : Icons.filter_alt_outlined),
            onPressed: () async {
              final result = await showModalBottomSheet<Map<String, dynamic>>(
                context: context,
                isScrollControlled: true,
                builder: (_) => FilterSheet(
                  categories: categoryProvider.active,
                  initialCategoryId: expenseProvider.filterCategoryId,
                  initialDate: expenseProvider.filterDate,
                ),
              );
              if (result != null) {
                if (result['clear'] == true) {
                  expenseProvider.clearFilters();
                } else {
                  expenseProvider.setCategoryFilter(result['category']);
                  expenseProvider.setDateFilter(result['date']);
                }
              }
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Builder(builder: (context) {
          if (expenseProvider.isLoading) return const LoadingView();
          if (expenseProvider.errorMessage != null) {
            return ErrorView(message: expenseProvider.errorMessage!);
          }
          final items = expenseProvider.filtered;
          return Column(
            children: [
              MonthSummaryCard(total: expenseProvider.currentMonthTotal),
              if (hasActiveFilters)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: expenseProvider.clearFilters,
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Clear filters'),
                    ),
                  ),
                ),
              Expanded(
                child: items.isEmpty
                    ? const EmptyState(
                        message: 'No expenses yet.\nTap + to add your first one.',
                        icon: Icons.receipt_long_outlined,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 80),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final expense = items[index];
                          return ExpenseListItem(
                            expense: expense,
                            category: categoryProvider.byId(expense.categoryId),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditExpenseScreen(expense: expense),
                              ),
                            ),
                            onDelete: () => expenseProvider.deleteExpense(expense.id),
                          );
                        },
                      ),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditExpenseScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}