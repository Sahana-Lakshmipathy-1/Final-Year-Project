import 'package:flutter/material.dart';
import 'package:lumora/components/input_field.dart';
import 'package:lumora/components/primary_button.dart';
import 'package:lumora/services/api_service.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/main_screen.dart'; // ✅ Import MainScreen

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ApiService _api = ApiService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      print("🚀 Logging in...");

      // 1. Call API
      final response = await _api.logIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      print("✅ Login Success: $response");

      // 2. Extract Name from API Response
      // If the API doesn't return a name, we default to "User" or the email
      String userName = response['name'] ?? "User";

      // Fallback: If name is null/empty, try using the part before '@' in email
      if (userName == "User") {
        userName = _emailController.text.split('@')[0];
      }

      if (mounted) {
        // 3. Pass the name to MainScreen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(userName: userName), // ✅ PASSED HERE
          ),
          (route) => false,
        );
      }
    } catch (e) {
      print("❌ Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Login Failed: ${e.toString().replaceAll('Exception: ', '')}",
            ),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InputField(
          controller: _emailController,
          labelText: "Email",
          hintText: "Enter your email",
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        InputField(
          controller: _passwordController,
          labelText: "Password",
          hintText: "Enter your password",
          prefixIcon: Icons.lock_outline,
          obscureText: true,
        ),
        const SizedBox(height: 12),

        // Forgot Password Link
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "Forgot Password?",
            style: AppTheme.caption.copyWith(color: AppTheme.primary),
          ),
        ),

        const SizedBox(height: 28),

        PrimaryButton(
          label: "Log In",
          isLoading: _isLoading,
          onPressed: _handleLogin,
        ),
      ],
    );
  }
}
