import 'package:flutter/material.dart';
import 'package:lumora/components/primary_button.dart';
import 'package:lumora/components/input_field.dart'; // <-- import your custom InputField
import 'package:lumora/pages/survey.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // 🔒 Validation disabled for now
    // if (_formKey.currentState!.validate()) { ... }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SurveyPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InputField(
            controller: _emailController,
            hintText: "Enter your email",
            labelText: "Email",
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            // validator: (value) {
            //   if (value == null || value.isEmpty) return "Please enter your email";
            //   if (!value.contains("@")) return "Enter a valid email";
            //   return null;
            // },
          ),
          const SizedBox(height: 16),
          InputField(
            controller: _passwordController,
            hintText: "Enter your password",
            labelText: "Password",
            prefixIcon: Icons.lock,
            obscureText: true,
            // validator: (value) {
            //   if (value == null || value.isEmpty) return "Please enter your password";
            //   if (value.length < 6) return "Password must be at least 6 characters";
            //   return null;
            // },
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: "Login",
            onPressed: _handleLogin,
          ),
        ],
      ),
    );
  }
}
