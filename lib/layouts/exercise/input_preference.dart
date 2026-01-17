import 'package:flutter/material.dart';
import 'package:lumora/components/chip_group.dart';
import 'package:lumora/components/input_field.dart';
import 'package:lumora/components/primary_button.dart';
import 'package:lumora/layouts/exercise/exercise_preview_screen.dart';
import 'package:lumora/theme/app_theme.dart';

class InputPreference extends StatefulWidget {
  const InputPreference({super.key});

  @override
  State<InputPreference> createState() => _InputPreferenceState();
}

class _InputPreferenceState extends State<InputPreference> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text("Workout Preferences"),
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
                  Text(
                    "Tell us about your goals",
                    style: AppTheme.h1,
                  ),
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
                            'Lose fat',
                            'Build muscle',
                            'Improve endurance',
                            'Mobility & flexibility',
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
                            'None (bodyweight)',
                            'Resistance bands',
                            'Dumbbells',
                            'Kettlebells',
                            'Barbell + rack',
                            'Full gym',
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
                          label: "Generate workout with AI",
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Generating your plan…"),
                                duration: Duration(seconds: 1),
                              ),
                            );

                            await Future.delayed(
                              const Duration(milliseconds: 600),
                            );

                            if (!mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ExercisePreviewScreen(),
                              ),
                            );
                          },
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
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: Text(e),
            ),
          )
          .toList(),
      decoration: AppTheme.inputDecoration(hint),
      dropdownColor: AppTheme.cardBgAlt,
      style: AppTheme.body,
    );
  }
}
