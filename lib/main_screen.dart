import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/components/bottom_navbar.dart';

import 'package:lumora/pages/home.dart';
import 'package:lumora/pages/tracker.dart';
import 'package:lumora/pages/plans.dart';
import 'package:lumora/pages/insights.dart';
import 'package:lumora/pages/wellness.dart';

class MainScreen extends StatefulWidget {
  // 1. Add the variable to hold the name
  final String userName;

  // 2. Add it to the constructor so other pages can pass it in
  const MainScreen({
    super.key,
    required this.userName,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 3. Pass widget.userName to the HomeScreen
    final List<Widget> tabs = [
      HomeScreen(userName: widget.userName),
      const TrackerScreen(),
      const PlansScreen(),
      const InsightsScreen(),
      const WellnessPage(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.bg,

      // Keeps tab state alive
      body: IndexedStack(
        index: _activeIndex,
        children: tabs,
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: _activeIndex,
        onTap: (index) => setState(() => _activeIndex = index),
      ),
    );
  }
}
