import 'package:flutter/material.dart';
import 'package:lumora/components/input_field.dart';
import 'package:lumora/pages/user_preference.dart';
import 'package:lumora/components/survey/survey_stepper.dart';

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
      if (field == "age") _age = (_age + delta).clamp(min, max);
      if (field == "weight") _weight = (_weight + delta).clamp(min, max);
      if (field == "height") _height = (_height + delta).clamp(min, max);
    });
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF1a1a40);
    const titleColor = Color(0xFFeeeafd);
    const primary = Color(0xFFb087f6);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  const Text(
                    "Tell us about yourself",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Name field using InputField
                  InputField(
                    controller: _nameController,
                    hintText: "What's your name?",
                    labelText: "Name",
                    // optional: prefixIcon: Icons.person,
                  ),
                  const SizedBox(height: 24),

                  // Survey steppers
                  SurveyStepper(
                    label: "Age",
                    value: _age,
                    min: 0,
                    max: 120,
                    onChanged: (delta) => _updateValue("age", delta, 0, 120),
                  ),
                  const SizedBox(height: 24),
                  SurveyStepper(
                    label: "Weight",
                    value: _weight,
                    unit: "kg",
                    min: 1,
                    max: 300,
                    onChanged: (delta) => _updateValue("weight", delta, 1, 300),
                  ),
                  const SizedBox(height: 24),
                  SurveyStepper(
                    label: "Height",
                    value: _height,
                    unit: "cm",
                    min: 50,
                    max: 250,
                    onChanged: (delta) =>
                        _updateValue("height", delta, 50, 250),
                  ),
                  const SizedBox(height: 40),

                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF232340),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Back",
                          style: TextStyle(fontSize: 17),
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const UserPreferencePage(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Next",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
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
