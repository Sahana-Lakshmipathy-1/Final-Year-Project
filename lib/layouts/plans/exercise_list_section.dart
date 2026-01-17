import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/data/exercise_plans.dart';
import 'package:lumora/layouts/plans/exercise_day_tile.dart';
import 'package:lumora/layouts/plans/edit_exercise_day_sheet.dart';
import 'package:lumora/layouts/models/exercise_plan.dart';

class ExerciseListSection extends StatefulWidget {
  const ExerciseListSection({super.key});

  @override
  State<ExerciseListSection> createState() => _ExerciseListSectionState();
}

class _ExerciseListSectionState extends State<ExerciseListSection> {
  ExercisePlan? selectedPlan;

  @override
  void initState() {
    super.initState();
    selectedPlan = exercisePlans.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Exercise List", style: AppTheme.sectionTitle),
        const SizedBox(height: 6),
        Text(
          "Manage your weekly workout routine.",
          style: AppTheme.caption,
        ),
        const SizedBox(height: 14),

        DropdownButtonFormField<ExercisePlan>(
          value: selectedPlan,
          items: exercisePlans.map((plan) {
            return DropdownMenuItem(
              value: plan,
              child: Text(plan.title),
            );
          }).toList(),
          onChanged: (v) => setState(() => selectedPlan = v),
        ),

        const SizedBox(height: 20),

        if (selectedPlan != null)
          ...selectedPlan!.days.map(
            (day) => ExerciseDayTile(
              day: day,
              onEdit: () => _editDay(day),
            ),
          ),
      ],
    );
  }

  void _editDay(ExerciseDay day) {
    showModalBottomSheet(
      context: context,
      builder: (_) => EditExerciseDaySheet(day: day),
    ).then((_) => setState(() {}));
  }
}
