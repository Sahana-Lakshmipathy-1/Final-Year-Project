import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/components/input_field.dart';
import 'package:lumora/components/survey/survey_stepper.dart';
import 'package:lumora/pages/user_preference.dart';

class SurveyPage extends StatefulWidget {
  const SurveyPage({super.key});

  @override
  State<SurveyPage> createState() => _SurveyPageState();
}

class _SurveyPageState extends State<SurveyPage> {
  final TextEditingController _nameController = TextEditingController();

  int _age = 25;
  int _weight = 70;
  int _height = 175;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updateValue(String field, int delta, int min, int max) {
    setState(() {
      switch (field) {
        case 'age':
          _age = (_age + delta).clamp(min, max);
          break;
        case 'weight':
          _weight = (_weight + delta).clamp(min, max);
          break;
        case 'height':
          _height = (_height + delta).clamp(min, max);
          break;
      }
    });
  }

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
                    "Let’s get to know you 👋",
                    style: AppTheme.h1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "This helps us personalize your plans and insights.",
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        /// NAME
                        InputField(
                          controller: _nameController,
                          labelText: "Your name",
                          hintText: "What should we call you?",
                        ),

                        const SizedBox(height: 28),

                        /// AGE
                        SurveyStepper(
                          label: "Age",
                          value: _age,
                          min: 10,
                          max: 100,
                          onChanged: (d) => _updateValue('age', d, 10, 100),
                        ),

                        const SizedBox(height: 24),

                        /// WEIGHT
                        SurveyStepper(
                          label: "Weight",
                          value: _weight,
                          unit: "kg",
                          min: 30,
                          max: 300,
                          onChanged: (d) => _updateValue('weight', d, 30, 300),
                        ),

                        const SizedBox(height: 24),

                        /// HEIGHT
                        SurveyStepper(
                          label: "Height",
                          value: _height,
                          unit: "cm",
                          min: 120,
                          max: 230,
                          onChanged: (d) => _updateValue('height', d, 120, 230),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// ------------------------------------------------------------
                  /// NAVIGATION ACTIONS
                  /// ------------------------------------------------------------
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: AppTheme.ghostButton,
                          child: const Text("Back"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: AppTheme.primaryButton,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const UserPreferencePage(),
                              ),
                            );
                          },
                          child: const Text(
                            "Continue",
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  /// SUBTLE TRUST NOTE
                  Text(
                    "You can update this anytime in settings.",
                    style: AppTheme.caption,
                    textAlign: TextAlign.center,
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
