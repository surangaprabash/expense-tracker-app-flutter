import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../../providers/expense_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loading_view.dart';
import '../add_edit_expense/add_edit_expense_screen.dart';
import '../chart/category_chart_screen.dart';
import '../manage_categories/manage_categories_screen.dart';
import 'widgets/expense_list_item.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/month_summary_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showSearch = false;
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch(ExpenseProvider expenseProvider) {
    setState(() => _showSearch = !_showSearch);
    if (!_showSearch) {
      _searchController.clear();
      expenseProvider.setSearchQuery('');
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = context.watch<ExpenseProvider>();
    final categoryProvider = context.watch<CategoryProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final hasActiveFilters =
        expenseProvider.filterCategoryId != null || expenseProvider.filterDate != null;

    return Scaffold(
      appBar: AppBar(
        title: _showSearch
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search title or note...',
                  border: InputBorder.none,
                ),
                onChanged: expenseProvider.setSearchQuery,
              )
            : const Text('Expense Tracker'),
        actions: [
          IconButton(
            icon: Icon(_showSearch ? Icons.close : Icons.search),
            onPressed: () => _toggleSearch(expenseProvider),
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
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'categories':
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()));
                  break;
                case 'chart':
                  Navigator.push(
                      context, MaterialPageRoute(builder: (_) => const CategoryChartScreen()));
                  break;
                case 'theme_system':
                  themeProvider.setThemeMode(ThemeMode.system);
                  break;
                case 'theme_light':
                  themeProvider.setThemeMode(ThemeMode.light);
                  break;
                case 'theme_dark':
                  themeProvider.setThemeMode(ThemeMode.dark);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'categories', child: Text('Manage categories')),
              const PopupMenuItem(value: 'chart', child: Text('Category chart')),
              const PopupMenuDivider(),
              CheckedPopupMenuItem(
                value: 'theme_system',
                checked: themeProvider.themeMode == ThemeMode.system,
                child: const Text('Theme: System'),
              ),
              CheckedPopupMenuItem(
                value: 'theme_light',
                checked: themeProvider.themeMode == ThemeMode.light,
                child: const Text('Theme: Light'),
              ),
              CheckedPopupMenuItem(
                value: 'theme_dark',
                checked: themeProvider.themeMode == ThemeMode.dark,
                child: const Text('Theme: Dark'),
              ),
            ],
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
              MonthSummaryCard(
                month: expenseProvider.selectedMonth,
                total: expenseProvider.selectedMonthTotal,
                onPreviousMonth: () => setState(expenseProvider.goToPreviousMonth),
                onNextMonth:
                    expenseProvider.canGoToNextMonth ? () => setState(expenseProvider.goToNextMonth) : null,
              ),
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
                    ? EmptyState(
                        message: expenseProvider.searchQuery.isNotEmpty
                            ? 'No expenses match "${expenseProvider.searchQuery}".'
                            : 'No expenses yet.\nTap + to add your first one.',
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