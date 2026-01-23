import 'dart:async'; // Required for Timer/Delay
import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/services/api_service.dart';
import 'package:lumora/services/user_session.dart';

// Assuming you have this component, otherwise use ElevatedButton
import 'package:lumora/components/primary_button.dart';

class MealInputPreference extends StatefulWidget {
  const MealInputPreference({super.key});

  @override
  State<MealInputPreference> createState() => _MealInputPreferenceState();
}

class _MealInputPreferenceState extends State<MealInputPreference> {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  String _statusMessage = "Generate with AI"; // Dynamic button label

  // --- FORM STATE ---
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

  // --- 🚀 POLLING LOGIC ---
  Future<void> _generateMealPlan() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
      _statusMessage = "Chef is thinking...";
    });

    try {
      // 1. Prepare Payload
      final List<String> allergies = allergiesController.text.isNotEmpty
          ? allergiesController.text.split(',').map((e) => e.trim()).toList()
          : [];

      final payload = {
        "event_type": "generate_weekly_meal_plan",
        "user_id": UserSession.email, // ✅ From Session
        "primary_goal": selectedGoal?.toLowerCase().replaceAll(' ', '_'),
        "meals_per_day": int.tryParse(mealsPerDayController.text) ?? 3,
        "diet_type": selectedDiet?.toLowerCase().replaceAll(' ', '_'),
        "cuisine_preferences": [
          selectedCuisine?.toLowerCase().replaceAll(' ', '_') ?? "mixed",
        ],
        "allergies_foods_to_avoid": allergies,
        "cooking_effort": selectedEffort?.toLowerCase(),
        "personal_notes": contextController.text,
        // Optional: You can add calorie_target logic here if you add inputs for it
      };

      print("🚀 [1/3] Requesting Meal Plan: $payload");

      // 2. Initial Call (Get ID)
      final initResponse = await _api.generateWeeklyMealPlan(payload);

      if (!initResponse.containsKey('meal_routine_id')) {
        throw Exception("Server did not return a Meal Routine ID.");
      }

      final String routineId = initResponse['meal_routine_id'];
      print("✅ Meal Routine ID: $routineId");

      // 3. Start Polling Loop
      bool isComplete = false;
      int attempts = 0;
      const int maxAttempts = 12; // 60 seconds max

      while (!isComplete && attempts < maxAttempts) {
        attempts++;
        if (mounted) {
          setState(() => _statusMessage = "Planning meals... ($attempts)");
        }

        // Wait 5 seconds
        await Future.delayed(const Duration(seconds: 5));

        // Check Status
        print("🔄 [2/3] Polling status... (Attempt $attempts)");
        final statusResponse = await _api.checkMealPlanStatus(
          UserSession.email!,
          routineId,
        );

        final String status = statusResponse['status'] ?? "UNKNOWN";
        print("   Status: $status");

        if (status == "COMPLETED") {
          isComplete = true;
          print("✅ [3/3] Generation Complete!");

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Meal Plan Ready!")),
            );
            Navigator.pop(
              context,
            ); // Return to previous screen to refresh/show plan
          }
        } else if (status == "FAILED") {
          throw Exception("AI Generation Failed on Server.");
        }
      }

      if (!isComplete) {
        throw Exception("Timeout: AI took too long.");
      }
    } catch (e) {
      print("❌ Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${e.toString().replaceAll('Exception: ', '')}",
            ),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _statusMessage = "Generate with AI";
        });
      }
    }
  }

  bool _validateForm() {
    if (selectedGoal == null ||
        selectedDiet == null ||
        mealsPerDayController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in Goal, Diet, and Meals per day."),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text("Meal Preferences"),
        backgroundColor: AppTheme.bg,
        elevation: 0,
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
                            "Keto",
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
                            "Mediterranean",
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
                            "Anything we should know? (e.g. Prefer quick breakfast)",
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
                          child: PrimaryButton(
                            label: _statusMessage,
                            isLoading: _isLoading,
                            onPressed: _generateMealPlan,
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
      labelText: label, // Optional, can remove if redundant with header
      hintText: hint,
      filled: true,
      fillColor: AppTheme.cardBgAlt,
      border: OutlineInputBorder(
        borderRadius: AppTheme.radiusMedium,
      ),
    );
  }
}
