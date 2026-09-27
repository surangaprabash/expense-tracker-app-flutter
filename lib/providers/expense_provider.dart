import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<Expense> _expenses = [];

  bool isLoading = false;
  String? errorMessage;

  String? filterCategoryId;
  DateTime? filterDate;
  String searchQuery = '';

  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  List<Expense> get all => List.unmodifiable(_expenses);

  // Full history list — respects category/date filter and search, but NOT
  // the selected month (that only scopes the summary card and the chart).
  List<Expense> get filtered {
    final query = searchQuery.trim().toLowerCase();
    var list = _expenses.where((e) {
      final matchesCategory =
          filterCategoryId == null || e.categoryId == filterCategoryId;
      final matchesDate = filterDate == null ||
          (e.date.year == filterDate!.year &&
              e.date.month == filterDate!.month &&
              e.date.day == filterDate!.day);
      final matchesSearch = query.isEmpty ||
          e.title.toLowerCase().contains(query) ||
          (e.note?.toLowerCase().contains(query) ?? false);
      return matchesCategory && matchesDate && matchesSearch;
    }).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double get selectedMonthTotal {
    return _expenses
        .where((e) =>
            e.date.year == selectedMonth.year &&
            e.date.month == selectedMonth.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  // categoryId -> total amount, for whichever month is selected. Used by the chart.
  Map<String, double> get categoryTotalsForSelectedMonth {
    final map = <String, double>{};
    for (final e in _expenses) {
      if (e.date.year == selectedMonth.year && e.date.month == selectedMonth.month) {
        map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
      }
    }
    return map;
  }

  bool get canGoToNextMonth {
    final now = DateTime.now();
    final current = DateTime(now.year, now.month);
    return selectedMonth.isBefore(current);
  }

  void goToPreviousMonth() {
    selectedMonth = DateTime(selectedMonth.year, selectedMonth.month - 1);
    notifyListeners();
  }

  void goToNextMonth() {
    if (!canGoToNextMonth) return;
    selectedMonth = DateTime(selectedMonth.year, selectedMonth.month + 1);
    notifyListeners();
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void updateExpense(Expense updated) {
    final index = _expenses.indexWhere((e) => e.id == updated.id);
    if (index != -1) {
      _expenses[index] = updated;
      notifyListeners();
    }
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void setCategoryFilter(String? categoryId) {
    filterCategoryId = categoryId;
    notifyListeners();
  }

  void setDateFilter(DateTime? date) {
    filterDate = date;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    searchQuery = query;
    notifyListeners();
  }

  void clearFilters() {
    filterCategoryId = null;
    filterDate = null;
    notifyListeners();
  }
}