import 'package:flutter/material.dart';
import '../data/remote/firebase_service.dart';
import '../data/models/expense.dart';

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

  // Helper to check if a date falls within the selected filter
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
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final secondaryText = onSurface.withValues(alpha: 0.6);

    return Scaffold(
      appBar: AppBar(
        title: Text('History', style: TextStyle(fontWeight: FontWeight.bold, color: onSurface)),
        backgroundColor: Colors.transparent,
        elevation: 0,
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
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(color: isSelected ? theme.colorScheme.onPrimary : onSurface),
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
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
                _buildCategoryChip('All Categories', null, theme),
                ...ExpenseCategory.values.map((cat) => _buildCategoryChip(cat.name, cat, theme)),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Grouped List
          Expanded(
            child: StreamBuilder<List<Expense>>(
              stream: FirebaseService().getExpenses(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final allExpenses = snapshot.data ?? [];
                
                // Apply Filters
                final filteredExpenses = allExpenses.where((exp) {
                  final matchesCategory = _selectedCategory == null || exp.category == _selectedCategory;
                  return matchesCategory && _matchesDateFilter(exp.date);
                }).toList();

                if (filteredExpenses.isEmpty) {
                  return Center(child: Text('No expenses found for these filters.', style: TextStyle(color: secondaryText)));
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

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Group Header
                        Padding(
                          padding: const EdgeInsets.only(top: 16, bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${date.day}/${date.month}/${date.year}', style: TextStyle(fontWeight: FontWeight.bold, color: onSurface)),
                              Text('${dailyTotal.toStringAsFixed(0)} EGP', style: TextStyle(fontWeight: FontWeight.bold, color: onSurface)),
                            ],
                          ),
                        ),
                        // Daily Items
                        ...dailyExpenses.map((exp) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Text(exp.categoryIcon, style: const TextStyle(fontSize: 24)),
                          title: Text(exp.categoryName, style: TextStyle(fontWeight: FontWeight.bold, color: onSurface)),
                          subtitle: Text((exp.note == null || exp.note!.isEmpty) ? 'Expense' : exp.note!, style: TextStyle(color: secondaryText)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('${exp.amount.toStringAsFixed(0)} EGP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: onSurface)),
                              IconButton(
                                icon: Icon(Icons.close, color: secondaryText),
                                onPressed: () => _confirmAndDelete(context, exp),
                              ),
                            ],
                          ),
                        )),
                      ],
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
      case DateFilter.today: return 'Today';
      case DateFilter.thisWeek: return 'This week';
      case DateFilter.month: return 'Month';
      case DateFilter.allTime: return 'All Time';
    }
  }

  Widget _buildCategoryChip(String label, ExpenseCategory? category, ThemeData theme) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: theme.colorScheme.secondaryContainer,
        labelStyle: TextStyle(color: isSelected ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onSurface),
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        side: BorderSide.none,
        onSelected: (_) => setState(() => _selectedCategory = category),
      ),
    );
  }
}