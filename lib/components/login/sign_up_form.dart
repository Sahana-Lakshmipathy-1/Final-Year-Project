import 'package:flutter/material.dart';
import 'package:lumora/components/primary_button.dart';
import 'package:lumora/components/input_field.dart'; // <-- import your custom InputField
import 'package:lumora/pages/survey.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() {
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
            controller: _nameController,
            hintText: "Enter your full name",
            labelText: "Full Name",
            prefixIcon: Icons.person,
            // validator: (value) {
            //   if (value == null || value.isEmpty) return "Please enter your name";
            //   return null;
            // },
          ),
          const SizedBox(height: 16),
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
            //   if (value == null || value.isEmpty) return "Please enter a password";
            //   if (value.length < 6) return "Password must be at least 6 characters";
            //   return null;
            // },
          ),
          const SizedBox(height: 16),
          InputField(
            controller: _confirmPasswordController,
            hintText: "Confirm your password",
            labelText: "Confirm Password",
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            // validator: (value) {
            //   if (value == null || value.isEmpty) return "Please confirm your password";
            //   if (value != _passwordController.text) return "Passwords do not match";
            //   return null;
            // },
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            label: "Sign Up",
            onPressed: _handleSignup,
          ),
        ],
      ),
    );
  }
}
