import 'package:flutter/material.dart';
import 'package:lumora/components/input_field.dart';
import 'package:lumora/components/primary_button.dart';
import 'package:lumora/pages/survey.dart';
import 'package:lumora/theme/app_theme.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
    // 1. Validate Inputs
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    // 2. Navigate to Step 2 (SurveyPage)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SurveyPage(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ CRITICAL FIX: Wrap everything in a transparent Material widget.
    // This gives the TextFields a "surface" to draw on during animations,
    // preventing the "No Material widget found" crash.
    return Material(
      type: MaterialType.transparency,
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /// FULL NAME
            InputField(
              controller: _nameController,
              labelText: "Full Name",
              hintText: "Enter your full name",
              prefixIcon: Icons.person_outline,
            ),

            const SizedBox(height: 16),

            /// EMAIL
            InputField(
              controller: _emailController,
              labelText: "Email",
              hintText: "Enter your email",
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            /// PASSWORD
            InputField(
              controller: _passwordController,
              labelText: "Password",
              hintText: "Enter your password",
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),

            const SizedBox(height: 16),

            /// CONFIRM PASSWORD
            InputField(
              controller: _confirmPasswordController,
              labelText: "Confirm Password",
              hintText: "Re-enter your password",
              prefixIcon: Icons.lock_outline,
              obscureText: true,
            ),

            const SizedBox(height: 28),

            /// BUTTON
            PrimaryButton(
              label: "Continue",
              isLoading: _isLoading,
              onPressed: _handleSignup,
            ),

            const SizedBox(height: 16),

            /// FOOTER TEXT
            Text(
              "By signing up, you agree to our Terms & Privacy Policy",
              style: AppTheme.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
