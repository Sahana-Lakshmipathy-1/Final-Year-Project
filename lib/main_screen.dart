// lib/pages/main_screen.dart
import 'package:flutter/material.dart';
import 'package:lumora/pages/home.dart';
import 'package:lumora/pages/insights.dart';
import 'package:lumora/pages/plans.dart';
import 'package:lumora/pages/wellness.dart';
import 'package:lumora/components/bottom_navbar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // ✅ Replace placeholders with actual pages
  final List<Widget> _pages = const [
    HomeScreen(), // replace with HomePage() if your class is named that
    Center(child: Text("Tracker Page", style: TextStyle(fontSize: 20))),
    PlansScreen(),
    InsightsScreen(), // make sure InsightsScreen matches your insights.dart
    WellnessPage(), // ✅ now using your wellness.dart screen
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
