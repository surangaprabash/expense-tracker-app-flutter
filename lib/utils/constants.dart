import 'package:flutter/material.dart';

const String kAppName = 'Expense Tracker';

const List<Map<String, dynamic>> kDefaultCategories = [
  {'name': 'Food & Dining', 'icon': Icons.restaurant, 'color': Colors.orange},
  {'name': 'Transport', 'icon': Icons.directions_car, 'color': Colors.blue},
  {'name': 'Bills & Utilities', 'icon': Icons.receipt_long, 'color': Colors.purple},
  {'name': 'Shopping', 'icon': Icons.shopping_bag, 'color': Colors.pink},
  {'name': 'Entertainment', 'icon': Icons.movie, 'color': Colors.teal},
];

const List<IconData> kCategoryIconChoices = [
  Icons.category, Icons.fastfood, Icons.local_hospital, Icons.school,
  Icons.pets, Icons.flight, Icons.fitness_center, Icons.home,
  Icons.card_giftcard, Icons.sports_esports,
];

const List<Color> kCategoryColorChoices = [
  Colors.red, Colors.orange, Colors.amber, Colors.green, Colors.teal,
  Colors.blue, Colors.indigo, Colors.purple, Colors.pink, Colors.brown,
];