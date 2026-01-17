import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/components/chip_group.dart';
import 'package:lumora/components/input_field.dart';
import 'package:lumora/pages/home.dart';

class UserPreferencePage extends StatefulWidget {
  const UserPreferencePage({super.key});

  @override
  State<UserPreferencePage> createState() => _UserPreferencePageState();
}

class _UserPreferencePageState extends State<UserPreferencePage> {
  final TextEditingController _healthController = TextEditingController();

  final List<String> fitnessGoals = [
    "Lose Weight",
    "Build Muscle",
    "Improve Endurance",
    "Stay Active",
  ];

  final List<String> nutritionGoals = [
    "High Protein",
    "Low Carb",
    "Vegan",
    "Balanced Diet",
  ];

  final Set<String> selectedFitnessGoals = {};
  final Set<String> selectedNutritionGoals = {};

  @override
  void dispose() {
    _healthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 36),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// ------------------------------------------------------------
                  /// HEADER
                  /// ------------------------------------------------------------
                  Text("Your preferences", style: AppTheme.h1),
                  const SizedBox(height: 6),
                  Text(
                    "Help us personalize your experience.",
                    style: AppTheme.bodyMuted,
                  ),

                  const SizedBox(height: 32),

                  /// ------------------------------------------------------------
                  /// HEALTH CONTEXT
                  /// ------------------------------------------------------------
                  Text("Health considerations", style: AppTheme.sectionTitle),
                  const SizedBox(height: 8),

                  InputField(
                    controller: _healthController,
                    labelText: "Existing conditions (optional)",
                    hintText: "e.g. asthma, diabetes, none",
                  ),

                  const SizedBox(height: 36),

                  /// ------------------------------------------------------------
                  /// FITNESS GOALS
                  /// ------------------------------------------------------------
                  Text("Fitness goals", style: AppTheme.sectionTitle),
                  const SizedBox(height: 6),
                  Text(
                    "What would you like to focus on?",
                    style: AppTheme.caption,
                  ),
                  const SizedBox(height: 14),

                  ChipGroup(
                    options: fitnessGoals,
                    selectedValues: selectedFitnessGoals,
                    onSelectionChanged: (goal, selected) {
                      setState(() {
                        selected
                            ? selectedFitnessGoals.add(goal)
                            : selectedFitnessGoals.remove(goal);
                      });
                    },
                  ),

                  const SizedBox(height: 36),

                  /// ------------------------------------------------------------
                  /// NUTRITION GOALS
                  /// ------------------------------------------------------------
                  Text("Nutrition preferences", style: AppTheme.sectionTitle),
                  const SizedBox(height: 6),
                  Text(
                    "Optional, but helps with meal planning.",
                    style: AppTheme.caption,
                  ),
                  const SizedBox(height: 14),

                  ChipGroup(
                    options: nutritionGoals,
                    selectedValues: selectedNutritionGoals,
                    onSelectionChanged: (goal, selected) {
                      setState(() {
                        selected
                            ? selectedNutritionGoals.add(goal)
                            : selectedNutritionGoals.remove(goal);
                      });
                    },
                  ),

                  const SizedBox(height: 44),

                  /// ------------------------------------------------------------
                  /// ACTIONS
                  /// ------------------------------------------------------------
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: AppTheme.ghostButton,
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Back"),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          style: AppTheme.primaryButton,
                          onPressed: _finishSetup,
                          child: const Text("Finish setup"),
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

  void _finishSetup() {
    debugPrint("Health: ${_healthController.text}");
    debugPrint("Fitness goals: $selectedFitnessGoals");
    debugPrint("Nutrition goals: $selectedNutritionGoals");

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }
}
