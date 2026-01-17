import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Manual Weekly Routine'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: routine.length,
        itemBuilder: (context, index) {
          final day = routine[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: AppTheme.card,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// DAY HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(day['day'], style: AppTheme.h2),
                    Row(
                      children: [
                        Text("Rest day", style: AppTheme.caption),
                        const SizedBox(width: 6),
                        Switch(
                          value: day['isRest'],
                          onChanged: (v) => setState(() => day['isRest'] = v),
                        ),
                      ],
                    ),
                  ],
                ),

                if (day['isRest']) ...[
                  const SizedBox(height: 12),
                  Text(
                    "Recovery is important. No workout scheduled.",
                    style: AppTheme.bodyMuted,
                  ),
                ] else ...[
                  const SizedBox(height: 16),

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
                    decoration: AppTheme.inputDecoration('Workout focus'),
                  ),

                  const SizedBox(height: 12),

                  /// TOTAL DURATION
                  TextFormField(
                    initialValue: day['totalDuration'],
                    onChanged: (v) => day['totalDuration'] = v,
                    decoration: AppTheme.inputDecoration(
                      'Total duration (e.g. 45 min)',
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// EXERCISES
                  Text("Exercises", style: AppTheme.h2),
                  const SizedBox(height: 8),

                  ...day['exercises'].map<Widget>((ex) {
                    return _ExerciseEditor(
                      exercise: ex,
                      onRemove: () =>
                          setState(() => day['exercises'].remove(ex)),
                    );
                  }).toList(),

                  const SizedBox(height: 8),

                  /// ADD EXERCISE
                  OutlinedButton.icon(
                    style: AppTheme.ghostButton,
                    icon: const Icon(Icons.add),
                    label: const Text("Add exercise"),
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

      /// SAVE
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          style: AppTheme.primaryButton,
          onPressed: () => Navigator.pop(context, routine),
          child: const Text("Save routine"),
        ),
      ),
    );
  }
}

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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cardBgAlt,
        borderRadius: AppTheme.radiusSmall,
        border: Border.all(color: AppTheme.borderSoft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// NAME
          TextFormField(
            onChanged: (v) => widget.exercise['title'] = v,
            decoration: AppTheme.inputDecoration('Exercise name'),
          ),

          const SizedBox(height: 10),

          /// TAGS
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: tagCtrl,
                  decoration: AppTheme.inputDecoration('Add tag'),
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
                  (t) => AppTheme.chip(
                    t,
                    color: AppTheme.primary,
                  ),
                )
                .toList(),
          ),

          const SizedBox(height: 10),

          /// SETS + REPS
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  onChanged: (v) => widget.exercise['sets'] = v,
                  decoration: AppTheme.inputDecoration('Sets'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  onChanged: (v) => widget.exercise['duration'] = v,
                  decoration: AppTheme.inputDecoration('Reps / Duration'),
                ),
              ),
            ],
          ),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: widget.onRemove,
              child: Text(
                "Remove",
                style: AppTheme.caption.copyWith(
                  color: AppTheme.danger,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
