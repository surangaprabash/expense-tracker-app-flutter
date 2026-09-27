import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/expense.dart';

class FirestoreService {
  final CollectionReference<Map<String, dynamic>> _expensesRef =
      FirebaseFirestore.instance.collection('expenses');

  Stream<List<Expense>> streamExpenses() {
    return _expensesRef.orderBy('date', descending: true).snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Expense.fromMap(doc.id, doc.data())).toList(),
        );
  }

  Future<void> addExpense(Expense expense) {
    return _expensesRef.add(expense.toMap());
  }

  Future<void> updateExpense(Expense expense) {
    return _expensesRef.doc(expense.id).update(expense.toMap());
  }

  Future<void> deleteExpense(String id) {
    return _expensesRef.doc(id).delete();
  }
}