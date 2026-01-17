import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border(
          top: BorderSide(color: AppTheme.borderSoft),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,

        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textMuted,

        selectedLabelStyle: AppTheme.caption.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTheme.caption,

        // ❌ const REMOVED here
        items: [
          _NavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            label: "Home",
          ),
          _NavItem(
            icon: Icons.access_time_outlined,
            activeIcon: Icons.access_time_filled,
            label: "Tracker",
          ),
          _NavItem(
            icon: Icons.event_note_outlined,
            activeIcon: Icons.event_note,
            label: "Plans",
          ),
          _NavItem(
            icon: Icons.insights_outlined,
            activeIcon: Icons.insights,
            label: "Insights",
          ),
          _NavItem(
            icon: Icons.favorite_outline,
            activeIcon: Icons.favorite,
            label: "Wellness",
          ),
        ],
      ),
    );
  }
}

/// Internal nav item helper
class _NavItem extends BottomNavigationBarItem {
  _NavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) : super(
         icon: Icon(icon),
         activeIcon: Icon(activeIcon),
         label: label,
       );
}
