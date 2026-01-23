import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/services/api_service.dart';
import 'package:lumora/services/user_session.dart';

// ✅ Custom Components
import 'package:lumora/components/chip_group.dart';
import 'package:lumora/components/input_field.dart';
import 'package:lumora/components/primary_button.dart';

class InputPreference extends StatefulWidget {
  const InputPreference({super.key});

  @override
  State<InputPreference> createState() => _InputPreferenceState();
}

class _InputPreferenceState extends State<InputPreference> {
  final ApiService _api = ApiService();
  bool _isLoading = false;
  String _statusMessage = "Generate workout with AI";

  // --- FORM STATE ---
  String? selectedGoal;
  String? selectedEquipment;
  String? selectedDifficulty;

  final daysController = TextEditingController();
  final minutesController = TextEditingController();
  final contextController = TextEditingController();

  final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final Set<String> selectedDays = {};

  @override
  void dispose() {
    daysController.dispose();
    minutesController.dispose();
    contextController.dispose();
    super.dispose();
  }

  // --- 🚀 POLLING LOGIC ---
  Future<void> _generateRoutine() async {
    if (!_validateForm()) return;

    setState(() {
      _isLoading = true;
      _statusMessage = "Starting AI engine...";
    });

    try {
      // 1. Prepare Request
      final fullDayNames = _mapDaysToFullNames();
      final payload = {
        "event_type": "generate_weekly_routine",
        "user_id": UserSession.email,
        "primary_goal": selectedGoal!.toLowerCase().replaceAll(' ', '_'),
        "time_availability": {
          "days_per_week": int.tryParse(daysController.text) ?? 3,
          "minutes_per_session": int.tryParse(minutesController.text) ?? 45,
        },
        "preferred_training_days": fullDayNames,
        "available_equipment": [
          selectedEquipment!.toLowerCase().replaceAll(' ', '_'),
        ],
        "difficulty_level": selectedDifficulty!.toLowerCase(),
        "personal_notes": contextController.text,
      };

      print("🚀 [1/3] Requesting Generation...");

      // 2. Initial Call (Gets Routine ID)
      final initResponse = await _api.generateWeeklyRoutine(payload);

      if (!initResponse.containsKey('routine_id')) {
        throw Exception("Server did not return a Routine ID.");
      }

      final String routineId = initResponse['routine_id'];
      print("✅ Routine ID Received: $routineId");

      // 3. Start Polling Loop
      bool isComplete = false;
      int attempts = 0;
      const int maxAttempts = 12; // 60 seconds max

      while (!isComplete && attempts < maxAttempts) {
        attempts++;
        if (mounted) {
          setState(() => _statusMessage = "AI is thinking... ($attempts)");
        }

        // Wait 5 seconds
        await Future.delayed(const Duration(seconds: 5));

        // Check Status
        print("🔄 [2/3] Polling status... (Attempt $attempts)");
        final statusResponse = await _api.checkRoutineStatus(
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
              const SnackBar(content: Text("Routine Ready!")),
            );
            Navigator.pop(context);
          }
        } else if (status == "FAILED") {
          throw Exception("AI Generation Failed on Server.");
        }
      }

      if (!isComplete) {
        throw Exception("Timeout: AI took too long to respond.");
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
          _statusMessage = "Generate workout with AI";
        });
      }
    }
  }

  bool _validateForm() {
    if (selectedGoal == null ||
        selectedEquipment == null ||
        selectedDifficulty == null ||
        daysController.text.isEmpty ||
        minutesController.text.isEmpty ||
        selectedDays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields.")),
      );
      return false;
    }
    return true;
  }

  List<String> _mapDaysToFullNames() {
    return selectedDays.map((d) {
      switch (d) {
        case 'Mon':
          return 'monday';
        case 'Tue':
          return 'tuesday';
        case 'Wed':
          return 'wednesday';
        case 'Thu':
          return 'thursday';
        case 'Fri':
          return 'friday';
        case 'Sat':
          return 'saturday';
        case 'Sun':
          return 'sunday';
        default:
          return d.toLowerCase();
      }
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text("Workout Preferences"),
        backgroundColor: AppTheme.bg,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// HEADER
                  Text("Tell us about your goals", style: AppTheme.h1),
                  const SizedBox(height: 6),
                  Text(
                    "Answer a few quick questions so the AI can design a plan that fits your lifestyle.",
                    style: AppTheme.bodyMuted,
                  ),

                  const SizedBox(height: 24),

                  /// FORM CARD
                  Container(
                    decoration: AppTheme.elevatedCard,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// GOAL
                        _sectionTitle("Primary goal"),
                        _dropdown(
                          value: selectedGoal,
                          hint: "Choose your main goal",
                          items: const [
                            'Weight loss',
                            'Muscle gain',
                            'Endurance',
                            'Flexibility',
                            'General fitness',
                          ],
                          onChanged: (v) => setState(() => selectedGoal = v),
                        ),

                        const SizedBox(height: 20),

                        /// TIME
                        _sectionTitle("Time availability"),
                        Row(
                          children: [
                            Expanded(
                              child: InputField(
                                controller: daysController,
                                labelText: "Days / week",
                                hintText: "e.g. 4",
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: InputField(
                                controller: minutesController,
                                labelText: "Minutes / session",
                                hintText: "e.g. 45",
                                keyboardType: TextInputType.number,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        /// DAYS
                        Text(
                          "Preferred training days",
                          style: AppTheme.caption,
                        ),
                        const SizedBox(height: 8),
                        ChipGroup(
                          options: days,
                          selectedValues: selectedDays,
                          onSelectionChanged: (day, selected) {
                            setState(() {
                              selected
                                  ? selectedDays.add(day)
                                  : selectedDays.remove(day);
                            });
                          },
                        ),

                        const SizedBox(height: 24),

                        /// EQUIPMENT
                        _sectionTitle("Available equipment"),
                        _dropdown(
                          value: selectedEquipment,
                          hint: "Select equipment you have",
                          items: const [
                            'Bodyweight',
                            'Resistance bands',
                            'Dumbbells',
                            'Gym',
                          ],
                          onChanged: (v) =>
                              setState(() => selectedEquipment = v),
                        ),

                        const SizedBox(height: 20),

                        /// DIFFICULTY
                        _sectionTitle("Difficulty level"),
                        _dropdown(
                          value: selectedDifficulty,
                          hint: "Choose difficulty",
                          items: const [
                            'Beginner',
                            'Intermediate',
                            'Advanced',
                          ],
                          onChanged: (v) =>
                              setState(() => selectedDifficulty = v),
                        ),

                        const SizedBox(height: 20),

                        /// CONTEXT
                        _sectionTitle("Personal notes (optional)"),
                        Text(
                          "Anything we should know? Injuries, preferences, or constraints.",
                          style: AppTheme.caption,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: contextController,
                          minLines: 4,
                          maxLines: 8,
                          style: AppTheme.body,
                          decoration: AppTheme.inputDecoration(
                            "Tell us more (optional)",
                          ),
                        ),

                        const SizedBox(height: 28),

                        /// CTA
                        PrimaryButton(
                          label: _statusMessage,
                          isLoading: _isLoading,
                          onPressed: _generateRoutine,
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

  /// ---------- HELPERS ----------

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(text, style: AppTheme.h2),
    );
  }

  Widget _dropdown({
    required String? value,
    required String hint,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      decoration: AppTheme.inputDecoration(hint),
      dropdownColor: AppTheme.cardBgAlt,
      style: AppTheme.body,
    );
  }
}
