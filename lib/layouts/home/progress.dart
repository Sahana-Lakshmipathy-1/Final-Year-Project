import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

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
        children: const [
          _ProgressItem("🔥", "Streak", "4 days"),
          _ProgressItem("💪", "Workouts", "12"),
          _ProgressItem("🧠", "Mood logs", "6"),
        ],
      ),
    );
  }
}

class _ProgressItem extends StatelessWidget {
  final String emoji;
  final String label;
  final String value;

  const _ProgressItem(this.emoji, this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 6),
        Text(value, style: AppTheme.h3),
        Text(label, style: AppTheme.caption),
      ],
    );
  }
}
