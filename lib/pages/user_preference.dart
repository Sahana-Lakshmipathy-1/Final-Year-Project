import 'package:flutter/material.dart';
import 'package:lumora/components/chip_group.dart';
import 'package:lumora/components/input_field.dart';
import "package:lumora/pages/home.dart";

class UserPreferencePage extends StatefulWidget {
  const UserPreferencePage({super.key});

  @override
  State<UserPreferencePage> createState() => _UserPreferencePageState();
}

class _UserPreferencePageState extends State<UserPreferencePage> {
  final TextEditingController _healthController = TextEditingController();

  // Fitness goals
  final List<String> fitnessGoals = [
    "Lose Weight",
    "Build Muscle",
    "Improve Endurance",
    "Stay Active",
  ];
  final Set<String> selectedFitnessGoals = {};

  // Nutritional goals
  final List<String> nutritionalGoals = [
    "High Protein",
    "Low Carb",
    "Vegan",
    "Balanced Diet",
  ];
  final Set<String> selectedNutritionGoals = {};

  @override
  void dispose() {
    _healthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF1a1a40);
    const chipSelectedBg = Color(0xFF48E6E4);
    const chipSelectedText = Color(0xFF211D3B);
    const cardColor = Color(0xFF232e40);
    const labelColor = Color(0xFFeeeafd);
    const chipUnselectedText = Color(0xFFE9EBF6);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Health & Goals",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: labelColor,
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Health conditions input using InputField
                  InputField(
                    controller: _healthController,
                    hintText: "e.g: diabetes, asthma or None",
                    labelText: "Any existing health conditions?",
                    // optional: prefixIcon: Icons.health_and_safety,
                  ),
                  const SizedBox(height: 24),

                  // Fitness goals
                  const Text(
                    "What are your fitness goals?",
                    style: TextStyle(fontSize: 18, color: labelColor),
                  ),
                  const SizedBox(height: 8),
                  ChipGroup(
                    options: fitnessGoals,
                    selectedValues: selectedFitnessGoals,
                    selectedBg: chipSelectedBg,
                    selectedText: chipSelectedText,
                    unselectedBg: cardColor,
                    unselectedText: chipUnselectedText,
                    onSelectionChanged: (goal, isNowSelected) {
                      setState(() {
                        if (isNowSelected) {
                          selectedFitnessGoals.add(goal);
                        } else {
                          selectedFitnessGoals.remove(goal);
                        }
                      });
                    },
                  ),

                  // Nutritional goals
                  const SizedBox(height: 24),
                  const Text(
                    "Any nutritional goals? (Optional)",
                    style: TextStyle(fontSize: 18, color: labelColor),
                  ),
                  const SizedBox(height: 8),
                  ChipGroup(
                    options: nutritionalGoals,
                    selectedValues: selectedNutritionGoals,
                    selectedBg: chipSelectedBg,
                    selectedText: chipSelectedText,
                    unselectedBg: cardColor,
                    unselectedText: chipUnselectedText,
                    onSelectionChanged: (goal, isNowSelected) {
                      setState(() {
                        if (isNowSelected) {
                          selectedNutritionGoals.add(goal);
                        } else {
                          selectedNutritionGoals.remove(goal);
                        }
                      });
                    },
                  ),

                  // Actions
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: cardColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: const Text("Back"),
                      ),
                      OutlinedButton(
                        onPressed: () {
                          // (Optional) You can still log the values or send them to backend here
                          print("Health: ${_healthController.text}");
                          print("Fitness: ${selectedFitnessGoals.join(', ')}");
                          print(
                            "Nutrition: ${selectedNutritionGoals.join(', ')}",
                          );

                          // Navigate to HomeScreen and replace the current screen
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const HomeScreen(), // import from home.dart
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: chipSelectedBg,
                          foregroundColor: Colors.black,
                          side: const BorderSide(color: Colors.white, width: 3),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                        child: const Text(
                          "Finish",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
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
