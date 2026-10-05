import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/expense.dart';
import '../local/database_helper.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseHelper _localDb = DatabaseHelper.instance;

  // Push an expense to SQLite first, then to the logged-in user's Firestore subcollection
  Future<void> addExpense(Expense expense) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Save locally to SQLite
    await _localDb.insertOrUpdateExpense(user.uid, expense);

    // 2. Save remotely to Firebase
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

  // Update an existing expense in SQLite and Firestore
  Future<void> updateExpense(Expense expense) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Update locally in SQLite
    await _localDb.insertOrUpdateExpense(user.uid, expense);

    // 2. Update remotely in Firebase
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .doc(expense.id)
        .update({
      'amount': expense.amount,
      'category': expense.category.name,
      'note': expense.note,
      'date': expense.date.toIso8601String(),
    });
  }

  // Delete an expense from SQLite and Firestore
  Future<void> deleteExpense(String expenseId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Delete locally from SQLite
    await _localDb.deleteExpense(expenseId);

    // 2. Delete remotely from Firebase
    await _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .doc(expenseId)
        .delete();
  }

  // Retrieve expenses: Emits cached SQLite data immediately, then listens to Firestore & updates SQLite cache
  Stream<List<Expense>> getExpenses() async* {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Emit local SQLite cache immediately (works offline!)
    final cachedExpenses = await _localDb.getExpenses(user.uid);
    if (cachedExpenses.isNotEmpty) {
      yield cachedExpenses;
    }

    // 2. Listen to live Firestore updates and sync them to SQLite
    yield* _db
        .collection('users')
        .doc(user.uid)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final cloudExpenses = snapshot.docs.map((doc) {
        final data = doc.data();
        return Expense(
          id: doc.id,
          amount: data['amount'] is int
              ? (data['amount'] as int).toDouble()
              : (data['amount'] as num).toDouble(),
          category: ExpenseCategory.values.byName(data['category']),
          note: data['note'] ?? '',
          date: DateTime.parse(data['date']),
        );
      }).toList();

      // Cache fresh Firestore data into SQLite
      await _localDb.syncExpensesFromCloud(user.uid, cloudExpenses);
      return cloudExpenses;
    });
  }

  // Save budget limit to SQLite and Firestore
  Future<void> setBudgetLimit(ExpenseCategory category, double limit) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _localDb.setBudgetLimit(user.uid, category, limit);

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .doc(category.name)
        .set({'limit': limit});
  }

  // Delete budget limit from SQLite and Firestore
  Future<void> deleteBudgetLimit(ExpenseCategory category) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _localDb.deleteBudgetLimit(user.uid, category);

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .doc(category.name)
        .delete();
  }

  // Retrieve budget limits: Emits SQLite cache first, then streams Firestore
  Stream<Map<ExpenseCategory, double>> getBudgetLimits() async* {
    final user = _auth.currentUser;
    if (user == null) return;

    // 1. Emit cached budgets from SQLite
    final cachedBudgets = await _localDb.getBudgetLimits(user.uid);
    if (cachedBudgets.isNotEmpty) {
      yield cachedBudgets;
    }

    // 2. Stream from Firestore and update SQLite
    yield* _db
        .collection('users')
        .doc(user.uid)
        .collection('budgets')
        .snapshots()
        .asyncMap((snapshot) async {
      final Map<ExpenseCategory, double> limits = {};
      for (var doc in snapshot.docs) {
        try {
          final category = ExpenseCategory.values.byName(doc.id);
          final limit = doc.data()['limit'];
          final parsedLimit =
              limit is int ? limit.toDouble() : (limit as num).toDouble();
          limits[category] = parsedLimit;
          await _localDb.setBudgetLimit(user.uid, category, parsedLimit);
        } catch (e) {
          // Ignore any deprecated/invalid categories safely
        }
      }
      return limits;
    });
  }
}