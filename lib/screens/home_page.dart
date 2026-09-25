import 'package:flutter/material.dart';
import '../data/models/expense.dart';
import '../widgets/add_expense_modal.dart';
import '../screens/profile_page.dart';
import '../data/remote/firebase_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // 1. Initialize your Firebase Service
  final FirebaseService _firebaseService = FirebaseService();

  // 2. Remove the mock _expenses list completely.

  void _openAddExpenseOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => AddExpenseModal(
        onAddExpense: (expense) async {
          // 3. Save the new expense to Firebase instead of a local list
          await _firebaseService.addExpense(expense);
          
          // Note: You no longer need setState() here because the StreamBuilder 
          // will automatically detect the new data in Firebase and update the UI.
        },
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, Expense expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Delete Expense', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text('Are you sure you want to delete this expense?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.onError)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _firebaseService.deleteExpense(expense.id);
    }
  }
  @override
  Widget build(BuildContext context) {
    final secondaryTextStyle = TextStyle(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Masroufi', 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 24, 
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
        actions: [
          // Profile Icon
          IconButton(
            icon: Icon(Icons.person_outline, color: Theme.of(context).colorScheme.onSurface),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _firebaseService.getExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading expenses', style: secondaryTextStyle));
          }

          final expenses = snapshot.data ?? [];
          final now = DateTime.now();

          // Calculate Totals
          double spentToday = 0;
          double spentThisWeek = 0;
          double spentThisMonth = 0;

          // Find the start of the current week (Assuming Monday is the start)
          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

          for (var exp in expenses) {
            // Today
            if (exp.date.year == now.year && exp.date.month == now.month && exp.date.day == now.day) {
              spentToday += exp.amount;
            }
            
            // This Month
            if (exp.date.year == now.year && exp.date.month == now.month) {
              spentThisMonth += exp.amount;
            }

            // This Week
            final expenseDateOnly = DateTime(exp.date.year, exp.date.month, exp.date.day);
            if (!expenseDateOnly.isBefore(startOfWeekDate) && expenseDateOnly.isBefore(now.add(const Duration(days: 1)))) {
              spentThisWeek += exp.amount;
            }
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spent this month', style: secondaryTextStyle),
                      const SizedBox(height: 8),
                      // Dynamic Monthly Total
                      Text('${spentThisMonth.toStringAsFixed(0)} EGP', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Today', style: secondaryTextStyle),
                              // Dynamic Daily Total
                              Text('${spentToday.toStringAsFixed(0)} EGP', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('This week', style: secondaryTextStyle),
                              // Dynamic Weekly Total
                              Text('${spentThisWeek.toStringAsFixed(0)} EGP', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _openAddExpenseOverlay,
                          child: const Text('+ Add expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Recent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 16),
                
                // Recent expenses list
                Expanded(
                  child: expenses.isEmpty
                      ? Center(child: Text('No recent expenses.', style: secondaryTextStyle))
                      : ListView.builder(
                          itemCount: expenses.length,
                          itemBuilder: (ctx, index) {
                            final exp = expenses[index];
                            return ListTile(
                              leading: Text(exp.categoryIcon, style: const TextStyle(fontSize: 24)),
                              title: Text(exp.categoryName, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
                              subtitle: Text(
                                '${exp.date.year}-${exp.date.month.toString().padLeft(2, '0')}-${exp.date.day.toString().padLeft(2, '0')}',
                                style: secondaryTextStyle,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('${exp.amount.toStringAsFixed(0)} EGP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).colorScheme.onSurface)),
                                  IconButton(
                                  icon: Icon(Icons.close, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4)),
                                  onPressed: () => _confirmAndDelete(context, exp),
                                ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}