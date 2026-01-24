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
    for (final d in days) {
      routine.add({
        'day': d,
        'type': 'Full Body',
        'isRest': false,
        'exercises': <Map<String, dynamic>>[],
      });
    }
  }

  Future<void> _saveRoutine() async {
    if (_routineNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please name your routine"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. TRANSFORM DATA
      List<Map<String, dynamic>> weeklySchedule = [];

      for (var day in routine) {
        if (day['isRest'] == true) {
          weeklySchedule.add({
            "day": day['day'],
            "focus": "Rest / Active Recovery",
            "exercises": [],
          });
        } else {
          weeklySchedule.add({
            "day": day['day'],
            "focus": day['type'],
            "exercises": (day['exercises'] as List).map((ex) {
              return {
                "name": ex['name'] ?? "Unknown",
                "sets": ex['sets'] ?? "3",
                "reps": ex['reps'] ?? "10",
                "rest": ex['rest'] ?? "60s",
                "notes": ex['notes'] ?? "",
                "completed": "No",
              };
            }).toList(),
          });
        }
      }

      // 2. PAYLOAD
      final payload = {
        "event_type": "create_manual_routine",
        "user_id": UserSession.email,
        "title": _routineNameController.text.trim(),
        "routine_summary":
            "Manual Routine: ${_routineNameController.text.trim()}",
        "weekly_schedule": weeklySchedule,
      };

      await _api.createManualRoutine(payload);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Routine Saved!"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
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
        title: const Text('Create Routine'),
        backgroundColor: AppTheme.bg,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: _isLoading ? null : _saveRoutine,
              child: _isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primary,
                      ),
                    )
                  : const Text(
                      "Save",
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- TOP BAR: ROUTINE NAME ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withOpacity(0.05),
                  width: 1,
                ),
              ),
            ),
            child: TextField(
              controller: _routineNameController,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                hintText: 'Routine Name (e.g. Summer Cut)',
                hintStyle: TextStyle(color: Colors.white30, fontSize: 20),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),

          // --- SCROLLABLE LIST ---
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: routine.length,
              itemBuilder: (context, index) {
                return _DayCard(
                  day: routine[index],
                  onUpdate: () =>
                      setState(() {}), // Refresh UI when data changes
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────── DAY CARD ─────────────────
class _DayCard extends StatefulWidget {
  final Map<String, dynamic> day;
  final VoidCallback onUpdate;

  const _DayCard({required this.day, required this.onUpdate});

  @override
  State<_DayCard> createState() => _DayCardState();
}

class _DayCardState extends State<_DayCard> {
  @override
  Widget build(BuildContext context) {
    bool isRest = widget.day['isRest'];
    List exercises = widget.day['exercises'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- CARD HEADER ---
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.day['day'], style: AppTheme.h3),
                    const SizedBox(height: 6),
                    Text(
                      isRest
                          ? "Rest & Recovery"
                          : "${widget.day['type']} Focus",
                      style: TextStyle(
                        color: isRest ? Colors.greenAccent : AppTheme.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Switch(
                  value: isRest,
                  activeColor: Colors.black,
                  activeTrackColor: Colors.greenAccent,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.grey.shade800,
                  onChanged: (v) {
                    setState(() => widget.day['isRest'] = v);
                    widget.onUpdate();
                  },
                ),
              ],
            ),
          ),

          // --- CONTENT AREA ---
          if (!isRest) ...[
            Divider(height: 1, color: Colors.white.withOpacity(0.08)),

            // Focus Selection
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  const Text(
                    "Target Focus:",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.bg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: widget.day['type'],
                          dropdownColor: AppTheme.cardBg,
                          isDense: true,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                          items:
                              [
                                    'Full Body',
                                    'Upper Body',
                                    'Lower Body',
                                    'Push',
                                    'Pull',
                                    'Legs',
                                    'Core',
                                    'Cardio',
                                  ]
                                  .map(
                                    (e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) {
                            setState(() => widget.day['type'] = v);
                            widget.onUpdate();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Exercises List
            if (exercises.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: exercises.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _ExerciseEditor(
                      exercise: exercises[index],
                      onRemove: () {
                        setState(() => exercises.removeAt(index));
                        widget.onUpdate();
                      },
                    );
                  },
                ),
              ),

            // Add Button
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    backgroundColor: AppTheme.bg,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: AppTheme.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                  ),
                  icon: const Icon(
                    Icons.add,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  label: const Text(
                    "Add Exercise",
                    style: TextStyle(
                      color: AppTheme.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      exercises.add({
                        'name': '',
                        'sets': '',
                        'reps': '',
                        'rest': '',
                        'notes': '',
                      });
                    });
                    widget.onUpdate();
                  },
                ),
              ),
            ),
          ] else
            const SizedBox(height: 4),
        ],
      ),
    );
  }
}

// ───────────────── EXERCISE EDITOR ─────────────────
class _ExerciseEditor extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onRemove;

  const _ExerciseEditor({required this.exercise, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Row 1: Name + Close
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: exercise['name'],
                  onChanged: (v) => exercise['name'] = v,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  decoration: const InputDecoration(
                    hintText: "Exercise Name",
                    hintStyle: TextStyle(color: Colors.white30),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              InkWell(
                onTap: onRemove,
                borderRadius: BorderRadius.circular(4),
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Icon(
                    Icons.close,
                    size: 20,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Row 2: Stats Row (Sets, Reps, Rest)
          Row(
            children: [
              _buildStatInput("Sets", "sets"),
              const SizedBox(width: 10),
              _buildStatInput("Reps", "reps"),
              const SizedBox(width: 10),
              _buildStatInput("Rest", "rest"),
            ],
          ),

          // Row 3: Notes (Optional)
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.cardBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withOpacity(0.05),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.edit_note,
                  size: 18,
                  color: Colors.white.withOpacity(0.3),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: exercise['notes'],
                    onChanged: (v) => exercise['notes'] = v,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                    decoration: const InputDecoration(
                      hintText: "Add notes...",
                      hintStyle: TextStyle(
                        color: Colors.white24,
                        fontSize: 13,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatInput(String label, String key) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            TextFormField(
              initialValue: exercise[key],
              onChanged: (v) => exercise[key] = v,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
