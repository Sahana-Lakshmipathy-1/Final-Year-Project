import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/components/checklist_item.dart';

class WorkoutChecklistPage extends StatefulWidget {
  const WorkoutChecklistPage({super.key});

  @override
  State<WorkoutChecklistPage> createState() => _WorkoutChecklistPageState();
}

class _WorkoutChecklistPageState extends State<WorkoutChecklistPage> {
  final List<bool> _completed = List.filled(5, false);

  final exercises = const [
    ("Push Ups", "3 sets • 12 reps"),
    ("Dumbbell Rows", "3 sets • 10 reps"),
    ("Shoulder Press", "3 sets • 10 reps"),
    ("Lateral Raises", "3 sets • 12 reps"),
    ("Plank Hold", "3 sets • 45 sec"),
  ];

  @override
  Widget build(BuildContext context) {
    final completedCount = _completed.where((e) => e).length;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Upper Body Workout", style: AppTheme.h2),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$completedCount / ${exercises.length} completed",
              style: AppTheme.bodyMuted,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final item = exercises[index];
                  return ChecklistItem(
                    title: item.$1,
                    subtitle: item.$2,
                    completed: _completed[index],
                    onToggle: () {
                      setState(() {
                        _completed[index] = !_completed[index];
                      });
                    },
                  );
                },
              ),
            ),

            ElevatedButton(
              style: AppTheme.primaryButton,
              onPressed: completedCount == exercises.length
                  ? () => Navigator.pop(context)
                  : null,
              child: const Text("Finish workout"),
            ),
          ],
        ),
      ),
    );
  }
}
