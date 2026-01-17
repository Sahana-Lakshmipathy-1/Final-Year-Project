import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class FirstAidCategoryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap; // ✅ added

  const FirstAidCategoryCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap, // ✅ added
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // ✅ wired
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.elevatedCard,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 28, color: AppTheme.primary),
            const SizedBox(height: 12),
            Text(title, style: AppTheme.h3),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTheme.caption),
          ],
        ),
      ),
    );
  }
}
