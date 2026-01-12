import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xFF12122A),
      selectedItemColor: const Color(0xFFB37CFF),
      unselectedItemColor: Colors.white70,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.access_time),
          label: "Tracker",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event_note),
          label: "Plans",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.insights),
          label: "Insights",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite_outline),
          label: "Wellness",
        ),
      ],
    );
  }
}
