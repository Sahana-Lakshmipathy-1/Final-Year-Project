import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/components/login/sign_up_form.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// ------------------------------------------------------------
                  /// HEADER / EMOTIONAL ANCHOR
                  /// ------------------------------------------------------------
                  Text(
                    "Create your account ✨",
                    style: AppTheme.h1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Let’s personalize your wellness journey.",
                    style: AppTheme.bodyMuted,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  /// ------------------------------------------------------------
                  /// FORM CARD
                  /// ------------------------------------------------------------
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.card,
                    child: const SignUpForm(),
                  ),

                  const SizedBox(height: 24),

                  /// ------------------------------------------------------------
                  /// FOOTER ACTION
                  /// ------------------------------------------------------------
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTheme.body,
                        children: [
                          const TextSpan(text: "Already have an account? "),
                          TextSpan(
                            text: "Log in",
                            style: AppTheme.body.copyWith(
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
