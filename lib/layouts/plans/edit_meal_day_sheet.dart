import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/layouts/models/meal_plan.dart';

class EditMealDaySheet extends StatefulWidget {
  final MealDay day;

  const EditMealDaySheet({
    super.key,
    required this.day,
  });

  @override
  State<EditMealDaySheet> createState() => _EditMealDaySheetState();
}

class _EditMealDaySheetState extends State<EditMealDaySheet> {
  late TextEditingController mealCtrl;

  @override
  void initState() {
    super.initState();
    mealCtrl = TextEditingController(text: widget.day.meals);
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
            controller: mealCtrl,
            decoration: const InputDecoration(
              labelText: "Meals",
              helperText: "Example: High protein, Low carb",
            ),
          ),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.day.meals = mealCtrl.text;
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
