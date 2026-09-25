import 'package:flutter/material.dart';
import '../data/remote/firebase_service.dart';
import '../data/models/expense.dart';
import '../widgets/set_budget_modal.dart';

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final FirebaseService _firebaseService = FirebaseService();

  // 1. Removed the hardcoded _budgetLimits Map here

  String _getCategoryIcon(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food: return '🍔';
      case ExpenseCategory.transport: return '🚌';
      case ExpenseCategory.bills: return '🧾';
      case ExpenseCategory.shopping: return '🛍️';
      default: return '📦';
    }
  }

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food: return const Color(0xFFE5C158);
      case ExpenseCategory.transport: return const Color(0xFF6B8BCC);
      case ExpenseCategory.bills: return const Color(0xFFD9725B);
      case ExpenseCategory.shopping: return const Color(0xFF9E6BCC);
      default: return const Color(0xFF8BA3A0);
    }
  }

  void _openSetBudgetModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SetBudgetModal(
        onSave: (category, limit) async {
          await _firebaseService.setBudgetLimit(category, limit);
        },
      ),
    );
  }

  Future<void> _confirmAndDeleteBudget(BuildContext context, ExpenseCategory category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Text('Delete Budget Limit', style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
        content: Text('Are you sure you want to delete the budget limit for ${category.name}?', style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8))),
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
      await _firebaseService.deleteBudgetLimit(category);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final secondaryText = onSurface.withValues(alpha: 0.6);

    return Scaffold(
      body: SafeArea(
        // 3. Nest StreamBuilders to listen to both Expenses and Budgets
        child: StreamBuilder<List<Expense>>(
          stream: _firebaseService.getExpenses(),
          builder: (context, expensesSnapshot) {
            
            return StreamBuilder<Map<ExpenseCategory, double>>(
              stream: _firebaseService.getBudgetLimits(),
              builder: (context, limitsSnapshot) {
                
                // Show a loading indicator while either stream is initializing
                if (expensesSnapshot.connectionState == ConnectionState.waiting || 
                    limitsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allExpenses = expensesSnapshot.data ?? [];
                // 4. Load budget limits from Firebase snapshot
                final firebaseBudgetLimits = limitsSnapshot.data ?? {}; 
                final now = DateTime.now();
                
                final thisMonthExpenses = allExpenses.where((e) => 
                  e.date.year == now.year && e.date.month == now.month
                ).toList();

                final Map<ExpenseCategory, double> spentPerCategory = {};
                for (var e in thisMonthExpenses) {
                  spentPerCategory[e.category] = (spentPerCategory[e.category] ?? 0) + e.amount;
                }

                return ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    Text('Goals', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: onSurface)),
                    const SizedBox(height: 4),
                    Text('Monthly budget limits', style: TextStyle(color: secondaryText, fontSize: 14)),
                    const SizedBox(height: 32),

                    // 5. Check if user has no goals set yet
                    if (firebaseBudgetLimits.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text('No budget limits set yet.', style: TextStyle(color: secondaryText)),
                      ),

                    // 6. Map over the Firebase budget limits
                    ...firebaseBudgetLimits.entries.map((entry) {
                      final category = entry.key;
                      final limit = entry.value;
                      final spent = spentPerCategory[category] ?? 0.0;
                      
                      double percentage = (spent / limit);
                      if (percentage > 1.0) percentage = 1.0;
                      final percentageText = ((spent / limit) * 100).toStringAsFixed(0);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${_getCategoryIcon(category)} ${category.name}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: onSurface)),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // 1. Conditionally show the red exclamation mark
                                    if (spent > limit)
                                      const Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: CircleAvatar(
                                          backgroundColor: Colors.red,
                                          radius: 10,
                                          child: Icon(Icons.priority_high, color: Colors.white, size: 14, weight: 900),
                                        ),
                                      ),
                                    
                                    // 2. Optionally make the percentage text red if over budget
                                    Text(
                                      '$percentageText%', 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 16, 
                                        color: spent > limit ? Colors.red : onSurface,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: Icon(Icons.close, color: onSurface.withValues(alpha: 0.4)),
                                      onPressed: () => _confirmAndDeleteBudget(context, category),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${spent.toStringAsFixed(0)} EGP of ${limit.toStringAsFixed(0)} EGP', style: TextStyle(color: secondaryText, fontSize: 14)),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: percentage,
                              minHeight: 12,
                              backgroundColor: onSurface.withValues(alpha: 0.1),
                              color: _getCategoryColor(category),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    OutlinedButton(
                      onPressed: _openSetBudgetModal,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        side: BorderSide(color: onSurface.withValues(alpha: 0.2), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('+ Set a budget limit', style: TextStyle(color: secondaryText, fontSize: 16)),
                    ),
                  ],
                );
              }
            );
          },
        ),
      ),
    );
  }
}