import 'package:flutter/material.dart';
import 'package:lumora/components/primary_button.dart';
import 'package:lumora/components/input_field.dart';
import 'package:lumora/pages/survey.dart';
import 'package:lumora/theme/app_theme.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // 🔒 Validation can be enabled later
    // if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Simulate login / replace with real auth later
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

          const SizedBox(height: 28),

          /// LOGIN BUTTON
          PrimaryButton(
            label: "Login",
            isLoading: _isLoading,
            onPressed: _handleLogin,
          ),

          const SizedBox(height: 16),

          /// FOOTER (optional / future)
          Text(
            "By continuing, you agree to our Terms & Privacy Policy",
            style: AppTheme.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
