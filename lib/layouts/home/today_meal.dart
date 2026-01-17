import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class TodayMealCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String cta;
  final VoidCallback onTap;

  const TodayMealCard({
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
          color: AppTheme.cardBgAlt,
          borderRadius: AppTheme.radiusXL,
          border: Border.all(color: AppTheme.borderSoft),
        ),
        child: Row(
          children: [
            /// TEXT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.h2),
                  const SizedBox(height: 6),
                  Text(subtitle, style: AppTheme.bodyMuted),
                  const SizedBox(height: 14),

                  /// CTA
                  Text(
                    cta,
                    style: AppTheme.body.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            /// ICON
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.restaurant_menu_rounded,
                color: AppTheme.primary,
                size: 28,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
