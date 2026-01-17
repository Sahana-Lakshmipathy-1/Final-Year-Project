import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class TodayFocusCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;

  const TodayFocusCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: AppTheme.radiusXL,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.h2Dark),
                  const SizedBox(height: 6),
                  Text(subtitle, style: AppTheme.bodyDark),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(cta, style: AppTheme.ctaDark),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.play_circle_fill_rounded,
              size: 54,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
