import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class ExploreIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ExploreIcon({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardBgAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            Text(label, style: AppTheme.caption),
          ],
        ),
      ),
    );
  }
}
