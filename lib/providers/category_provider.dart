import 'package:flutter/material.dart';
import '../models/category.dart';
import '../utils/constants.dart';

class CategoryProvider extends ChangeNotifier {
  final List<ExpenseCategory> _categories = [];
  int _customCounter = 0;

  CategoryProvider() {
    for (var i = 0; i < kDefaultCategories.length; i++) {
      final c = kDefaultCategories[i];
      _categories.add(ExpenseCategory(
        id: 'default_$i',
        name: c['name'] as String,
        icon: c['icon'] as IconData,
        color: c['color'] as Color,
        isDefault: true,
      ));
    }
  }

  List<ExpenseCategory> get all => List.unmodifiable(_categories);

  // Only enabled ones are offered when picking a category for an expense.
  List<ExpenseCategory> get active =>
      _categories.where((c) => c.isEnabled).toList();

  ExpenseCategory? byId(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  void addCustom(String name, IconData icon, Color color) {
    _customCounter++;
    _categories.add(ExpenseCategory(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}_$_customCounter',
      name: name,
      icon: icon,
      color: color,
      isDefault: false,
    ));
    notifyListeners();
  }

  void toggleEnabled(String id) {
    final c = byId(id);
    if (c != null) {
      c.isEnabled = !c.isEnabled;
      notifyListeners();
    }
  }

  // Custom categories can be fully removed; defaults can only be disabled.
  void removeCustom(String id) {
    _categories.removeWhere((c) => c.id == id && !c.isDefault);
    notifyListeners();
  }
}