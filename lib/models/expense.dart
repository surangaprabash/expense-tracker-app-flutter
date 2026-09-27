import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String title;
  final double amount;
  final String categoryId;
  final DateTime date;
  final String? note;

  // Snapshot of the category at save time. Categories live only on-device,
  // not in Firestore, so this is what lets old expenses still show a
  // name/icon/color even if that category is later disabled or deleted.
  final String? categoryName;
  final int? categoryColorValue;
  final int? categoryIconCodePoint;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.categoryId,
    required this.date,
    this.note,
    this.categoryName,
    this.categoryColorValue,
    this.categoryIconCodePoint,
  });

  Expense copyWith({
    String? title,
    double? amount,
    String? categoryId,
    DateTime? date,
    String? note,
    String? categoryName,
    int? categoryColorValue,
    int? categoryIconCodePoint,
  }) {
    return Expense(
      id: id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      date: date ?? this.date,
      note: note ?? this.note,
      categoryName: categoryName ?? this.categoryName,
      categoryColorValue: categoryColorValue ?? this.categoryColorValue,
      categoryIconCodePoint: categoryIconCodePoint ?? this.categoryIconCodePoint,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'amount': amount,
      'categoryId': categoryId,
      'date': Timestamp.fromDate(date),
      'note': note,
      'categoryName': categoryName,
      'categoryColorValue': categoryColorValue,
      'categoryIconCodePoint': categoryIconCodePoint,
    };
  }

  factory Expense.fromMap(String id, Map<String, dynamic> map) {
    return Expense(
      id: id,
      title: map['title'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      categoryId: map['categoryId'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      note: map['note'] as String?,
      categoryName: map['categoryName'] as String?,
      categoryColorValue: map['categoryColorValue'] as int?,
      categoryIconCodePoint: map['categoryIconCodePoint'] as int?,
    );
  }
}