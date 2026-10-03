import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../data/remote/firebase_service.dart';
import '../data/models/expense.dart';
import '../core/constants/colors.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  late DateTime _selectedMonth;
  final String appFont = 'Poppins';
  bool _isArabic = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month);
    
  }



  String _getMonthName(int month) {
    const monthsEn = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    const monthsAr = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return _isArabic ? monthsAr[month - 1] : monthsEn[month - 1];
  }

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

  Color _getCategoryColor(ExpenseCategory category) {
    switch (category) {
      case ExpenseCategory.food: return const Color(0xFFE5C158);
      case ExpenseCategory.transport: return const Color(0xFF6B8BCC);
      case ExpenseCategory.bills: return const Color(0xFFD9725B);
      case ExpenseCategory.shopping: return const Color(0xFF9E6BCC);
      default: return const Color(0xFF8BA3A0);
    }
  }

  @override
  Widget build(BuildContext context) {
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

            // 1. Current selected month expenses
            final currentViewExpenses = allExpenses.where((e) =>
                e.date.year == _selectedMonth.year && e.date.month == _selectedMonth.month
            ).toList();

            final totalSpent = currentViewExpenses.fold(0.0, (sum, e) => sum + e.amount);

            // 2. Previous month expenses (for Trend Discovery)
            final prevMonthDate = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
            final prevMonthExpenses = allExpenses.where((e) =>
                e.date.year == prevMonthDate.year && e.date.month == prevMonthDate.month
            ).toList();
            final prevTotalSpent = prevMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);

            // Calculate Month-over-Month % trend
            double trendPercentage = 0;
            bool isSpendingUp = false;
            if (prevTotalSpent > 0) {
              trendPercentage = ((totalSpent - prevTotalSpent) / prevTotalSpent) * 100;
              isSpendingUp = trendPercentage > 0;
            }

            // Calculate Daily Average
            final daysInMonth = (_selectedMonth.year == now.year && _selectedMonth.month == now.month)
                ? now.day
                : DateUtils.getDaysInMonth(_selectedMonth.year, _selectedMonth.month);
            final dailyAverage = daysInMonth > 0 ? totalSpent / daysInMonth : 0.0;

            // Group by Category
            final Map<ExpenseCategory, double> categoryTotals = {};
            for (var e in currentViewExpenses) {
              categoryTotals[e.category] = (categoryTotals[e.category] ?? 0) + e.amount;
            }

            final sortedCategories = categoryTotals.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));

            final topCategory = sortedCategories.isNotEmpty ? sortedCategories.first.key.name : 'N/A';

            // 3. Prepare data for 6-Month Bar Chart
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
                      color: targetMonth.month == _selectedMonth.month && targetMonth.year == _selectedMonth.year
                          ? AppColors.primaryBlue
                          : AppColors.primaryTeal,
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
                  Text(
                    _isArabic ? 'التحليلات' : 'Analytics',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryBlue, fontFamily: appFont),
                  ),
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
                        onPressed: _selectedMonth.isBefore(DateTime(now.year, now.month))
                            ? _nextMonth
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Total Amount for Selected Month
                  Text(
                    '${totalSpent.toStringAsFixed(0)} EGP',
                    style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: textColor, fontFamily: appFont),
                  ),
                  const SizedBox(height: 20),

                  // NEW: User Trends & Monthly Summary Cards
                  Text(
                    _isArabic ? 'ملخص الشهر والاتجاهات' : 'Monthly Summary & Trends',
                    style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600, fontFamily: appFont),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTrendCard(
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                          textSecondary: textSecondary,
                          icon: Icons.calendar_today_rounded,
                          iconColor: AppColors.primaryTeal,
                          title: _isArabic ? 'المتوسط اليومي' : 'Daily Avg',
                          value: '${dailyAverage.toStringAsFixed(0)} EGP',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTrendCard(
                          surfaceColor: surfaceColor,
                          textColor: textColor,
                          textSecondary: textSecondary,
                          icon: Icons.category_rounded,
                          iconColor: const Color(0xFFE5C158),
                          title: _isArabic ? 'الأعلى إنفاقاً' : 'Top Category',
                          value: topCategory.toUpperCase(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Trend Discovery Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          prevTotalSpent == 0
                              ? Icons.info_outline
                              : (isSpendingUp ? Icons.trending_up : Icons.trending_down),
                          color: prevTotalSpent == 0
                              ? textSecondary
                              : (isSpendingUp ? Colors.redAccent : Colors.green),
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            prevTotalSpent == 0
                                ? (_isArabic ? 'لا توجد بيانات للشهر الماضي للمقارنة.' : 'No data from last month to compare trends.')
                                : (isSpendingUp
                                    ? 'You spent ${trendPercentage.abs().toStringAsFixed(1)}% more than last month.'
                                    : 'Great job! You spent ${trendPercentage.abs().toStringAsFixed(1)}% less than last month.'),
                            style: TextStyle(color: textColor, fontSize: 14, fontFamily: appFont),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 6-Month Summary Bar Chart
                  Text(
                    _isArabic ? 'آخر 6 أشهر' : 'Last 6 months',
                    style: TextStyle(color: textSecondary, fontWeight: FontWeight.w600, fontFamily: appFont),
                  ),
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
                        maxY: maxMonthlySpend > 0 ? maxMonthlySpend * 1.2 : 100,
                        titlesData: FlTitlesData(
                          show: true,
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (value, meta) {
                                final index = 5 - value.toInt();
                                final targetMonth = DateTime(now.year, now.month - index);
                                final monthLabel = _getMonthName(targetMonth.month);
                                final shortMonth = monthLabel.length > 3 && !_isArabic
                                    ? monthLabel.substring(0, 3)
                                    : monthLabel;
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
                        Text(
                          '${_isArabic ? 'حسب الفئة' : 'By category'} — ${_getMonthName(_selectedMonth.month)}',
                          style: TextStyle(color: textSecondary, fontFamily: appFont),
                        ),
                        const SizedBox(height: 32),
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
                                    title: '',
                                    radius: 25,
                                  );
                                }).toList(),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            height: 200,
                            child: Center(
                              child: Text(
                                'No data for ${_getMonthName(_selectedMonth.month)}',
                                style: TextStyle(color: textSecondary, fontFamily: appFont),
                              ),
                            ),
                          ),
                        const SizedBox(height: 40),
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

  Widget _buildTrendCard({
    required Color surfaceColor,
    required Color textColor,
    required Color textSecondary,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(title, style: TextStyle(color: textSecondary, fontSize: 12, fontFamily: appFont)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: appFont)),
        ],
      ),
    );
  }
}