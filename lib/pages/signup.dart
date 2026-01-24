import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/components/login/sign_up_form.dart'; // Imports your updated form
import 'package:lumora/pages/login.dart'; // For the "Log in" footer link

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
                  /// HEADER
                  /// ------------------------------------------------------------
                  Text(
                    "Create your account",
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
                    decoration: AppTheme.card,
                    clipBehavior:
                        Clip.antiAlias, // Ensures ink ripples don't spill out
                    // 🛡️ CRITICAL: This Material widget prevents the crash.
                    // Since your SignUpForm uses TextFields, they need this
                    // parent to draw on.
                    child: Material(
                      type: MaterialType.transparency,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: const SignUpForm(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// ------------------------------------------------------------
                  /// FOOTER ACTION
                  /// ------------------------------------------------------------
                  TextButton(
                    onPressed: () {
                      // Switch back to Login Page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
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
