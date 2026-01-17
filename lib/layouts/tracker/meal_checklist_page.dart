import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/components/checklist_item.dart';

class MealChecklistPage extends StatefulWidget {
  const MealChecklistPage({super.key});

  @override
  State<MealChecklistPage> createState() => _MealChecklistPageState();
}

class _MealChecklistPageState extends State<MealChecklistPage> {
  final List<bool> _completed = List.filled(4, false);

  final meals = const [
    ("Breakfast", "Oats • Fruits • Protein"),
    ("Lunch", "Rice • Vegetables • Protein"),
    ("Snack", "Nuts • Smoothie"),
    ("Dinner", "Light meal • Low carbs"),
  ];

  @override
  Widget build(BuildContext context) {
    final completedCount = _completed.where((e) => e).length;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("Meal Plan", style: AppTheme.h2),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "$completedCount / ${meals.length} logged",
              style: AppTheme.bodyMuted,
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView.builder(
                itemCount: meals.length,
                itemBuilder: (context, index) {
                  final item = meals[index];
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
              onPressed: () => Navigator.pop(context),
              child: const Text("Save meals"),
            ),
          ],
        ),
      ),
    );
  }
}
