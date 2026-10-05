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
    // Check device orientation for responsiveness
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    // Determine if the device is in dark mode
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Assign colors dynamically from AppColors
    final bgColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final surfaceColor =
        isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final unselectedColor =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;
    final mutedUnselectedColor = unselectedColor.withValues(alpha: 0.6);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Row(
          children: [
            // Landscape: Side NavigationRail with pill indicator
            if (isLandscape)
              NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onTabTapped,
                backgroundColor: surfaceColor,
                indicatorColor: AppColors.accentCyan,
                labelType: NavigationRailLabelType.all,
                selectedIconTheme: const IconThemeData(
                  color: AppColors.primaryBlue,
                ),
                unselectedIconTheme: IconThemeData(
                  color: mutedUnselectedColor,
                ),
                selectedLabelTextStyle: TextStyle(
                  fontFamily: appFont,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
                unselectedLabelTextStyle: TextStyle(
                  fontFamily: appFont,
                  color: mutedUnselectedColor,
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.receipt_long),
                    label: Text('History'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.bar_chart),
                    label: Text('Analytics'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.track_changes),
                    label: Text('Goals'),
                  ),
                ],
              ),

            if (isLandscape)
              VerticalDivider(
                thickness: 1,
                width: 1,
                color: mutedUnselectedColor.withValues(alpha: 0.2),
              ),

            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                children: _pages,
              ),
            ),
          ],
        ),
      ),
      // Portrait: Material 3 NavigationBar (matches the pill style of NavigationRail)
      bottomNavigationBar: isLandscape
          ? null
          : NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: surfaceColor,
                indicatorColor: AppColors.accentCyan,
                iconTheme: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return const IconThemeData(color: AppColors.primaryBlue);
                  }
                  return IconThemeData(color: mutedUnselectedColor);
                }),
                labelTextStyle: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return TextStyle(
                      fontFamily: appFont,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: AppColors.primaryBlue,
                    );
                  }
                  return TextStyle(
                    fontFamily: appFont,
                    fontSize: 12,
                    color: mutedUnselectedColor,
                  );
                }),
              ),
              child: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onTabTapped,
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.home),
                    label: 'Home',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.receipt_long),
                    label: 'History',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.bar_chart),
                    label: 'Analytics',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.track_changes),
                    label: 'Goals',
                  ),
                ],
              ),
            ),
    );
  }
}