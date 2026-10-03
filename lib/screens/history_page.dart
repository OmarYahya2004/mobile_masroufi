import 'package:flutter/material.dart';
import '../data/remote/firebase_service.dart';
import '../data/models/expense.dart';
import '../widgets/expense_item_tile.dart'; // Reusable expense item widget
import '../core/constants/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/profile_page.dart';

enum DateFilter { today, thisWeek, month, allTime }

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateFilter _selectedDateFilter = DateFilter.month;
  ExpenseCategory? _selectedCategory; // null means 'All'
  final FirebaseService _firebaseService = FirebaseService();
  final String appFont = 'Poppins';

  bool _matchesDateFilter(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expenseDate = DateTime(date.year, date.month, date.day);

    switch (_selectedDateFilter) {
      case DateFilter.today:
        return expenseDate.isAtSameMomentAs(today);
      case DateFilter.thisWeek:
        final weekAgo = today.subtract(const Duration(days: 7));
        return expenseDate.isAfter(weekAgo) || expenseDate.isAtSameMomentAs(weekAgo);
      case DateFilter.month:
        return expenseDate.year == today.year && expenseDate.month == today.month;
      case DateFilter.allTime:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Theme setup
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final chipBgColor = isDark ? AppColors.darkInputFill : AppColors.lightInputFill;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;






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
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'History',
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Date Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: DateFilter.values.map((filter) {
                final isSelected = _selectedDateFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(_getFilterName(filter)),
                    selected: isSelected,
                    selectedColor: AppColors.primaryBlue,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : textColor,
                      fontFamily: appFont,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: chipBgColor,
                    side: BorderSide.none,
                    onSelected: (_) => setState(() => _selectedDateFilter = filter),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // 2. Category Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildCategoryChip('All Categories', null, chipBgColor, textColor),
                ...ExpenseCategory.values.map((cat) => _buildCategoryChip(cat.name, cat, chipBgColor, textColor)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Grouped List
          Expanded(
            child: StreamBuilder<List<Expense>>(
              stream: _firebaseService.getExpenses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primaryTeal),
                  );
                }

                final allExpenses = snapshot.data ?? [];

                // Apply Filters
                final filteredExpenses = allExpenses.where((exp) {
                  final matchesCategory = _selectedCategory == null || exp.category == _selectedCategory;
                  return matchesCategory && _matchesDateFilter(exp.date);
                }).toList();

                if (filteredExpenses.isEmpty) {
                  return Center(
                    child: Text(
                      'No expenses found for these filters.',
                      style: TextStyle(color: textSecondary, fontFamily: appFont),
                    ),
                  );
                }

                // Group by Date
                final Map<DateTime, List<Expense>> grouped = {};
                for (var exp in filteredExpenses) {
                  final dateKey = DateTime(exp.date.year, exp.date.month, exp.date.day);
                  grouped.putIfAbsent(dateKey, () => []).add(exp);
                }

                // Sort dates descending
                final sortedDates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: sortedDates.length,
                  itemBuilder: (context, index) {
                    final date = sortedDates[index];
                    final dailyExpenses = grouped[date]!;
                    final dailyTotal = dailyExpenses.fold(0.0, (sum, exp) => sum + exp.amount);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Group Header
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${date.day}/${date.month}/${date.year}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontFamily: appFont),
                                ),
                                Text(
                                  '${dailyTotal.toStringAsFixed(0)} EGP',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryTeal, fontFamily: appFont),
                                ),
                              ],
                            ),
                          ),
                          // Daily Items using Reusable Widget
                          ...dailyExpenses.map(
                            (exp) => ExpenseItemTile(
                              expense: exp,
                              showCard: false,
                              appFont: appFont,
                              onDelete: () => _firebaseService.deleteExpense(exp.id),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getFilterName(DateFilter filter) {
    switch (filter) {
      case DateFilter.today:
        return 'Today';
      case DateFilter.thisWeek:
        return 'This week';
      case DateFilter.month:
        return 'Month';
      case DateFilter.allTime:
        return 'All Time';
    }
  }

  Widget _buildCategoryChip(String label, ExpenseCategory? category, Color chipBgColor, Color textColor) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.primaryTeal,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : textColor,
          fontFamily: appFont,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: chipBgColor,
        side: BorderSide.none,
        onSelected: (_) => setState(() => _selectedCategory = category),
      ),
    );
  }
}