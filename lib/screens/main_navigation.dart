import 'package:flutter/material.dart';
import '../screens/home_page.dart';
import '../screens/history_page.dart';
import '../screens/analytics_page.dart';
import '../screens/goals_page.dart';
import '../core/constants/colors.dart'; // Import your new colors file

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late PageController _pageController;
  final String appFont = 'Poppins'; // Ensure the custom font is consistent

  final List<Widget> _pages = const [
    HomePage(),
    HistoryPage(),
    AnalyticsPage(),
    GoalsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine if the device is in dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Assign colors dynamically from AppColors
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final unselectedColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      backgroundColor: bgColor, // Update Scaffold background
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: surfaceColor,
        // Use brand colors for navigation states
        selectedItemColor: AppColors.primaryBlue, 
        unselectedItemColor: unselectedColor.withValues(alpha: 0.6),
        // Apply custom font to labels
        selectedLabelStyle: TextStyle(fontFamily: appFont, fontWeight: FontWeight.bold),
        unselectedLabelStyle: TextStyle(fontFamily: appFont),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Analytics'),
          BottomNavigationBarItem(icon: Icon(Icons.track_changes), label: 'Goals'),
        ],
      ),
    );
  }
}