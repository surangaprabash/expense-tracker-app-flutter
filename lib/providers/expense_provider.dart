import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpenseProvider extends ChangeNotifier {
  final List<Expense> _expenses = [];

  bool isLoading = false;
  String? errorMessage;

  String? filterCategoryId;
  DateTime? filterDate;

  List<Expense> get all => List.unmodifiable(_expenses);

  List<Expense> get filtered {
    var list = _expenses.where((e) {
      final matchesCategory =
          filterCategoryId == null || e.categoryId == filterCategoryId;
      final matchesDate = filterDate == null ||
          (e.date.year == filterDate!.year &&
              e.date.month == filterDate!.month &&
              e.date.day == filterDate!.day);
      return matchesCategory && matchesDate;
    }).toList();
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  double get currentMonthTotal {
    final now = DateTime.now();
    return _expenses
        .where((e) => e.date.year == now.year && e.date.month == now.month)
        .fold(0.0, (sum, e) => sum + e.amount);
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

  void clearFilters() {
    filterCategoryId = null;
    filterDate = null;
    notifyListeners();
  }
}