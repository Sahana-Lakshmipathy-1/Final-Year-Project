import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/layouts/plans/meal_day_title.dart';
import 'package:lumora/layouts/plans/edit_meal_day_sheet.dart';
import 'package:lumora/data/meal_plans.dart';
import 'package:lumora/layouts/models/meal_plan.dart';

class MealListSection extends StatefulWidget {
  const MealListSection({super.key});

  @override
  State<MealListSection> createState() => _MealListSectionState();
}

class _MealListSectionState extends State<MealListSection> {
  MealPlan? selectedPlan;

  @override
  void initState() {
    super.initState();
    selectedPlan = mealPlans.first;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Meal List", style: AppTheme.sectionTitle),
        const SizedBox(height: 6),
        Text(
          "Manage your weekly meal routine.",
          style: AppTheme.caption,
        ),
        const SizedBox(height: 14),

        DropdownButtonFormField<MealPlan>(
          value: selectedPlan,
          items: mealPlans.map((plan) {
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
            (day) => MealDayTile(
              day: day,
              onEdit: () => _editDay(day),
            ),
          ),
      ],
    );
  }

  void _editDay(MealDay day) {
    showModalBottomSheet(
      context: context,
      builder: (_) => EditMealDaySheet(day: day),
    ).then((_) => setState(() {}));
  }
}
