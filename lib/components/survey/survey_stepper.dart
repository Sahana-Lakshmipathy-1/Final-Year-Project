import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class SurveyStepper extends StatelessWidget {
  final String label;
  final int value;
  final String? unit;
  final int min;
  final int max;
  final void Function(int delta) onChanged;

  const SurveyStepper({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.unit,
  });

  bool get _canDecrement => value > min;
  bool get _canIncrement => value < max;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// LABEL
        Text(label, style: AppTheme.h2),

        const SizedBox(height: 10),

        /// STEPPER CARD
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: AppTheme.card,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StepButton(
                icon: Icons.remove,
                enabled: _canDecrement,
                onTap: () => onChanged(-1),
              ),

              /// VALUE + UNIT
              Row(
                children: [
                  Text(
                    value.toString(),
                    style: AppTheme.h1.copyWith(fontSize: 22),
                  ),
                  if (unit != null) ...[
                    const SizedBox(width: 6),
                    Text(unit!, style: AppTheme.bodyMuted),
                  ],
                ],
              ),

              _StepButton(
                icon: Icons.add,
                enabled: _canIncrement,
                onTap: () => onChanged(1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 🔹 Internal step button
class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const _StepButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: AppTheme.radiusSmall,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: enabled
                ? AppTheme.primary.withOpacity(0.15)
                : AppTheme.borderSoft,
            borderRadius: AppTheme.radiusSmall,
          ),
          child: Icon(
            icon,
            color: enabled ? AppTheme.primary : AppTheme.textMuted,
            size: 22,
          ),
        ),
      ),
    );
  }
}
