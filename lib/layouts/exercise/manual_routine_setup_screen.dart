import 'package:flutter/material.dart';

class ManualRoutineSetupScreen extends StatefulWidget {
  const ManualRoutineSetupScreen({super.key});

  @override
  State<ManualRoutineSetupScreen> createState() =>
      _ManualRoutineSetupScreenState();
}

class _ManualRoutineSetupScreenState extends State<ManualRoutineSetupScreen> {
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
        'totalDuration': '45 min',
        'isRest': false,
        'exercises': <Map<String, dynamic>>[],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F1431);
    const card = Color(0xFF181C3A);
    const accent = Color(0xFFB787FF);
    const text = Color(0xFFE9ECFF);
    const muted = Color(0xFFB7C0E0);
    const edge = Color(0xFF2C315C);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('Manual Weekly Routine'),
        backgroundColor: card,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: routine.length,
        itemBuilder: (context, index) {
          final day = routine[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: edge),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// DAY HEADER + REST TOGGLE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      day['day'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: text,
                      ),
                    ),
                    Row(
                      children: [
                        const Text('Rest', style: TextStyle(color: muted)),
                        Switch(
                          value: day['isRest'],
                          activeColor: accent,
                          onChanged: (v) => setState(() => day['isRest'] = v),
                        ),
                      ],
                    ),
                  ],
                ),

                if (!day['isRest']) ...[
                  const SizedBox(height: 12),

                  /// WORKOUT TYPE
                  DropdownButtonFormField<String>(
                    value: day['type'],
                    items:
                        const [
                              'Full Body',
                              'Upper Body',
                              'Lower Body',
                              'Push',
                              'Pull',
                              'Legs',
                              'Core',
                            ]
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (v) => setState(() => day['type'] = v),
                    decoration: _dec('Workout Type'),
                  ),

                  const SizedBox(height: 10),

                  /// TOTAL DAY DURATION
                  TextFormField(
                    initialValue: day['totalDuration'],
                    onChanged: (v) => day['totalDuration'] = v,
                    decoration: _dec('Total Day Duration (e.g. 45 min)'),
                  ),

                  const SizedBox(height: 14),

                  /// EXERCISES
                  ...day['exercises'].map<Widget>((ex) {
                    return _ExerciseEditor(
                      exercise: ex,
                      onRemove: () {
                        setState(() => day['exercises'].remove(ex));
                      },
                    );
                  }).toList(),

                  /// ADD EXERCISE BUTTON
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Add Exercise'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: accent,
                      side: BorderSide(color: accent),
                    ),
                    onPressed: () {
                      setState(() {
                        day['exercises'].add({
                          'title': '',
                          'tags': <String>[],
                          'sets': '',
                          'duration': '',
                        });
                      });
                    },
                  ),
                ],
              ],
            ),
          );
        },
      ),

      /// SUBMIT
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: accent,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            Navigator.pop(context, routine);
          },
          child: const Text(
            'Save Routine',
            style: TextStyle(
              color: Color(0xFF1A1034),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
    labelText: label,
    filled: true,
    fillColor: const Color(0xFF14183A),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  );
}

/// ---------------- EXERCISE INPUT BLOCK ----------------

class _ExerciseEditor extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onRemove;

  const _ExerciseEditor({
    required this.exercise,
    required this.onRemove,
  });

  @override
  State<_ExerciseEditor> createState() => _ExerciseEditorState();
}

class _ExerciseEditorState extends State<_ExerciseEditor> {
  final tagCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const muted = Color(0xFFB7C0E0);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF14183A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          /// EXERCISE NAME
          TextFormField(
            onChanged: (v) => widget.exercise['title'] = v,
            decoration: const InputDecoration(labelText: 'Exercise Name'),
          ),

          const SizedBox(height: 8),

          /// TAG INPUT
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: tagCtrl,
                  decoration: const InputDecoration(labelText: 'Add Tag'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  if (tagCtrl.text.isNotEmpty) {
                    setState(() {
                      widget.exercise['tags'].add(tagCtrl.text);
                      tagCtrl.clear();
                    });
                  }
                },
              ),
            ],
          ),

          Wrap(
            spacing: 6,
            children: widget.exercise['tags']
                .map<Widget>(
                  (t) => Chip(
                    label: Text(t),
                    onDeleted: () {
                      setState(() => widget.exercise['tags'].remove(t));
                    },
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 8),

          /// SETS
          TextFormField(
            onChanged: (v) => widget.exercise['sets'] = v,
            decoration: const InputDecoration(labelText: 'Sets (e.g. 3)'),
          ),

          const SizedBox(height: 8),

          /// DURATION / REPS
          TextFormField(
            onChanged: (v) => widget.exercise['duration'] = v,
            decoration: const InputDecoration(labelText: 'Duration / Reps'),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onRemove,
              child: const Text('Remove', style: TextStyle(color: muted)),
            ),
          ),
        ],
      ),
    );
  }
}
