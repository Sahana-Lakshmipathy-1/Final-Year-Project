import 'package:flutter/material.dart';
import 'package:lumora/layouts/exercise/saved_exercise_preview.dart';
import 'package:lumora/theme/app_theme.dart';

class ExercisePreviewScreen extends StatefulWidget {
  const ExercisePreviewScreen({super.key});

  @override
  State<ExercisePreviewScreen> createState() => _ExercisePreviewScreenState();
}

class _ExercisePreviewScreenState extends State<ExercisePreviewScreen> {
  List<Map<String, dynamic>> exercises = [
    {
      'id': 1,
      'title': 'Push-ups',
      'icon': '💪',
      'muscle': 'Chest',
      'difficulty': 'Beginner',
      'equipment': 'Bodyweight',
      'description':
          'Classic upper body exercise targeting chest, shoulders, and triceps.',
      'selected': true,
    },
    {
      'id': 2,
      'title': 'Squats',
      'icon': '🦵',
      'muscle': 'Legs',
      'difficulty': 'Beginner',
      'equipment': 'Bodyweight',
      'description':
          'Fundamental lower body movement for quads, glutes, and core.',
      'selected': true,
    },
    {
      'id': 3,
      'title': 'Plank Hold',
      'icon': '🧘',
      'muscle': 'Core',
      'difficulty': 'Beginner',
      'equipment': 'Bodyweight',
      'description':
          'Isometric core exercise building stability and endurance.',
      'selected': true,
    },
  ];

  void toggleExercise(int id) {
    setState(() {
      final index = exercises.indexWhere((e) => e['id'] == id);
      if (index != -1) {
        exercises[index]['selected'] = !exercises[index]['selected'];
      }
    });
  }

  void addAll() =>
      setState(() => exercises.forEach((e) => e['selected'] = true));

  void clearAll() =>
      setState(() => exercises.forEach((e) => e['selected'] = false));

  @override
  Widget build(BuildContext context) {
    final selectedCount = exercises.where((e) => e['selected'] == true).length;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text("Workout Preview"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(
                "$selectedCount selected",
                style: AppTheme.caption.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              backgroundColor: AppTheme.primary.withOpacity(0.15),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          /// INFO
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              "Review and customize your workout. Reorder exercises and choose what fits your goals.",
              style: AppTheme.bodyMuted,
            ),
          ),

          /// QUICK ACTIONS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text("Quick actions", style: AppTheme.caption),
                const Spacer(),
                TextButton(
                  onPressed: addAll,
                  child: const Text("Add all"),
                ),
                TextButton(
                  onPressed: clearAll,
                  child: Text(
                    "Clear",
                    style: TextStyle(color: AppTheme.danger),
                  ),
                ),
              ],
            ),
          ),

          /// LIST
          Expanded(
            child: exercises.isEmpty
                ? Center(
                    child: AppTheme.emptyState(
                      title: "No exercises",
                      subtitle: "Add exercises to build your workout",
                      icon: Icons.fitness_center,
                    ),
                  )
                : ReorderableListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: exercises.length,
                    onReorder: (oldIndex, newIndex) {
                      setState(() {
                        if (newIndex > oldIndex) newIndex -= 1;
                        final item = exercises.removeAt(oldIndex);
                        exercises.insert(newIndex, item);
                      });
                    },
                    itemBuilder: (context, index) {
                      final e = exercises[index];
                      return ExerciseCard(
                        key: ValueKey(e['id']),
                        title: e['title'],
                        icon: e['icon'],
                        muscle: e['muscle'],
                        difficulty: e['difficulty'],
                        equipment: e['equipment'],
                        description: e['description'],
                        selected: e['selected'],
                        onToggle: () => toggleExercise(e['id']),
                      );
                    },
                  ),
          ),

          /// CTA
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: AppTheme.primaryButton,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SavedExercisePreview(),
                        ),
                      );
                    },
                    child: const Text("Confirm & Continue"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    style: AppTheme.ghostButton,
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Back"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseCard extends StatelessWidget {
  final String title, icon, muscle, difficulty, equipment, description;
  final bool selected;
  final VoidCallback onToggle;

  const ExerciseCard({
    super.key,
    required this.title,
    required this.icon,
    required this.muscle,
    required this.difficulty,
    required this.equipment,
    required this.description,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: AppTheme.radiusMedium,
        border: Border.all(
          color: selected ? AppTheme.success : AppTheme.borderSoft,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ICON
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppTheme.cardBgAlt,
                borderRadius: AppTheme.radiusSmall,
              ),
              alignment: Alignment.center,
              child: Text(icon, style: const TextStyle(fontSize: 26)),
            ),

            const SizedBox(width: 12),

            /// INFO
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTheme.h2),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: [
                      AppTheme.chip(muscle, color: AppTheme.primary),
                      AppTheme.chip(difficulty),
                      AppTheme.chip(equipment),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(description, style: AppTheme.bodyMuted),
                ],
              ),
            ),

            const SizedBox(width: 12),

            /// TOGGLE
            InkWell(
              onTap: onToggle,
              borderRadius: AppTheme.radiusSmall,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.success.withOpacity(0.15)
                      : AppTheme.cardBgAlt,
                  borderRadius: AppTheme.radiusSmall,
                  border: Border.all(
                    color: selected ? AppTheme.success : AppTheme.borderSoft,
                  ),
                ),
                child: Icon(
                  selected ? Icons.check : Icons.add,
                  color: selected ? AppTheme.success : AppTheme.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
