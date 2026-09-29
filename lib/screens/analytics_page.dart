import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/remote/firebase_service.dart';
import '../data/models/expense.dart';
import '../core/constants/colors.dart'; // Import your colors file

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  // 1. State for the currently viewed month
  late DateTime _selectedMonth;
  final String appFont = 'Poppins'; // Custom font consistency

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
  }

  // Helper to get month names
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  // Navigation methods
  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

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
    // Theme setup
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final textSecondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: StreamBuilder<List<Expense>>(
          stream: FirebaseService().getExpenses(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: AppColors.primaryTeal));
            }

            final allExpenses = snapshot.data ?? [];

            // 2. Filter data based on _selectedMonth
            final currentViewExpenses = allExpenses.where((e) =>
                e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month
            ).toList();

            final totalSpent = currentViewExpenses.fold(0.0, (sum, e) => sum + e.amount);

            // Group by Category for the selected month
            final Map<ExpenseCategory, double> categoryTotals = {};
            for (var e in currentViewExpenses) {
              categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
            }

            final sortedCategories = categoryTotals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            // 3. Prepare data for the 6-Month Bar Chart
            final List<BarChartGroupData> barGroups = [];
            double maxMonthlySpend = 0;

            for (int i = 5; i >= 0; i--) {
              final targetMonth = DateTime(now.year, now.month - i);
              final monthExpenses = allExpenses.where((e) =>
                  e.date.year == targetMonth.year && e.date.month == targetMonth.month
              );
              
              final monthTotal = monthExpenses.fold(0.0, (sum, e) => sum + e.amount);
              if (monthTotal > maxMonthlySpend) maxMonthlySpend = monthTotal;

              barGroups.add(
                BarChartGroupData(
                  x: 5 - i,
                  barRods: [
                    BarChartRodData(
                      toY: monthTotal,
                      color: AppColors.primaryTeal, // Use brand teal for bars
                      width: 16,
                      borderRadius: BorderRadius.circular(4),
                    )
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text('Analytics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontFamily: appFont)),
                  const SizedBox(height: 16),

                  // Month Selector UI
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left, color: textColor),
                        onPressed: _previousMonth,
                      ),
                      Text(
                        '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor, fontFamily: appFont),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right, color: textColor),
                        // Disable right button if we are in the current real-world month
                        onPressed: _selectedMonth.isBefore(DateTime(now.year, now.month))
                            ? _nextMonth
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Total Amount for Selected Month
                  Text('${totalSpent.toStringAsFixed(0)} EGP', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: textColor, fontFamily: appFont)),
                  const SizedBox(height: 32),

                  // 6-Month Summary Bar Chart
                  Text('Last 6 months', style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600, fontFamily: appFont)),
                  const SizedBox(height: 16),
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: maxMonthlySpend > 0 ? maxMonthlySpend * 1.2 : 100, // Handle empty data edge case
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide Y-axis numbers for cleaner look
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = 5 - value.toInt();
                                final targetMonth = DateTime(now.year, now.month - index);
                                final shortMonth = _getMonthName(targetMonth.month).substring(0, 3);
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(shortMonth, style: TextStyle(color: textSecondary, fontSize: 12, fontFamily: appFont)),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        gridData: const FlGridData(show: false),
                        barGroups: barGroups,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Category Breakdown Donut Chart
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('By category — ${_getMonthName(_selectedMonth.month)}', style: TextStyle(color: textSecondary, fontFamily: appFont)),
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
                                    title: '', // Hiding inline titles
                                    radius: 25,
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 200,
                            child: Center(child: Text('No data for ${_getMonthName(_selectedMonth.month)}', style: TextStyle(color: textSecondary, fontFamily: appFont)))
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
                                Text('${entry.key.name} · $percentage%', style: TextStyle(color: textColor, fontSize: 16, fontFamily: appFont)),
                                const Spacer(),
                                Text('${entry.value.toStringAsFixed(0)} EGP', style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16, fontFamily: appFont)),
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