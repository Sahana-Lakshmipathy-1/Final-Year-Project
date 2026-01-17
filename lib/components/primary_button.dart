import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: AppTheme.primaryButton,
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? AppTheme.loader(size: 22)
            : Text(
                label,
                style: AppTheme.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
