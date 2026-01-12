import 'package:flutter/material.dart';
import 'package:lumora/layouts/exercise/saved_exercise_preview.dart';

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
    {
      'id': 4,
      'title': 'Dumbbell Rows',
      'icon': '🏋️',
      'muscle': 'Back',
      'difficulty': 'Intermediate',
      'equipment': 'Dumbbells',
      'description': 'Strengthens back muscles and improves posture.',
      'selected': false,
    },
    {
      'id': 5,
      'title': 'Lunges',
      'icon': '🚶',
      'muscle': 'Legs',
      'difficulty': 'Beginner',
      'equipment': 'Bodyweight',
      'description': 'Unilateral leg exercise for balance and strength.',
      'selected': true,
    },
    {
      'id': 6,
      'title': 'Mountain Climbers',
      'icon': '⛰️',
      'muscle': 'Full Body',
      'difficulty': 'Intermediate',
      'equipment': 'Bodyweight',
      'description': 'Dynamic cardio exercise engaging core and legs.',
      'selected': false,
    },
  ];

  void toggleExercise(int id) {
    setState(() {
      final i = exercises.indexWhere((e) => e['id'] == id);
      if (i != -1) exercises[i]['selected'] = !exercises[i]['selected'];
    });
  }

  void addAll() =>
      setState(() => exercises.forEach((e) => e['selected'] = true));
  void clearAll() =>
      setState(() => exercises.forEach((e) => e['selected'] = false));

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFF0F1431);
    const bg2 = Color(0xFF181C3A);
    const accent = Color(0xFFB787FF);
    const muted = Color(0xFFB7C0E0);
    const danger = Color(0xFFF06272);
    const edge = Color(0xFF2C315C);
    const chip = Color(0xFF262B56);
    const text = Color(0xFFE9ECFF);

    final selectedCount = exercises.where((e) => e['selected']).length;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -1.5),
              radius: 1.2,
              colors: [bg2, bg],
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Your Workout Plan ✨',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: text,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: Text(
                            "$selectedCount exercises",
                            style: const TextStyle(
                              color: Color(0xFF1A1034),
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Review and customize your AI-generated exercises. Drag to reorder, toggle to add/remove.',
                      style: TextStyle(color: muted, fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              ),

              /// Bulk Actions (Add All + Clear All only)
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF23275F).withOpacity(0.9),
                  border: Border.all(color: edge),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: text,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    _bulkButton('Add All', accent, Colors.black, onTap: addAll),
                    const SizedBox(width: 8),
                    _bulkButton(
                      'Clear All',
                      Colors.transparent,
                      danger,
                      border: danger,
                      onTap: clearAll,
                    ),
                  ],
                ),
              ),

              /// Drag-and-Drop Exercise List
              Expanded(
                child: exercises.isEmpty
                    ? const Center(
                        child: Text(
                          'No exercises yet. Start by adding some!',
                          style: TextStyle(color: muted, fontSize: 14),
                        ),
                      )
                    : ReorderableListView.builder(
                        physics: const BouncingScrollPhysics(),
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
                          return ListTile(
                            key: ValueKey(e['id']),
                            contentPadding: EdgeInsets.zero,
                            title: _ExerciseCard(
                              title: e['title'],
                              icon: e['icon'],
                              muscle: e['muscle'],
                              difficulty: e['difficulty'],
                              equipment: e['equipment'],
                              description: e['description'],
                              selected: e['selected'],
                              onToggle: () => toggleExercise(e['id']),
                            ),
                            trailing: const Icon(
                              Icons.drag_handle_rounded,
                              color: muted,
                            ),
                          );
                        },
                      ),
              ),

              /// Footer Buttons
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 8,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const SavedExercisePreview(),
                            ),
                          );
                        },
                        child: const Text(
                          'Confirm & Continue',
                          style: TextStyle(
                            color: Color(0xFF1A1034),
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFF242953),
                          side: const BorderSide(color: Color(0xFF3A3F72)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          'Back to Goals',
                          style: TextStyle(
                            color: text,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bulkButton(
    String label,
    Color bg,
    Color color, {
    Color? border,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border ?? Colors.transparent),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final String title, icon, muscle, difficulty, equipment, description;
  final bool selected;
  final VoidCallback onToggle;

  const _ExerciseCard({
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
    const edge = Color(0xFF2C315C);
    const text = Color(0xFFE9ECFF);
    const muted = Color(0xFFB7C0E0);
    const success = Color(0xFF4ADE80);
    const field = Color(0xFF14183A);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF23275F), Color(0xFF181B40)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: selected ? success : edge),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: field,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF2A2F59)),
            ),
            alignment: Alignment.center,
            child: Text(icon, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: text,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    _metaTag(muscle, const Color(0xFF2FE0C7)),
                    _metaTag(difficulty, muted),
                    _metaTag(equipment, muted),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: muted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: selected ? success : field,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? success : edge, width: 2),
              ),
              child: Icon(
                selected ? Icons.check_rounded : Icons.add_rounded,
                color: selected ? const Color(0xFF1A1034) : muted,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF262B56),
        border: Border.all(color: const Color(0xFF343A6A)),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
