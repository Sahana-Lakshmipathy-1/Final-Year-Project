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
    // 🔒 Enable validation later
    // if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 600), () {
      if (!mounted) return;

      setState(() => _isLoading = false);

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SurveyPage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
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

          /// SIGN UP BUTTON
          PrimaryButton(
            label: "Create Account",
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
    );
  }
}
