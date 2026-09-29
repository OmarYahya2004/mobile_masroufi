import 'package:flutter/material.dart';
import '../data/remote/firebase_service.dart';
import '../data/models/expense.dart';
import '../widgets/set_budget_modal.dart';
import '../core/constants/colors.dart'; // Import your colors file

class GoalsPage extends StatefulWidget {
  const GoalsPage({super.key});

  @override
  State<GoalsPage> createState() => _GoalsPageState();
}

class _GoalsPageState extends State<GoalsPage> {
  final FirebaseService _firebaseService = FirebaseService();
  final String appFont = 'Poppins'; // Custom font consistency

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

  void _openSetBudgetModal(Color surfaceColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
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

  Future<void> _confirmAndDeleteBudget(BuildContext context, ExpenseCategory category, Color surfaceColor, Color textColor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        title: Text('Delete Budget Limit', style: TextStyle(color: textColor, fontFamily: appFont, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete the budget limit for ${category.name}?', style: TextStyle(color: textColor.withValues(alpha: 0.8), fontFamily: appFont)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: TextStyle(color: AppColors.primaryTeal, fontFamily: appFont)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.errorRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete', style: TextStyle(color: Colors.white, fontFamily: appFont)),
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
    // Theme setup
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: StreamBuilder<List<Expense>>(
          stream: _firebaseService.getExpenses(),
          builder: (context, expensesSnapshot) {
            
            return StreamBuilder<Map<ExpenseCategory, double>>(
              stream: _firebaseService.getBudgetLimits(),
              builder: (context, limitsSnapshot) {
                
                // Show a loading indicator while either stream is initializing
                if (expensesSnapshot.connectionState == ConnectionState.waiting || 
                    limitsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal));
                }

                final allExpenses = expensesSnapshot.data ?? [];
                // Load budget limits from Firebase snapshot
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
                    Text('Goals', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontFamily: appFont)),
                    const SizedBox(height: 4),
                    Text('Monthly budget limits', style: TextStyle(color: textSecondary, fontSize: 14, fontFamily: appFont)),
                    const SizedBox(height: 32),

                    // Check if user has no goals set yet
                    if (firebaseBudgetLimits.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Text('No budget limits set yet.', style: TextStyle(color: textSecondary, fontFamily: appFont)),
                      ),

                    // Map over the Firebase budget limits
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
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${_getCategoryIcon(category)} ${category.name}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textColor, fontFamily: appFont)),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Conditionally show the red exclamation mark
                                    if (spent > limit)
                                      const Padding(
                                        padding: EdgeInsets.only(right: 8.0),
                                        child: CircleAvatar(
                                          backgroundColor: AppColors.errorRed,
                                          radius: 10,
                                          child: Icon(Icons.priority_high, color: Colors.white, size: 14, weight: 900),
                                        ),
                                      ),
                                    
                                    // Optionally make the percentage text red if over budget
                                    Text(
                                      '$percentageText%', 
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 16, 
                                        fontFamily: appFont,
                                        color: spent > limit ? AppColors.errorRed : textColor,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                      icon: Icon(Icons.close, color: textSecondary.withValues(alpha: 0.5)),
                                      onPressed: () => _confirmAndDeleteBudget(context, category, surfaceColor, textColor),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text('${spent.toStringAsFixed(0)} EGP of ${limit.toStringAsFixed(0)} EGP', style: TextStyle(color: textSecondary, fontSize: 14, fontFamily: appFont)),
                            const SizedBox(height: 16),
                            LinearProgressIndicator(
                              value: percentage,
                              minHeight: 12,
                              backgroundColor: textColor.withValues(alpha: 0.1),
                              color: _getCategoryColor(category),
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 8),

                    OutlinedButton(
                      onPressed: () => _openSetBudgetModal(surfaceColor),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        side: BorderSide(color: textColor.withValues(alpha: 0.2), width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text('+ Set a budget limit', style: TextStyle(color: textSecondary, fontSize: 16, fontFamily: appFont, fontWeight: FontWeight.w600)),
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