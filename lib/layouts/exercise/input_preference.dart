import 'package:flutter/material.dart';
import 'package:lumora/layouts/exercise/exercise_preview_screen.dart';

class InputPreference extends StatefulWidget {
  const InputPreference({super.key});

  @override
  State<InputPreference> createState() => _InputPreferenceState();
}

class _InputPreferenceState extends State<InputPreference> {
  // Dropdown values
  String? selectedGoal;
  String? selectedEquipment;
  String? selectedDifficulty;

  // Time availability
  final daysController = TextEditingController();
  final minutesController = TextEditingController();

  // Context text
  final contextController = TextEditingController();

  // Chips for preferred days
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
    const bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF23275F), Color(0xFF181B40)],
    );
    const fieldColor = Color(0xFF14183A);
    const textColor = Color(0xFFE9ECFF);
    const accent = Color(0xFFB787FF);
    const muted = Color(0xFFB7C0E0);
    const chipColor = Color(0xFF262B56);
    const edgeColor = Color(0xFF2C315C);

    return Scaffold(
      backgroundColor: const Color(0xFF0F1431),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🧭 Form Header
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tell us about your goals ✨',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Share a bit about the target, schedule, and equipment so the assistant can tailor a plan.',
                          style: TextStyle(color: muted),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 🌈 Form Shell
                  Container(
                    decoration: BoxDecoration(
                      gradient: bgGradient,
                      border: Border.all(color: edgeColor),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🎯 Primary Goal
                        _buildDropdownField(
                          label: 'Primary goal',
                          value: selectedGoal,
                          items: [
                            'Lose fat',
                            'Build muscle',
                            'Improve endurance',
                            'Mobility & flexibility',
                            'General fitness',
                          ],
                          hint: 'Select a goal…',
                          onChanged: (val) =>
                              setState(() => selectedGoal = val),
                        ),
                        const SizedBox(height: 14),

                        // ⏰ Time Availability
                        const Text(
                          'Time availability',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: Color(0xFFD5DBFF),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: daysController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: textColor),
                                decoration: const InputDecoration(
                                  labelText: 'Days per week',
                                  hintText: 'e.g., 4',
                                  filled: true,
                                  fillColor: fieldColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: minutesController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: textColor),
                                decoration: const InputDecoration(
                                  labelText: 'Minutes per session',
                                  hintText: 'e.g., 45',
                                  filled: true,
                                  fillColor: fieldColor,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // 📅 Preferred Days
                        Wrap(
                          spacing: 8,
                          children: days.map((day) {
                            final isSelected = selectedDays.contains(day);
                            return ChoiceChip(
                              label: Text(day),
                              selected: isSelected,
                              selectedColor: accent.withOpacity(0.2),
                              backgroundColor: chipColor,
                              labelStyle: TextStyle(
                                color: isSelected ? accent : textColor,
                                fontWeight: FontWeight.w700,
                              ),
                              onSelected: (_) {
                                setState(() {
                                  if (isSelected) {
                                    selectedDays.remove(day);
                                  } else {
                                    selectedDays.add(day);
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),

                        // 🏋️ Equipment
                        _buildDropdownField(
                          label: 'Available equipment',
                          value: selectedEquipment,
                          items: [
                            'None (bodyweight)',
                            'Resistance bands',
                            'Dumbbells',
                            'Kettlebells',
                            'Barbell + rack',
                            'Full gym',
                          ],
                          hint: 'Select equipment…',
                          onChanged: (val) =>
                              setState(() => selectedEquipment = val),
                        ),
                        const SizedBox(height: 14),

                        // 📊 Difficulty
                        _buildDropdownField(
                          label: 'Difficulty',
                          value: selectedDifficulty,
                          items: ['Beginner', 'Intermediate', 'Advanced'],
                          hint: 'Choose level…',
                          onChanged: (val) =>
                              setState(() => selectedDifficulty = val),
                        ),
                        const SizedBox(height: 14),

                        // 🧍 Personalization
                        TextFormField(
                          controller: contextController,
                          minLines: 6,
                          maxLines: 12,
                          style: const TextStyle(color: textColor),
                          decoration: const InputDecoration(
                            labelText: 'Personalize your plan',
                            hintText:
                                'We’d love to get to know you! Share a bit about yourself…',
                            filled: true,
                            fillColor: fieldColor,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'This helps the assistant make safer, more personal choices. Avoid sensitive medical details; share only what’s needed.',
                          style: TextStyle(color: muted, fontSize: 12),
                        ),
                        const SizedBox(height: 22),

                        // 🚀 Single Action Button (AI Generation)
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
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Generating with AI…'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                              Future.delayed(
                                const Duration(milliseconds: 600),
                                () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ExercisePreviewScreen(),
                                    ),
                                  );
                                },
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    const fieldColor = Color(0xFF14183A);
    const textColor = Color(0xFFE9ECFF);
    const muted = Color(0xFFB7C0E0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700, color: textColor),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: fieldColor,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            hintText: hint,
          ),
          dropdownColor: fieldColor,
          style: const TextStyle(color: textColor),
        ),
        const SizedBox(height: 2),
        Text(
          'This sets overall structure and progression.',
          style: const TextStyle(color: muted, fontSize: 12),
        ),
      ],
    );
  }
}
