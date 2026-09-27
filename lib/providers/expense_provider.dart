import 'dart:async';
import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../services/firestore_service.dart';

class ExpenseProvider extends ChangeNotifier {
  final FirestoreService _firestoreService;
  StreamSubscription<List<Expense>>? _subscription;

  List<Expense> _expenses = [];

  bool isLoading = true;
  String? errorMessage;

  String? filterCategoryId;
  DateTime? filterDate;
  String searchQuery = '';

  DateTime selectedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  ExpenseProvider({FirestoreService? firestoreService})
      : _firestoreService = firestoreService ?? FirestoreService() {
    _listen();
  }

  void _listen() {
    isLoading = true;
    _subscription = _firestoreService.streamExpenses().listen(
      (expenses) {
        _expenses = expenses;
        isLoading = false;
        errorMessage = null;
        notifyListeners();
      },
      onError: (_) {
        isLoading = false;
        errorMessage = 'Failed to load expenses. Check your internet connection.';
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  List<Expense> get all => List.unmodifiable(_expenses);

  List<Expense> get expensesForSelectedMonth => _expenses
      .where((e) => e.date.year == selectedMonth.year && e.date.month == selectedMonth.month)
      .toList();

  List<Expense> get filtered {
    final query = searchQuery.trim().toLowerCase();
    var list = expensesForSelectedMonth.where((e) {
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

  double get selectedMonthTotal =>
      expensesForSelectedMonth.fold(0.0, (sum, e) => sum + e.amount);

  Map<String, double> get categoryTotalsForSelectedMonth {
    final map = <String, double>{};
    for (final e in expensesForSelectedMonth) {
      map[e.categoryId] = (map[e.categoryId] ?? 0) + e.amount;
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

  Future<void> addExpense(Expense expense) => _firestoreService.addExpense(expense);
  Future<void> updateExpense(Expense expense) => _firestoreService.updateExpense(expense);
  Future<void> deleteExpense(String id) => _firestoreService.deleteExpense(id);

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