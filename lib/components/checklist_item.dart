import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ChecklistItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool completed;
  final VoidCallback onToggle;

  const ChecklistItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.completed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: completed
              ? AppTheme.primary.withOpacity(0.12)
              : AppTheme.cardBgAlt,
          borderRadius: AppTheme.radiusMedium,
          border: Border.all(
            color: completed ? AppTheme.primary : AppTheme.borderSoft,
          ),
        ),
        child: Row(
          children: [
            Icon(
              completed ? LucideIcons.checkCircle : LucideIcons.circle,
              color: completed ? AppTheme.primary : AppTheme.textMuted,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.body.copyWith(
                      fontWeight: FontWeight.w600,
                      decoration: completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: AppTheme.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
