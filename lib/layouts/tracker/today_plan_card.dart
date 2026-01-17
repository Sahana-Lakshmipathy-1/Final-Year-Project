import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class TodayPlanCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final Color? accentColor;

  const TodayPlanCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final accent = accentColor ?? AppTheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.cardBgAlt,
            AppTheme.cardBg,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(color: accent.withOpacity(0.25)),
        boxShadow: AppTheme.softShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppTheme.radiusLarge,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                /// ICON BADGE
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    icon,
                    color: accent,
                    size: 26,
                  ),
                ),

                const SizedBox(width: 16),

                /// TEXT CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTheme.h2.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: AppTheme.bodyMuted.copyWith(height: 1.4),
                      ),
                    ],
                  ),
                ),

                /// CHEVRON (navigation hint)
                Icon(
                  Icons.chevron_right_rounded,
                  color: AppTheme.textMuted,
                  size: 28,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
