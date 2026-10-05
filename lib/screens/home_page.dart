import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/models/expense.dart';
import '../widgets/add_expense_modal.dart';
import '../widgets/expense_item_tile.dart'; // Reusable expense item widget
import '../screens/profile_page.dart';
import '../data/remote/firebase_service.dart';
import '../core/constants/colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseService _firebaseService = FirebaseService();
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    final secondaryTextStyle = TextStyle(
      color: textSecondary,
      fontFamily: appFont,
    );

    // Fetch the current user data
    final user = FirebaseAuth.instance.currentUser;
    // Fallback to email prefix or 'User' if display name is not set
    final userName = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!
        : (user?.email?.split('@').first ?? 'User');
    final userInitial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            // Masroufi Logo
            ClipOval(
              child: Image.asset(
                'lib/assets/icon/masroufi_logo_cropped2.png',
                height: 36,
                width: 36,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Masroufi',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                color: AppColors.primaryBlue,
                fontFamily: appFont,
              ),
            ),
          ],
        ),
        actions: [
          // User Name
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Text(
                userName,
                style: TextStyle(
                  color: textColor,
                  fontFamily: appFont,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          // User Initial Avatar (Clickable to go to Profile)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            child: CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primaryTeal,
              child: Text(
                userInitial,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: appFont,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<List<Expense>>(
        stream: _firebaseService.getExpenses(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryTeal),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error loading expenses', style: secondaryTextStyle),
            );
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

          // Sort by date descending (newest first) and take only the last 6
          final sortedExpenses = [...expenses]..sort((a, b) => b.date.compareTo(a.date));
          final recentExpenses = sortedExpenses.take(6).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
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
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Spent this month', style: TextStyle(color: Colors.white70, fontFamily: appFont)),
                      const SizedBox(height: 8),
                      Text(
                        '${spentThisMonth.toStringAsFixed(0)} EGP',
                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: appFont),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Today', style: TextStyle(color: Colors.white70, fontFamily: appFont)),
                              Text(
                                '${spentToday.toStringAsFixed(0)} EGP',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: appFont),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('This week', style: TextStyle(color: Colors.white70, fontFamily: appFont)),
                              Text(
                                '${spentThisWeek.toStringAsFixed(0)} EGP',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontFamily: appFont),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentCyan,
                            foregroundColor: AppColors.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => _openAddExpenseOverlay(surfaceColor),
                          child: Text(
                            '+ Add expense',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: appFont),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Recent',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor, fontFamily: appFont),
                ),
                const SizedBox(height: 16),
                recentExpenses.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(child: Text('No recent expenses.', style: secondaryTextStyle)),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: recentExpenses.length,
                        itemBuilder: (ctx, index) {
                          final exp = recentExpenses[index];
                          return ExpenseItemTile(
                            expense: exp,
                            showCard: true,
                            appFont: appFont,
                            onDelete: () => _firebaseService.deleteExpense(exp.id),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}