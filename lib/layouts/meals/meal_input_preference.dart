import 'package:flutter/material.dart';
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
  String? selectedDifficulty;

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
    const bg = Color(0xFF0F1431);
    const card = Color(0xFF181C3A);
    const field = Color(0xFF14183A);
    const accent = Color(0xFFB787FF);
    const text = Color(0xFFE9ECFF);
    const muted = Color(0xFFB7C0E0);
    const edge = Color(0xFF2C315C);

    return Scaffold(
      backgroundColor: bg,
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
                  const Text(
                    'Tell us about your meals ✨',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: text,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Share your dietary goals and preferences so the assistant can tailor a meal plan.',
                    style: TextStyle(color: muted),
                  ),
                  const SizedBox(height: 18),

                  /// FORM CARD
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: edge),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// PRIMARY GOAL
                        _dropdown(
                          label: 'Primary goal',
                          value: selectedGoal,
                          hint: 'Select a goal…',
                          items: const [
                            'Fat loss',
                            'Muscle gain',
                            'Maintenance',
                            'Healthy eating',
                          ],
                          onChanged: (v) => setState(() => selectedGoal = v),
                        ),

                        const SizedBox(height: 14),

                        /// MEALS PER DAY
                        TextFormField(
                          controller: mealsPerDayController,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: text),
                          decoration: _dec(
                            'Meals per day',
                            'e.g. 3',
                            field,
                          ),
                        ),

                        const SizedBox(height: 14),

                        /// DIET TYPE
                        _dropdown(
                          label: 'Diet type',
                          value: selectedDiet,
                          hint: 'Select diet…',
                          items: const [
                            'Vegetarian',
                            'Non-vegetarian',
                            'Vegan',
                            'Eggetarian',
                          ],
                          onChanged: (v) => setState(() => selectedDiet = v),
                        ),

                        const SizedBox(height: 14),

                        /// CUISINE
                        _dropdown(
                          label: 'Cuisine preference',
                          value: selectedCuisine,
                          hint: 'Select cuisine…',
                          items: const [
                            'Indian',
                            'South Indian',
                            'North Indian',
                            'Continental',
                            'Mixed',
                          ],
                          onChanged: (v) => setState(() => selectedCuisine = v),
                        ),

                        const SizedBox(height: 14),

                        /// ALLERGIES
                        TextFormField(
                          controller: allergiesController,
                          style: const TextStyle(color: text),
                          decoration: _dec(
                            'Allergies / foods to avoid',
                            'e.g. peanuts, dairy',
                            field,
                          ),
                        ),

                        const SizedBox(height: 14),

                        /// DIFFICULTY
                        _dropdown(
                          label: 'Cooking effort',
                          value: selectedDifficulty,
                          hint: 'Choose level…',
                          items: const [
                            'Easy',
                            'Moderate',
                            'Advanced',
                          ],
                          onChanged: (v) =>
                              setState(() => selectedDifficulty = v),
                        ),

                        const SizedBox(height: 14),

                        /// PERSONALIZATION
                        TextFormField(
                          controller: contextController,
                          minLines: 5,
                          maxLines: 10,
                          style: const TextStyle(color: text),
                          decoration: _dec(
                            'Personalize your meal plan',
                            'Anything the assistant should know…',
                            field,
                          ),
                        ),

                        const SizedBox(height: 6),
                        const Text(
                          'Avoid sensitive medical details. Share only what’s needed.',
                          style: TextStyle(color: muted, fontSize: 12),
                        ),

                        const SizedBox(height: 22),

                        /// GENERATE BUTTON (NOW WIRED)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const MealPreviewScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Generate with AI',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1A1034),
                              ),
                            ),
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

  /// ---------- helpers ----------

  Widget _dropdown({
    required String label,
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    const field = Color(0xFF14183A);
    const text = Color(0xFFE9ECFF);
    const muted = Color(0xFFB7C0E0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, color: text),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          dropdownColor: field,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: field,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          style: const TextStyle(color: text),
        ),
        const SizedBox(height: 2),
        const Text(
          'This helps tailor the meal structure.',
          style: TextStyle(color: muted, fontSize: 12),
        ),
      ],
    );
  }

  InputDecoration _dec(String label, String hint, Color field) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: field,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
