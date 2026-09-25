import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Push an expense to the logged-in user's private subcollection
  Future<void> addExpense(Expense expense) async {
    final user = _auth.currentUser;
    
    // Safety check: Do nothing if no user is logged in
    if (user == null) return; 

    // Target the specific path: users -> {uid} -> expenses
    final userExpensesRef = _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses');

    await userExpensesRef.doc(expense.id).set({
      'amount': expense.amount,
      'category': expense.category.name,
      'note': expense.note,
      'date': expense.date.toIso8601String(),
    });
  }

  Future<void> deleteExpense(String expenseId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  // Retrieve expenses as a live stream for the specific user
  Stream<List<Expense>> getExpenses() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Expense(
          id: doc.id,
          amount: data['amount'] is int ? (data['amount'] as int).toDouble() : data['amount'],
          category: ExpenseCategory.values.byName(data['category']),
          note: data['note'] ?? '',
          date: DateTime.parse(data['date']),
        );
      }).toList();
    });
  }


  Future<void> setBudgetLimit(ExpenseCategory category, double limit) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .doc(category.name) 
        .set({'limit': limit});
  }

  Future<void> deleteBudgetLimit(ExpenseCategory category) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .doc(category.name)
        .delete();
  }

  // Retrieve budget limits as a live stream
  Stream<Map<ExpenseCategory, double>> getBudgetLimits() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .snapshots()
        .map((snapshot) {
      final Map<ExpenseCategory, double> limits = {};
      for (var doc in snapshot.docs) {
        try {
          final category = ExpenseCategory.values.byName(doc.id);
          final limit = doc.data()['limit'];
          limits[category] = limit is int ? limit.toDouble() : (limit as double);
        } catch (e) {
          // Ignore any deprecated/invalid categories safely
        }
      }
      return limits;
    });
  }
}

  




