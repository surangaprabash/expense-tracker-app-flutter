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

  // History list — scoped to the selected month, plus category/date filter and search.
  List<Expense> get filtered {
    final query = searchQuery.trim().toLowerCase();
    var list = _expenses.where((e) {
      final matchesMonth =
          e.date.year == selectedMonth.year && e.date.month == selectedMonth.month;
      final matchesCategory =
          filterCategoryId == null || e.categoryId == filterCategoryId;
      final matchesDate = filterDate == null ||
          (e.date.year == filterDate!.year &&
              e.date.month == filterDate!.month &&
              e.date.day == filterDate!.day);
      final matchesSearch = query.isEmpty ||
          e.title.toLowerCase().contains(query) ||
          (e.note?.toLowerCase().contains(query) ?? false);
      return matchesMonth && matchesCategory && matchesDate && matchesSearch;
    }).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double get selectedMonthTotal {
    return _expenses
        .where((e) =>
            e.date.year == selectedMonth.year && e.date.month == selectedMonth.month)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  Map<String, double> get categoryTotalsForSelectedMonth {
    final map = <String, double>{};
    for (final e in _expenses) {
      if (e.date.year == selectedMonth.year && e.date.month == selectedMonth.month) {
        map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
      }
    }
    return map;
  }

  bool get isViewingCurrentMonth {
    final now = DateTime.now();
    return selectedMonth.year == now.year && selectedMonth.month == now.month;
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

  // Explicit jump from the year/month picker — clamped so you can't pick a future month.
  void setMonth(int year, int month) {
    final now = DateTime.now();
    var target = DateTime(year, month);
    final current = DateTime(now.year, now.month);
    if (target.isAfter(current)) target = current;
    selectedMonth = target;
    notifyListeners();
  }

  void resetToCurrentMonth() {
    final now = DateTime.now();
    selectedMonth = DateTime(now.year, now.month);
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