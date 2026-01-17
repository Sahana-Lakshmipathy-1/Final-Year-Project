import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/components/bottom_navbar.dart';

import 'package:lumora/pages/home.dart';
import 'package:lumora/pages/tracker.dart';
import 'package:lumora/pages/plans.dart';
import 'package:lumora/pages/insights.dart';
import 'package:lumora/pages/wellness.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _activeIndex = 0;

  /// Centralized tabs (easy to reorder, log, deep-link)
  static const List<Widget> _tabs = [
    HomeScreen(),
    TrackerScreen(),
    PlansScreen(),
    InsightsScreen(),
    WellnessPage(),
  ];

  void _onTabSelected(int index) {
    if (index == _activeIndex) return;

    setState(() => _activeIndex = index);

    // 🔮 Future hooks:
    // analytics.logEvent(name: 'tab_switched', parameters: {'index': index});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,

      /// Keeps tab state alive (scroll position, forms, charts, etc.)
      body: IndexedStack(
        index: _activeIndex,
        children: _tabs,
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: _activeIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
