import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class ChipGroup extends StatelessWidget {
  final List<String> options;
  final Set<String> selectedValues;
  final void Function(String value, bool isSelected) onSelectionChanged;

  const ChipGroup({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onSelectionChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option);

        return ChoiceChip(
          labelPadding: const EdgeInsets.symmetric(horizontal: 6),
          label: Text(
            option,
            style: AppTheme.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: isSelected ? AppTheme.primary : AppTheme.textGrey,
            ),
          ),

          selected: isSelected,

          /// 🎨 COLORS
          selectedColor: AppTheme.primary.withOpacity(0.14),
          backgroundColor: AppTheme.cardBgAlt,

          /// 🧱 SHAPE
          shape: RoundedRectangleBorder(
            borderRadius: AppTheme.radiusSmall,
            side: BorderSide(
              color: isSelected ? AppTheme.primary : AppTheme.borderSoft,
            ),
          ),

          /// 📏 TAP TARGET
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 10,
          ),

          /// 🎯 INTERACTION
          onSelected: (_) => onSelectionChanged(option, !isSelected),

          /// ♿ ACCESSIBILITY
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }
}
