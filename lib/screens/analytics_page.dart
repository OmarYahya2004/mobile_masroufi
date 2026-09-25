import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/remote/firebase_service.dart';
import '../data/models/expense.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  // Map categories to specific chart colors
  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food: return const Color(0xFFE5C158);
      case ExpenseCategory.transport: return const Color(0xFF6B8BCC);
      case ExpenseCategory.bills: return const Color(0xFFD9725B);
      case ExpenseCategory.shopping: return const Color(0xFF9E6BCC);
      default: return const Color(0xFF8BA3A0); // Other / Fun
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final secondaryText = onSurface.withValues(alpha: 0.6);

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<List<Expense>>(
          stream: FirebaseService().getExpenses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final allExpenses = snapshot.data ?? [];

            // 1. Filter for THIS month only
            final now = DateTime.now();
            final thisMonthExpenses = allExpenses.where((e) => 
              e.date.year == now.year && e.date.month == now.month
            ).toList();

            // 2. Calculate Total
            final totalSpent = thisMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);

            // 3. Group by Category
            final Map<ExpenseCategory, double> categoryTotals = {};
            for (var e in thisMonthExpenses) {
              categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
            }

            // Sort categories by highest spending
            final sortedCategories = categoryTotals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text('Analytics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: onSurface)),
                  const SizedBox(height: 4),
                  Text('Spending trends by category', style: TextStyle(color: secondaryText, fontSize: 14)),
                  const SizedBox(height: 24),
                  
                  // Total Amount
                  Text('${totalSpent.toStringAsFixed(0)} EGP', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: onSurface)),
                  const SizedBox(height: 32),

                  // Chart Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('By category — this month', style: TextStyle(color: secondaryText)),
                        const SizedBox(height: 32),
                        
                        // Donut Chart
                        if (totalSpent > 0)
                          SizedBox(
                            height: 200,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 0,
                                centerSpaceRadius: 60,
                                sections: sortedCategories.map((entry) {
                                  return PieChartSectionData(
                                    color: _getCategoryColor(entry.key),
                                    value: entry.value,
                                    title: '', // Hiding inline titles to match your design
                                    radius: 25,
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        else
                          const SizedBox(
                            height: 200, 
                            child: Center(child: Text('No data for this month'))
                          ),
                        
                        const SizedBox(height: 40),
                        
                        // Legend List
                        ...sortedCategories.map((entry) {
                          final percentage = ((entry.value / totalSpent) * 100).toStringAsFixed(0);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              children: [
                                Container(
                                  width: 12,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(entry.key),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('${entry.key.name} · $percentage%', style: TextStyle(color: onSurface, fontSize: 16)),
                                const Spacer(),
                                Text('${entry.value.toStringAsFixed(0)} EGP', style: TextStyle(fontWeight: FontWeight.bold, color: onSurface, fontSize: 16)),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}