import 'package:flutter/material.dart';
import '../screens/home_page.dart';
import '../screens/history_page.dart';
import '../screens/analytics_page.dart';
import '../screens/goals_page.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  // 1. Define a PageController
  late PageController _pageController;

  final List<Widget> _pages = const [
    HomePage(),
    HistoryPage(),
    AnalyticsPage(),
    GoalsPage(),
  ];

  @override
  void initState() {
    super.initState();
    // 2. Initialize the controller to start at the current index
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    // 3. Dispose of the controller to prevent memory leaks
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    // 4. Animate to the corresponding page when a bottom tab is tapped
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // 5. Replace the static body with a PageView
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          // 6. Update the bottom navigation bar when the user swipes
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
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
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