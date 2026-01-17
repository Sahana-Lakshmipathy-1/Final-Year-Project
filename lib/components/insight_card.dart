import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class InsightCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const InsightCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppTheme.radiusLarge,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.cardBg,
            borderRadius: AppTheme.radiusLarge,
            border: Border.all(
              color: accentColor.withOpacity(0.35),
            ),
          ),
          child: Row(
            children: [
              /// ICON
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: AppTheme.radiusMedium,
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              /// TEXT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTheme.h2.copyWith(
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: AppTheme.bodyMuted,
                    ),
                  ],
                ),
              ),

              /// CHEVRON
              Icon(
                Icons.chevron_right,
                color: AppTheme.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
