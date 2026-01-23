import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/services/api_service.dart';
import 'package:lumora/services/user_session.dart';

class ManualRoutineSetupScreen extends StatefulWidget {
  const ManualRoutineSetupScreen({super.key});

  @override
  State<ManualRoutineSetupScreen> createState() =>
      _ManualRoutineSetupScreenState();
}

class _ManualRoutineSetupScreenState extends State<ManualRoutineSetupScreen> {
  final ApiService _api = ApiService();
  final TextEditingController _routineNameController = TextEditingController();
  bool _isLoading = false;

  final List<String> days = const [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  final List<Map<String, dynamic>> routine = [];

  @override
  void initState() {
    super.initState();
    // Initialize empty schedule
    for (final d in days) {
      routine.add({
        'day': d,
        'type': 'Full Body', // This maps to "focus"
        'isRest': false,
        'exercises': <Map<String, dynamic>>[],
      });
    }
  }

  // --- SAVE LOGIC ---
  Future<void> _saveRoutine() async {
    if (_routineNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please name your routine (e.g., Summer Cut)"),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. TRANSFORM DATA to match your exact JSON
      List<Map<String, dynamic>> weeklySchedule = [];

      for (var day in routine) {
        // If Rest Day, send empty exercises and focus = "Rest"
        if (day['isRest'] == true) {
          weeklySchedule.add({
            "day": day['day'],
            "focus": "Rest / Active Recovery",
            "exercises": [],
          });
        } else {
          // If Workout Day, map the exercises
          weeklySchedule.add({
            "day": day['day'],
            "focus": day['type'],
            "exercises": (day['exercises'] as List).map((ex) {
              return {
                "name": ex['name'] ?? "Unknown Exercise",
                "sets": ex['sets'] ?? "3",
                "reps": ex['reps'] ?? "10",
                "rest": ex['rest'] ?? "60s",
                "notes": ex['notes'] ?? "",
                "completed": "No", // ✅ ADDED AS REQUESTED
              };
            }).toList(),
          });
        }
      }

      // 2. CONSTRUCT PAYLOAD
      final payload = {
        "event_type": "create_manual_routine",
        "user_id": UserSession.email, // ✅ From Session
        "routine_summary": _routineNameController.text,
        "weekly_schedule": weeklySchedule,
      };

      print("🚀 Sending Payload: $payload");

      // 3. CALL API
      await _api.createManualRoutine(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Routine Created Successfully!")),
        );
        Navigator.pop(context); // Go back to Plans/Home
      }
    } catch (e) {
      print("❌ Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Create Custom Routine'),
        backgroundColor: AppTheme.bg,
        elevation: 0,
      ),
      body: Column(
        children: [
          // --- ROUTINE NAME INPUT ---
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _routineNameController,
              style: AppTheme.h2,
              decoration: AppTheme.inputDecoration(
                'Routine Name (e.g. Arnold Split)',
              ),
            ),
          ),

          // --- WEEKLY LIST ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
              itemCount: routine.length,
              itemBuilder: (context, index) {
                final day = routine[index];
                return _buildDayCard(day);
              },
            ),
          ),
        ],
      ),

      // --- SAVE BUTTON ---
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: AppTheme.bg,
        child: ElevatedButton(
          style: AppTheme.primaryButton,
          onPressed: _isLoading ? null : _saveRoutine,
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text("Save Routine"),
        ),
      ),
    );
  }

  Widget _buildDayCard(Map<String, dynamic> day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.card,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER: Day Name + Rest Switch
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(day['day'], style: AppTheme.h3),
              Row(
                children: [
                  Text("Rest Day", style: AppTheme.caption),
                  Switch(
                    value: day['isRest'],
                    activeColor: AppTheme.primary,
                    onChanged: (v) => setState(() => day['isRest'] = v),
                  ),
                ],
              ),
            ],
          ),

          if (day['isRest'])
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text("Active Recovery / Rest", style: AppTheme.bodyMuted),
            )
          else ...[
            const SizedBox(height: 12),
            // FOCUS DROPDOWN
            DropdownButtonFormField<String>(
              value: day['type'],
              dropdownColor: AppTheme.cardBg,
              style: AppTheme.body,
              items: const [
                'Full Body',
                'Upper Body',
                'Lower Body',
                'Push',
                'Pull',
                'Legs',
                'Core',
                'Cardio',
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (v) => setState(() => day['type'] = v),
              decoration: AppTheme.inputDecoration('Focus'),
            ),

            const SizedBox(height: 16),
            Text("Exercises", style: AppTheme.h3),

            // EXERCISE LIST
            ...day['exercises'].map<Widget>((ex) {
              return _ExerciseEditor(
                exercise: ex,
                onRemove: () => setState(() => day['exercises'].remove(ex)),
              );
            }).toList(),

            const SizedBox(height: 12),

            // ADD EXERCISE BUTTON
            OutlinedButton.icon(
              style: AppTheme.ghostButton,
              icon: const Icon(Icons.add),
              label: const Text("Add Exercise"),
              onPressed: () {
                setState(() {
                  day['exercises'].add({
                    'name': '',
                    'sets': '',
                    'reps': '',
                    'rest': '',
                    'notes': '',
                  });
                });
              },
            ),
          ],
        ],
      ),
    );
  }
}

// --- EXERCISE EDITOR WIDGET ---
class _ExerciseEditor extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onRemove;

  const _ExerciseEditor({required this.exercise, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBgAlt,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Column(
        children: [
          // Row 1: Name + Remove
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: exercise['name'],
                  onChanged: (v) => exercise['name'] = v,
                  style: AppTheme.body,
                  decoration: AppTheme.inputDecoration(
                    'Exercise Name (e.g. Squat)',
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: Sets, Reps, Rest
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: exercise['sets'],
                  onChanged: (v) => exercise['sets'] = v,
                  style: AppTheme.body,
                  decoration: AppTheme.inputDecoration('Sets'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: exercise['reps'],
                  onChanged: (v) => exercise['reps'] = v,
                  style: AppTheme.body,
                  decoration: AppTheme.inputDecoration('Reps'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextFormField(
                  initialValue: exercise['rest'],
                  onChanged: (v) => exercise['rest'] = v,
                  style: AppTheme.body,
                  decoration: AppTheme.inputDecoration('Rest'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 3: Notes
          TextFormField(
            initialValue: exercise['notes'],
            onChanged: (v) => exercise['notes'] = v,
            style: AppTheme.body,
            decoration: AppTheme.inputDecoration('Notes (Optional)'),
          ),
        ],
      ),
    );
  }
}
