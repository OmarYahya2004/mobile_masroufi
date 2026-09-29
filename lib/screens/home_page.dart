import 'package:flutter/material.dart';
import '../data/models/expense.dart';
import '../widgets/add_expense_modal.dart';
import '../screens/profile_page.dart';
import '../data/remote/firebase_service.dart';
import '../core/constants/colors.dart'; // Import your new colors file

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _firebaseService = FirebaseService();
  // Set your unique font here (ensure it is loaded in pubspec.yaml)
  final String appFont = 'Poppins'; 

  void _openAddExpenseOverlay(Color surfaceColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => AddExpenseModal(
        onAddExpense: (expense) async {
          await _firebaseService.addExpense(expense);
        },
      ),
    );
  }

  Future<void> _confirmAndDelete(BuildContext context, Expense expense, Color surfaceColor, Color textColor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        title: Text('Delete Expense', style: TextStyle(color: textColor, fontFamily: appFont, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this expense?', style: TextStyle(color: textColor.withValues(alpha: 0.8), fontFamily: appFont)),
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
      await _firebaseService.deleteExpense(expense.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the device is in dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Assign colors based on mode directly from your file
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final secondaryTextStyle = TextStyle(
      color: textSecondary,
      fontFamily: appFont,
    );

    return Scaffold(
      backgroundColor: bgColor,
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
                fontSize: 26, 
                color: AppColors.primaryBlue, // Use logo's deep blue for the brand name
                fontFamily: appFont,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person_outline, color: textColor),
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
            return Center(child: CircularProgressIndicator(color: AppColors.primaryTeal));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading expenses', style: secondaryTextStyle));
          }

          final expenses = snapshot.data ?? [];
          final now = DateTime.now();

          double spentToday = 0;
          double spentThisWeek = 0;
          double spentThisMonth = 0;

          final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
          final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);

          for (var exp in expenses) {
            if (exp.date.year == now.year && exp.date.month == now.month && exp.date.day == now.day) {
              spentToday += exp.amount;
            }
            if (exp.date.year == now.year && exp.date.month == now.month) {
              spentThisMonth += exp.amount;
            }
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
                    // Use a gradient based on the logo colors for the main card
                    gradient: const LinearGradient(
                      colors: [AppColors.primaryBlue, AppColors.primaryTeal],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryBlue.withValues(alpha: 0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      )
                    ]
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spent this month', style: TextStyle(color: Colors.white70, fontFamily: appFont)),
                      const SizedBox(height: 8),
                      Text('${spentThisMonth.toStringAsFixed(0)} EGP', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: appFont)),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Today', style: TextStyle(color: Colors.white70, fontFamily: appFont)),
                              Text('${spentToday.toStringAsFixed(0)} EGP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: appFont)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('This week', style: TextStyle(color: Colors.white70, fontFamily: appFont)),
                              Text('${spentThisWeek.toStringAsFixed(0)} EGP', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: appFont)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentCyan, // Bright color from arrow logo
                            foregroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _openAddExpenseOverlay(surfaceColor),
                          child: Text('+ Add expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: appFont)),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('Recent', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor, fontFamily: appFont)),
                const SizedBox(height: 16),
                
                Expanded(
                  child: expenses.isEmpty
                      ? Center(child: Text('No recent expenses.', style: secondaryTextStyle))
                      : ListView.builder(
                          itemCount: expenses.length,
                          itemBuilder: (ctx, index) {
                            final exp = expenses[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: surfaceColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Text(exp.categoryIcon, style: const TextStyle(fontSize: 24)),
                                title: Text(exp.categoryName, style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontFamily: appFont)),
                                subtitle: Text(
                                  '${exp.date.year}-${exp.date.month.toString().padLeft(2, '0')}-${exp.date.day.toString().padLeft(2, '0')}',
                                  style: secondaryTextStyle,
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('${exp.amount.toStringAsFixed(0)} EGP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor, fontFamily: appFont)),
                                    IconButton(
                                      icon: Icon(Icons.close, color: textSecondary.withValues(alpha: 0.4)),
                                      onPressed: () => _confirmAndDelete(context, exp, surfaceColor, textColor),
                                    ),
                                  ],
                                ),
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