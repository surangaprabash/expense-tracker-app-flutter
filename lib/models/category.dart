import 'package:flutter/material.dart';

class ExpenseCategory {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final bool isDefault;
  bool isEnabled;

  ExpenseCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.isDefault = false,
    this.isEnabled = true,
  });
}