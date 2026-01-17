import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/layouts/meals/meal_preview_screen.dart';

class MealInputPreference extends StatefulWidget {
  const MealInputPreference({super.key});

  @override
  State<MealInputPreference> createState() => _MealInputPreferenceState();
}

class _MealInputPreferenceState extends State<MealInputPreference> {
  String? selectedGoal;
  String? selectedDiet;
  String? selectedCuisine;
  String? selectedEffort;

  final mealsPerDayController = TextEditingController();
  final allergiesController = TextEditingController();
  final contextController = TextEditingController();

  @override
  void dispose() {
    mealsPerDayController.dispose();
    allergiesController.dispose();
    contextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text("Meal Preferences"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Text(
                    "Tell us about your meals ✨",
                    style: AppTheme.h1,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Your preferences help us plan meals that fit your goals and lifestyle.",
                    style: AppTheme.bodyMuted,
                  ),
                  const SizedBox(height: 24),

                  /// FORM CARD
                  Container(
                    decoration: AppTheme.elevatedCard,
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _dropdown(
                          label: "Primary goal",
                          hint: "Select your goal",
                          value: selectedGoal,
                          items: const [
                            "Fat loss",
                            "Muscle gain",
                            "Maintenance",
                            "Healthy eating",
                          ],
                          onChanged: (v) => setState(() => selectedGoal = v),
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: mealsPerDayController,
                          keyboardType: TextInputType.number,
                          style: AppTheme.body,
                          decoration: _inputDecoration(
                            "Meals per day",
                            "e.g. 3",
                          ),
                        ),

                        const SizedBox(height: 14),

                        _dropdown(
                          label: "Diet type",
                          hint: "Choose diet",
                          value: selectedDiet,
                          items: const [
                            "Vegetarian",
                            "Non-vegetarian",
                            "Vegan",
                            "Eggetarian",
                          ],
                          onChanged: (v) => setState(() => selectedDiet = v),
                        ),

                        const SizedBox(height: 14),

                        _dropdown(
                          label: "Cuisine preference",
                          hint: "Select cuisine",
                          value: selectedCuisine,
                          items: const [
                            "Indian",
                            "South Indian",
                            "North Indian",
                            "Continental",
                            "Mixed",
                          ],
                          onChanged: (v) => setState(() => selectedCuisine = v),
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: allergiesController,
                          style: AppTheme.body,
                          decoration: _inputDecoration(
                            "Allergies / foods to avoid",
                            "e.g. peanuts, dairy",
                          ),
                        ),

                        const SizedBox(height: 14),

                        _dropdown(
                          label: "Cooking effort",
                          hint: "Choose effort level",
                          value: selectedEffort,
                          items: const [
                            "Easy",
                            "Moderate",
                            "Advanced",
                          ],
                          onChanged: (v) => setState(() => selectedEffort = v),
                        ),

                        const SizedBox(height: 14),

                        TextFormField(
                          controller: contextController,
                          minLines: 5,
                          maxLines: 10,
                          style: AppTheme.body,
                          decoration: _inputDecoration(
                            "Personalize your meal plan",
                            "Anything we should know?",
                          ),
                        ),

                        const SizedBox(height: 8),
                        Text(
                          "Avoid sensitive medical details.",
                          style: AppTheme.caption,
                        ),

                        const SizedBox(height: 24),

                        /// CTA
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: AppTheme.primaryButton,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const MealPreviewScreen(),
                                ),
                              );
                            },
                            child: const Text("Generate with AI"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// ───────── HELPERS ─────────

  Widget _dropdown({
    required String label,
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTheme.body.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map(
                (e) => DropdownMenuItem(
                  value: e,
                  child: Text(e),
                ),
              )
              .toList(),
          onChanged: onChanged,
          dropdownColor: AppTheme.cardBgAlt,
          decoration: _inputDecoration(label, hint),
          style: AppTheme.body,
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: AppTheme.cardBgAlt,
      border: OutlineInputBorder(
        borderRadius: AppTheme.radiusMedium,
      ),
    );
  }
}
