import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/components/login/login_form.dart';
import 'package:lumora/pages/signup.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  /// ------------------------------------------------------------
                  /// HEADER
                  /// ------------------------------------------------------------
                  Text(
                    "Welcome back 👋",
                    textAlign: TextAlign.center,
                    style: AppTheme.h1,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Sign in to continue your wellness journey",
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyMuted,
                  ),

                  const SizedBox(height: 36),

                  /// ------------------------------------------------------------
                  /// LOGIN FORM CARD
                  /// ------------------------------------------------------------
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: AppTheme.card,
                    child: const LoginForm(),
                  ),

                  const SizedBox(height: 28),

                  /// ------------------------------------------------------------
                  /// FOOTER ACTION
                  /// ------------------------------------------------------------
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SignUpPage(),
                        ),
                      );
                    },
                    child: Text(
                      "Don’t have an account? Sign up",
                      textAlign: TextAlign.center,
                      style: AppTheme.body.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
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
