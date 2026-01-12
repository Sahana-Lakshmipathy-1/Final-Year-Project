import 'package:flutter/material.dart';

class ChipGroup extends StatelessWidget {
  final List<String> options;
  final Set<String> selectedValues;
  final Function(String, bool) onSelectionChanged;
  final Color selectedBg;
  final Color selectedText;
  final Color unselectedBg;
  final Color unselectedText;

  const ChipGroup({
    super.key,
    required this.options,
    required this.selectedValues,
    required this.onSelectionChanged,
    this.selectedBg = const Color(0xFF48E6E4),
    this.selectedText = const Color(0xFF211D3B),
    this.unselectedBg = const Color(0xFF232e40),
    this.unselectedText = const Color(0xFFE9EBF6),
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = selectedValues.contains(option);
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          selectedColor: selectedBg,
          backgroundColor: unselectedBg,
          labelStyle: TextStyle(
            color: isSelected ? selectedText : unselectedText,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
          onSelected: (_) => onSelectionChanged(option, !isSelected),
        );
      }).toList(),
    );
  }
}
