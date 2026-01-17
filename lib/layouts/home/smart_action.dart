import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class SmartActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const SmartActionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: AppTheme.radiusLarge,
          border: Border.all(color: AppTheme.borderSoft),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primary),
            const SizedBox(height: 12),
            Text(title, style: AppTheme.h3),
            const SizedBox(height: 4),
            Text(subtitle, style: AppTheme.bodyMuted),
          ],
        ),
      ),
    );
  }
}
