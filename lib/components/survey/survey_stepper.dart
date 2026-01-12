import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFF232340);
    const borderColor = Color(0xFF333353);
    const labelColor = Color(0xFFbcb7f6);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: labelColor, fontSize: 18)),
        const SizedBox(height: 8),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepButton(icon: "-", onPressed: () => _handleChange(-1)),
              const SizedBox(width: 6),
              SizedBox(
                width: 54,
                child: Text(
                  value.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 6),
                Text(
                  unit!,
                  style: const TextStyle(color: labelColor, fontSize: 16),
                ),
              ],
              const SizedBox(width: 6),
              _StepButton(icon: "+", onPressed: () => _handleChange(1)),
            ],
          ),
        ),
      ],
    );
  }

  void _handleChange(int delta) {
    final newValue = value + delta;
    if (newValue >= min && newValue <= max) {
      onChanged(delta);
    }
  }
}

class _StepButton extends StatelessWidget {
  final String icon;
  final VoidCallback onPressed;

  const _StepButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    const btnColor = Color(0xFFbcb7f6);

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.symmetric(horizontal: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            icon,
            style: const TextStyle(color: btnColor, fontSize: 22),
          ),
        ),
      ),
    );
  }
}
