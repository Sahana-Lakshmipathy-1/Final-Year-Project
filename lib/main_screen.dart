import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/components/bottom_navbar.dart';

import 'package:lumora/pages/home.dart';
import 'package:lumora/pages/tracker.dart';
import 'package:lumora/pages/plans.dart';
import 'package:lumora/pages/insights.dart';
import 'package:lumora/pages/wellness.dart';

class MainScreen extends StatefulWidget {
  // ❌ No variables needed here anymore!
  // The session is handled globally by UserSession.
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _activeIndex = 0;

  // Define tabs as a final list since they don't depend on constructor args anymore
  final List<Widget> _tabs = const [
    HomeScreen(), // ✅ Clean! No arguments needed.
    TrackerScreen(),
    PlansScreen(),
    InsightsScreen(),
    WellnessPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,

      // IndexedStack keeps the state of tabs alive (so you don't lose scroll position)
      body: IndexedStack(
        index: _activeIndex,
        children: _tabs,
      ),

      bottomNavigationBar: BottomNavBar(
        currentIndex: _activeIndex,
        onTap: (index) => setState(() => _activeIndex = index),
      ),
    );
  }
}
