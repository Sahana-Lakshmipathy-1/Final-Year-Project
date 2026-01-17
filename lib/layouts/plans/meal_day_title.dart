import 'package:flutter/material.dart';
import 'package:lumora/theme/app_theme.dart';
import 'package:lumora/layouts/models/meal_plan.dart';

class MealDayTile extends StatelessWidget {
  final MealDay day;
  final VoidCallback onEdit;

  const MealDayTile({
    super.key,
    required this.day,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: AppTheme.elevatedCard,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(day.day, style: AppTheme.h3),
                const SizedBox(height: 6),
                Text("🍽️ ${day.meals}", style: AppTheme.caption),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
