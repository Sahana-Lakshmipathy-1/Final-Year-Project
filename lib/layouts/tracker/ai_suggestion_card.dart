import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class AISuggestionCard extends StatelessWidget {
  final String message;
  final String title;
  final IconData icon;
  final Color? accentColor;
  final VoidCallback? onTap;

  const AISuggestionCard({
    super.key,
    required this.message,
    this.title = "AI Coach",
    this.icon = Icons.auto_awesome,
    this.accentColor,
    this.onTap,
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
        border: Border.all(color: accent.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: accent.withOpacity(0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppTheme.radiusLarge,
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ICON BADGE
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: accent,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 14),

                /// TEXT CONTENT
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.toUpperCase(),
                        style: AppTheme.caption.copyWith(
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textGrey,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        message,
                        style: AppTheme.body.copyWith(
                          fontWeight: FontWeight.w600,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                /// OPTIONAL CHEVRON (future expandable)
                if (onTap != null) ...[
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: AppTheme.textMuted,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
