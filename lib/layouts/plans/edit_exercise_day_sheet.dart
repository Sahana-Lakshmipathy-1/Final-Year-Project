import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/layouts/models/exercise_plan.dart';

class EditExerciseDaySheet extends StatefulWidget {
  final ExerciseDay day;

  const EditExerciseDaySheet({
    super.key,
    required this.day,
  });

  @override
  State<EditExerciseDaySheet> createState() => _EditExerciseDaySheetState();
}

class _EditExerciseDaySheetState extends State<EditExerciseDaySheet> {
  late TextEditingController workoutCtrl;

  @override
  void initState() {
    super.initState();
    workoutCtrl = TextEditingController(text: widget.day.workout);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.day.day, style: AppTheme.h3),
          const SizedBox(height: 14),

          TextField(
            controller: workoutCtrl,
            decoration: const InputDecoration(
              labelText: "Workout",
              helperText: "Example: Cardio, Strength, Yoga",
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.day.workout = workoutCtrl.text;
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ),
        ],
      ),
    );
  }
}
