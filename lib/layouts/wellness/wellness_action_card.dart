import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class WellnessActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String cta;
  final IconData icon;
  final VoidCallback onTap;

  const WellnessActionCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.cta,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: AppTheme.card,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(.15),
                  borderRadius: AppTheme.radiusSmall,
                ),
                child: Icon(icon, color: AppTheme.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.h3),
                    const SizedBox(height: 4),
                    Text(subtitle, style: AppTheme.bodyMuted),
                  ],
                ),
              ),
              Text(
                cta,
                style: AppTheme.body.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
