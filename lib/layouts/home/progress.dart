import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProgressStrip extends StatelessWidget {
  const ProgressStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.radiusLarge,
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ProgressItem(LucideIcons.flame, "Streak", "4 days"),
          _ProgressItem(LucideIcons.dumbbell, "Workouts", "12"),
          _ProgressItem(LucideIcons.brain, "Mood logs", "6"),
        ],
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ProgressItem(
    this.icon,
    this.label,
    this.value, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: AppTheme.radiusSmall,
          ),
          child: Icon(
            icon,
            color: AppTheme.primary,
            size: 22,
          ),
        ),
        const SizedBox(height: 6),
        Text(value, style: AppTheme.h3),
        const SizedBox(height: 2),
        Text(label, style: AppTheme.caption),
      ],
    );
  }
}
