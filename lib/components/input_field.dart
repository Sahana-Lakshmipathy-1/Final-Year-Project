import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData? prefixIcon;
  final bool obscureText;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;

  const InputField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    this.prefixIcon,
    this.obscureText = false,
    this.validator,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      keyboardType: keyboardType,
      style: AppTheme.body,

      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,

        // 🎨 ICON
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppTheme.textMuted)
            : null,

        // ✍️ TEXT STYLES
        hintStyle: AppTheme.bodyMuted,
        labelStyle: AppTheme.caption,

        // 📏 SPACING
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 16,
        ),
      ),
    );
  }
}
